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
    
    //正在上传中的任务  文件url的MD5 => 上传任务
    private static var uploading = [String : FileUploader]()
    
    //当前上传总数
    private static var total = 0
    
    //是否取消
    private static var isCancel = false
    
    //开始上传
    static func upload(_ list: [FileUploaderDto]){
        self.lock.lock()
        try? UploaderDBUtil.add(list)
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
            guard let dto = UploaderDBUtil.selectOneForNeedUpload() else{//如果没有需要上传的文件
                break
            }
            if self.uploading.count >= UploaderConfig.maxUploadingCount {//当前下载并发数已到上限
                break
            }
            
            //将文件标记为正在下载中
            UploaderDBUtil.updateState(dto.id, 1)
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
    static func uploadFinish(_ dto: FileUploaderDto, _ err: Error?){
        self.lock.lock()
        
        if let err = err as? UploaderError{//如果发生错误
        if case let .error(msg) = err {
            UploaderDBUtil.updateState(dto.id, 3, msg)
        }
    } else if let err {
        if let err = err as? URLError, err.code == .cancelled {//用户主动取消了请求,标记为暂停状态
            UploaderDBUtil.updateState(dto.id, 2)
        } else {
            UploaderDBUtil.updateState(dto.id, 3, err.localizedDescription)
        }
    } else {//如果没有发生错误,则更新下载状态为下载完成
        UploaderDBUtil.updateState(dto.id, 10)
    }
        
        //从正在上传的任务中移除
        self.uploading.removeValue(forKey: dto.id)
        if self.isCancel{//如果用户已经取消
            self.lock.unlock()
            return
        }
        self.lock.unlock()
        Task.detached{
            self.loopUpload()
        }
    }
    
    ///取消所有任务
    static func cancel(){
        self.lock.lock()
        self.isCancel = true
        
        
        //将数据标记为暂停
        UploaderDBUtil.pauseAll()
        
        self.uploading.forEach{//取消正在上传的额任务
            $0.value.cancel()
        }
        self.lock.unlock()
    }
}

