//
//  FileDownloadViewModel.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/01.
//

import Foundation
import DairoUI_IOS
import DairoFileSDK

class FileDownloadViewModel : ObservableObject{
    
    /// 列表最多显示的数量
    private static let MAX_COUNT: UInt64 = 1000
    
    /// 当前显示的模式 下载或缓存
    @Published var mode = CacheMode.save
    
    /// 文件列表
    @Published var list = [CacheInfo]()
    
    /// 文件ID => 下载速度
    @Published var speeds = [String : UInt64]()
    
    /// 当前选中的id
    @Published var checked = Set<String>()
    
    init(){
        self.reload()
    }
    
    /// 重新加载数据
    func reload(){
        do {
            let query = CacheQuery(group: nil, mode: self.mode, state: nil, offset: 0, limit: FileDownloadViewModel.MAX_COUNT)
            self.list = try FileSdkUtil.get().list(query: query)
        } catch {
            Toast.show(error.fileSdkMessage)
        }
    }
    
    /// 切换下载和缓存
    func onModeClick(_ mode: CacheMode){
        self.mode = mode
        self.checked.removeAll()
        self.reload()
    }
    
    /// SDK事件
    func onFileSdkEvent(_ event: Event){
        switch event{
        case let .progress(id, _, size, downloaded, speed):
            guard let index = (self.list.firstIndex{ $0.id == id }) else{
                return
            }
            self.list[index].size = size
            self.list[index].downloaded = downloaded
            self.speeds[id] = speed
        case let .stateChanged(id, mode, state, error):
            guard let index = (self.list.firstIndex{ $0.id == id }) else{
                if mode == self.mode{//新添加的文件
                    self.reload()
                }
                return
            }
            self.list[index].state = state
            self.list[index].error = error
            if state != .downloading{
                self.speeds[id] = nil
            }
        case let .removed(ids):
            self.list.removeAll{ ids.contains($0.id) }
            self.checked.subtract(ids)
        default:
            break
        }
    }
    
    /// 选中状态点击事件
    func onCheckClick(_ id: String){
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
    func onStateClick(_ item: CacheInfo){
        self.run{
            if item.state == .waiting || item.state == .downloading{
                try FileSdkUtil.get().pause(ids: [item.id])
            } else {
                try FileSdkUtil.get().resume(ids: [item.id])
            }
        }
    }
    
    /// 暂停所有点击事件
    func onPauseAllClick(){
        self.run{ try FileSdkUtil.get().pauseAll() }
    }
    
    /// 开始所有点击事件
    func onStartAllClick(){
        self.run{ try FileSdkUtil.get().resumeAll() }
    }
    
    /// 删除点击事件,删除会等待任务停止,不能在主线程调用
    func onDeleteClick(){
        let ids = Array(self.checked)
        self.checked.removeAll()
        Task.detached{
            do {
                try FileSdkUtil.get().delete(ids: ids)
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
