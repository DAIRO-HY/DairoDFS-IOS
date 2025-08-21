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
    
    //由于PHAsset读取数据时单线程的,这里即使开启多线程上传,同时也只有一个上传任务,暂时无解
    private static let MAX_LIMIT = 1
    
    private static let lock = NSLock()
    
    //准备上传中的相册
    private static var uploadList = [URL]()
    
    //正在上传中的任务  文件url的MD5 => 上传任务
    private static var uploading = [String : FileUploader]()
    
    //当前上传总数
    private static var total = 0
    
    //是否取消
    private static var isCancel = false
    
    //开始上传
    static func upload(_ uploadList: [URL]){
        FileUploaderManager.lock.lock()
        self.isCancel = false
        FileUploaderManager.total = uploadList.count
        FileUploaderManager.uploadList = uploadList
        FileUploaderManager.lock.unlock()
        Task.detached{
            
            //启动上传
            FileUploaderManager.loopUpload()
        }
    }
    
    /// 循环上传
    static func loopUpload(){
        FileUploaderManager.lock.lock()
        for i in 0 ..< (FileUploaderManager.MAX_LIMIT - FileUploaderManager.uploading.count){
            if FileUploaderManager.uploadList.isEmpty{
                break
            }
            
            let url = FileUploaderManager.uploadList[0]
            
            //去除第一个元素
            let uploader = FileUploader(url)
            FileUploaderManager.uploading[url.path.md5] = uploader
            
            //移除第一个元素
            FileUploaderManager.uploadList.remove(at: 0)
            uploader.upload()
        }
        let countMsg = "进度:\(FileUploaderManager.total - FileUploaderManager.uploadList.count - FileUploaderManager.uploading.count + 1)/\(FileUploaderManager.total)"
        Task{@MainActor in
            NotificationCenter.default.post(name: Notification.Name(FileUploaderManager.NOTIFY_UPLOAD_COUNT), object: countMsg)
        }
        FileUploaderManager.lock.unlock()
    }
    
    ///上传完成(不代表上传成功)
    static func uploadFinish(_ urlMD5: String){
        FileUploaderManager.lock.lock()
        FileUploaderManager.uploading.removeValue(forKey: urlMD5)
        if FileUploaderManager.uploadList.isEmpty && FileUploaderManager.uploading.isEmpty{//全部上传完成
            FileUploaderManager.lock.unlock()
            Task{@MainActor in
                NotificationCenter.default.post(name: Notification.Name(FileUploaderManager.NOTIFY_UPLOAD_FINISH), object: nil)
            }
            return
        }
        if FileUploaderManager.isCancel{//如果用户已经取消
            FileUploaderManager.lock.unlock()
            return
        }
        FileUploaderManager.lock.unlock()
        Task.detached{
            FileUploaderManager.loopUpload()
        }
    }
    
    ///取消所有任务
    static func cancel(){
        FileUploaderManager.lock.lock()
        FileUploaderManager.isCancel = true
        
        //移除所有等待上传中的照片
        FileUploaderManager.uploadList.removeAll()
        for (k,v) in FileUploaderManager.uploading{//取消正在上传的额任务
            v.cancel()
        }
        FileUploaderManager.lock.unlock()
    }
}
