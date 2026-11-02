//
//  FileBackgroundTransfer.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/03.
//

import BackgroundTasks
import DairoFileSDK
import UIKit

/**
 让上传和永久下载在App进入后台后尽量继续,所有方法都在主线程调用
 iOS26及以上使用BGContinuedProcessingTask,系统提前结束或者提交失败时使用beginBackgroundTask多争取一点时间
 系统不保证传输完成,被挂起的任务回到前台后由SDK继续
 */
final class FileBackgroundTransfer {
    
    static let shared = FileBackgroundTransfer()
    
    ///后台任务ID前缀,要和Info.plist里的BGTaskSchedulerPermittedIdentifiers对应
    private static let TASK_ID_PREFIX = "cn.dairo.dfs.transfer."
    
    ///后台任务运行时,检查传输进度的间隔(秒)
    private static let REFRESH_INTERVAL = 1.0
    
    ///正在运行的BGContinuedProcessingTask
    private var continuedTask: BGTask?
    
    ///BGContinuedProcessingTask是否已提交,还没开始运行
    private var isSubmitting = false
    
    ///提交失败之后,到App下次回到前台之前不再提交,避免每个传输事件都重试一次
    private var isSubmitFailed = false
    
    ///beginBackgroundTask的任务ID
    private var backgroundTaskId = UIBackgroundTaskIdentifier.invalid
    
    private var timer: Timer?
    
    ///本次后台任务里每个文件的大小和已传输大小,传输完成的文件也保留,保证总进度不会倒退
    private var transfers = [String: (size: UInt64, done: UInt64)]()
    
    private var observers = [NSObjectProtocol]()
    
    private init() {}
    
    /**
     开始监听传输和App状态,只调用一次
     */
    func start() {
        let center = NotificationCenter.default
        self.observers = [
            center.addObserver(forName: FileSdkUtil.EVENT, object: nil, queue: .main){ [weak self] in
                if let event = $0.object as? Event, FileBackgroundTransfer.isTransferStarted(event){
                    self?.submitContinuedTask()
                }
            },
            center.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main){ [weak self] _ in
                self?.endBackgroundTask()
                self?.isSubmitFailed = false
                self?.submitContinuedTask()
            },
            center.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main){ [weak self] _ in
                self?.beginBackgroundTask()
            }
        ]
    }
    
    /// 事件是否表示有传输开始了,缓存图片和视频不算在内
    private static func isTransferStarted(_ event: Event) -> Bool {
        switch event {
        case let .stateChanged(_, mode, state, _):
            return mode == .save && (state == .waiting || state == .downloading)
        case let .uploadStateChanged(_, state, _):
            return state == .waiting || state == .uploading
        default:
            return false
        }
    }
    
    /// 查询正在进行的传输
    private func activeTransfers() -> [String: (size: UInt64, done: UInt64)] {
        guard let sdk = try? FileSdkUtil.get() else{
            return [:]
        }
        var result = [String: (size: UInt64, done: UInt64)]()
        for state in [DownloadState.waiting, .downloading]{
            let query = CacheQuery(group: nil, mode: .save, state: state, offset: 0, limit: UInt64(Int32.max))
            for it in (try? sdk.list(query: query)) ?? []{
                result["download-\(it.id)"] = (it.size ?? it.downloaded, it.downloaded)
            }
        }
        if let account = FileSdkUtil.dfsAccount{
            for state in [UploadState.waiting, .uploading]{
                let query = UploadQuery(account: account, state: state, offset: 0, limit: UInt64(Int32.max))
                for it in (try? sdk.listUploads(query: query)) ?? []{
                    result["upload-\(it.id)"] = (it.size ?? it.uploaded, it.uploaded)
                }
            }
        }
        return result
    }
    
    /// 提交BGContinuedProcessingTask,只能在前台提交
    private func submitContinuedTask() {
        guard #available(iOS 26.0, *) else{
            return
        }
        guard UIApplication.shared.applicationState == .active, self.continuedTask == nil, !self.isSubmitting, !self.isSubmitFailed,
              !self.activeTransfers().isEmpty else{
            return
        }
        
        //同一个ID只能注册一次,否则系统会杀掉App,所以每次都用新的ID
        let identifier = FileBackgroundTransfer.TASK_ID_PREFIX + UUID().uuidString
        let isRegistered = BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: .main){ [weak self] task in
            self?.onContinuedTaskStart(task)
        }
        guard isRegistered else{
            self.isSubmitFailed = true
            print("注册后台传输任务失败")
            return
        }
        let request = BGContinuedProcessingTaskRequest(identifier: identifier, title: "正在传输文件", subtitle: "准备中")
        request.strategy = .fail
        do {
            self.isSubmitting = true
            try BGTaskScheduler.shared.submit(request)
        } catch {
            self.isSubmitting = false
            self.isSubmitFailed = true
            print("提交后台传输任务失败:\(error)")
        }
    }
    
    /// BGContinuedProcessingTask开始运行
    private func onContinuedTaskStart(_ task: BGTask) {
        self.isSubmitting = false
        self.continuedTask = task
        task.expirationHandler = { [weak self] in
            DispatchQueue.main.async {
                self?.finishContinuedTask(success: false)
            }
        }
        self.endBackgroundTask()
        self.startTimer()
        self.refresh()
    }
    
    /// 结束BGContinuedProcessingTask
    private func finishContinuedTask(success: Bool) {
        guard let task = self.continuedTask else{
            return
        }
        self.continuedTask = nil
        self.stopTimer()
        task.setTaskCompleted(success: success)
        
        //被系统提前结束时,如果App已经在后台,再多争取一点时间
        if !success && UIApplication.shared.applicationState == .background{
            self.beginBackgroundTask()
        }
    }
    
    /// 申请一段后台运行时间
    private func beginBackgroundTask() {
        guard self.continuedTask == nil, self.backgroundTaskId == .invalid, !self.activeTransfers().isEmpty else{
            return
        }
        self.backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: "FileTransfer"){ [weak self] in
            self?.endBackgroundTask()
        }
        self.startTimer()
    }
    
    /// 结束后台运行时间
    private func endBackgroundTask() {
        guard self.backgroundTaskId != .invalid else{
            return
        }
        FileSdkUtil.flush()
        UIApplication.shared.endBackgroundTask(self.backgroundTaskId)
        self.backgroundTaskId = .invalid
        if self.continuedTask == nil{
            self.stopTimer()
        }
    }
    
    private func startTimer() {
        guard self.timer == nil else{
            return
        }
        self.transfers = [:]
        self.timer = Timer.scheduledTimer(withTimeInterval: FileBackgroundTransfer.REFRESH_INTERVAL, repeats: true){ [weak self] _ in
            self?.refresh()
        }
    }
    
    private func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    /// 上报传输进度,没有传输时结束后台任务
    private func refresh() {
        let active = self.activeTransfers()
        for (id, transfer) in active{
            self.transfers[id] = transfer
        }
        
        //刚离开列表的文件,按传输完成计算,暂停和失败的文件也不再等待
        for (id, transfer) in self.transfers where active[id] == nil{
            self.transfers[id] = (transfer.size, transfer.size)
        }
        if #available(iOS 26.0, *), let task = self.continuedTask as? BGContinuedProcessingTask{
            let total = self.transfers.values.reduce(UInt64(0)){ $0 + $1.size }
            let done = self.transfers.values.reduce(UInt64(0)){ $0 + $1.done }
            task.progress.totalUnitCount = Int64(max(total, 1))
            task.progress.completedUnitCount = Int64(min(done, max(total, 1)))
            task.updateTitle("正在传输文件", subtitle: "还剩\(active.count)个文件")
        }
        if active.isEmpty{
            self.endBackgroundTask()
            self.finishContinuedTask(success: true)
        }
    }
}
