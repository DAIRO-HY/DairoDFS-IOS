//
//  FileUploadViewModel.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/12.
//

import Foundation
import DairoUI_IOS
import DairoFileSDK

class FileUploadViewModel : ObservableObject{
    
    /// 列表最多显示的数量
    private static let MAX_COUNT: UInt64 = 1000
    
    /// 上传列表
    @Published var list = [UploadInfo]()
    
    /// 上传ID => 进度信息
    @Published var progressInfo = [Int64 : String]()
    
    /// 当前选中的id
    @Published var checked = Set<Int64>()
    init(){
        self.reload()
    }
    
    /// 重新加载数据
    func reload(){
        guard let account = FileSdkUtil.dfsAccount else{
            self.list = []
            return
        }
        do {
            let query = UploadQuery(account: account, state: nil, offset: 0, limit: FileUploadViewModel.MAX_COUNT)
            self.list = try FileSdkUtil.get().listUploads(query: query)
        } catch {
            Toast.show(error.fileSdkMessage)
        }
    }
    
    /// SDK事件
    func onFileSdkEvent(_ event: Event){
        switch event{
        case let .uploadProgress(id, hashing, size, done, speed):
            guard let index = (self.list.firstIndex{ $0.id == id }) else{
                return
            }
            self.list[index].size = size
            if hashing{
                self.progressInfo[id] = "文件校验中 \(Int64(done).fileSize)"
            } else {
                self.list[index].uploaded = done
                self.progressInfo[id] = "\(Int64(done).fileSize)(\(Int64(speed).fileSize)/S)"
            }
        case let .uploadStateChanged(id, state, error):
            guard let index = (self.list.firstIndex{ $0.id == id }) else{
                self.reload()
                return
            }
            self.list[index].state = state
            self.list[index].error = error
            if state != .uploading{
                self.progressInfo[id] = nil
            }
        case let .uploadRemoved(ids):
            self.list.removeAll{ ids.contains($0.id) }
            self.checked.subtract(ids)
        default:
            break
        }
    }
    
    /// 选中状态点击事件
    func onCheckClick(_ id: Int64){
        if self.checked.contains(id){
            self.checked.remove(id)
        } else {
            self.checked.insert(id)
        }
    }
    
    /// 选择所有点击事件
    func onCheckAllClick(){
        self.checked.formUnion(self.list.map{ $0.id })
    }
    
    /// 暂停/开始点击事件
    func onStateClick(_ item: UploadInfo){
        self.run{
            if item.state == .waiting || item.state == .uploading{
                try FileSdkUtil.get().pauseUploads(ids: [item.id])
            } else {
                try FileSdkUtil.get().resumeUploads(ids: [item.id])
            }
        }
    }
    
    /// 暂停所有点击事件
    func onPauseAllClick(){
        self.run{ try FileSdkUtil.get().pauseAllUploads() }
    }
    
    /// 开始所有点击事件
    func onStartAllClick(){
        self.run{ try FileSdkUtil.get().resumeAllUploads() }
    }
    
    /// 删除点击事件,删除会等待任务停止,不能在主线程调用
    func onDeleteClick(){
        let ids = Array(self.checked)
        self.checked.removeAll()
        Task.detached{
            do {
                try FileSdkUtil.get().deleteUploads(ids: ids)
            } catch {
                Toast.show(error.fileSdkMessage)
            }
            Task{@MainActor in
                self.reload()
            }
        }
    }
    
    /// 执行操作之后刷新列表
    private func run(_ action: () throws -> Void){
        do {
            try action()
        } catch {
            Toast.show(error.fileSdkMessage)
        }
        self.reload()
    }
}
