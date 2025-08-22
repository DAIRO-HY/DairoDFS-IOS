//
//  DownloadViewModel.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/12.
//

import Foundation

class FileUploadViewModel : ObservableObject{
    
    /// 加载的列表的保存方式
    @Published var saveType: Int8 = 1
    
    /// 文件id列表
    @Published var ids = [String]()
    
    /// 当前选中的id
    @Published var checked = Set<String>()
    init(){
        self.reload()
    }
    
    /// 重新加载数据
    func reload(){
        self.ids = UploaderDBUtil.selectAllId()
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
        self.ids.forEach{
            self.checked.insert($0)
        }
    }
    
    /// 删除点击事件
    func onDeleteClick(){
//        DownloadManager.delete(Array(self.checked))
//        self.checked.removeAll()
//        self.reload()
    }
    
    /// 暂停所有点击事件
    func onPauseAllClick(){
//        DownloadManager.cancelAll()
//        self.reload()
    }
    
    /// 开始所有点击事件
    func onStartAllClick(){
//        DownloadManager.startAll()
//        DownloadManager.loopDownloadByWaiting()
//        self.reload()
    }
}
