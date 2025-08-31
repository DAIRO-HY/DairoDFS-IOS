//
//  FileUploaderManager.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/07/16.
//

import DairoUI_IOS
import Foundation

class FileUploaderManager{
    
    //通知:上传数量发生变化
    static let NOTIFY_UPLOAD_COUNT = "NOTIFY_FILE_UPLOAD_COUNT"
    
    //通知:上传进度通知
    static let NOTIFY_UPLOAD_PROGRESS = "NOTIFY_FILE_UPLOAD_PROGRESS"
    
    //通知:单个文件上传完成通知
    static let NOTIFY_UPLOAD_ITEM_FINISH = "NOTIFY_FILE_UPLOAD_ITEM_FINISH"
    
    //通知:全部文件上传完成通知
    static let NOTIFY_UPLOAD_FINISH = "NOTIFY_FILE_UPLOAD_FINISH"
    
    //已经上传的文件ID
    static var uploadedSet = Set<String>()
    
    private static let lock = NSLock()
    
    //正在上传中的任务  文件ID => 上传任务
    private static var uploading = [Int64 : FileUploader]()
    
    //当前上传总数
    private static var total = 0
    
    //是否取消
    private static var isCancel = false
    
    //开始上传
    static func upload(_ list: [FileUploaderDto]){
        self.lock.lock()
        try? FileUploaderDBUtil.add(list)
        self.isCancel = false
        self.lock.unlock()
        Task.detached{
            
            //启动上传
            FileUploaderManager.loopUpload()
        }
    }
    
    /// 循环上传
    static func loopUpload(){
        self.lock.lock()
        while true{
            guard let dto = FileUploaderDBUtil.selectOneForNeedUpload() else{//如果没有需要上传的文件
                break
            }
            if self.uploading.count >= FileUploaderConfig.maxUploadingCount {//当前下载并发数已到上限
                break
            }
            
            //将文件标记为正在下载中
            FileUploaderDBUtil.setState(dto.id, 1)
            self.uploading[dto.id] = FileUploader(dto)
            self.uploading[dto.id]!.upload()
        }
        //        let countMsg = "进度:\(FileUploaderManager.total - self.uploadWaitingList.count - self.uploading.count + 1)/\(self.total)"
        //        Task{@MainActor in
        //            NotificationCenter.default.post(name: Notification.Name(self.NOTIFY_UPLOAD_COUNT), object: countMsg)
        //        }
        self.lock.unlock()
    }
    
    ///上传完成(不代表上传成功)
    /// - Parameter id:文件上传id
    static func finish(_ id: Int64){
        self.lock.lock()
        
        //从正在上传的任务中移除
        self.uploading.removeValue(forKey: id)
        if self.isCancel{//如果用户已经取消
            self.lock.unlock()
            return
        }
        self.lock.unlock()
        Task.detached{
            self.loopUpload()
        }
    }
    
    /// 删除一个文件
    /// - Parameter ids: 要删除的id列表
    static func delete(_ ids: [Int64]){
        if ids.isEmpty{
            return
        }
        
        //从数据库中删除数据
        FileUploaderDBUtil.delete(ids)
        ids.forEach{//取消下载
            self.cancel($0)
        }
    }
    
    /// 开始所有下载
    static func startAll() {
        FileUploaderDBUtil.startAll()
    }
    
    /// 取消上传
    /// - Parameter id: 文件id
    static func cancel(_ id: Int64) {
        self.lock.lock()
        self.uploading[id]?.cancel()
        self.lock.unlock()
    }
    
    ///取消所有任务
    static func cancelAll(){
        self.lock.lock()
        self.isCancel = true
        
        
        //将数据标记为暂停
        FileUploaderDBUtil.pauseAll()
        
        self.uploading.forEach{//取消正在上传的额任务
            $0.value.cancel()
        }
        self.lock.unlock()
    }
}

