//
//  PHAssetUploadManager.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/07/16.
//

import Photos

class PHAssetUploadManager{
    
    //通知:上传数量发生变化
    static let NOTIFY_UPLOAD_COUNT = "NOTIFY_UPLOAD_COUNT"
    
    //通知:上传进度通知
    static let NOTIFY_UPLOAD_PROGRESS = "NOTIFY_UPLOAD_PROGRESS"
    
    //通知:单个文件上传完成通知
    static let NOTIFY_UPLOAD_ITEM_FINISH = "NOTIFY_UPLOAD_ITEM_FINISH"
    
    //通知:全部文件上传完成通知
    static let NOTIFY_UPLOAD_FINISH = "NOTIFY_UPLOAD_FINISH"
    
    //相册文件唯一ID对应的MD5
    static var md5Map: Dictionary<String,String> = [String:String]()
    
    //已经上传的文件ID
    static var uploadedSet = Set<String>()
    
    //文件信息获取锁
    static let assetLock = NSLock()
    
    private static let MAX_LIMIT = 5
    
    private static let lock = NSLock()
    
    //准备上传中的相册
    private static var uploadList = [PHAsset]()
    
    //正在上传中的任务
    private static var uploading = [String : StreamUploader]()
    
    //当前上传总数
    private static var total = 0
    
    //是否取消
    private static var isCancel = false
    
    //是否仅检查是否上传
    private static var isOnlyCheck = false
    
    //开始上传
    static func upload(_ uploadList: [PHAsset], _ isOnlyCheck: Bool){
        PHAssetUploadManager.isOnlyCheck = isOnlyCheck
        PHAssetUploadManager.lock.lock()
        self.isCancel = false
        PHAssetUploadManager.total = uploadList.count
        PHAssetUploadManager.uploadList = uploadList
        PHAssetUploadManager.lock.unlock()
        Task.detached{
            
            //启动上传
            PHAssetUploadManager.loopUpload()
        }
    }
    
    /// 循环上传
    static func loopUpload(){
        PHAssetUploadManager.lock.lock()
        for i in 0 ..< (PHAssetUploadManager.MAX_LIMIT - PHAssetUploadManager.uploading.count){
            if PHAssetUploadManager.uploadList.isEmpty{
                break
            }
            
            let asset = PHAssetUploadManager.uploadList[0]
            
            //去除第一个元素
            let uploader = StreamUploader(asset, PHAssetUploadManager.isOnlyCheck)
            PHAssetUploadManager.uploading[asset.localIdentifier] = uploader
            
            //移除第一个元素
            PHAssetUploadManager.uploadList.remove(at: 0)
            uploader.upload()
        }
        let countMsg = "进度:\(PHAssetUploadManager.total - PHAssetUploadManager.uploadList.count - PHAssetUploadManager.uploading.count + 1)/\(PHAssetUploadManager.total)"
        Task{@MainActor in
            NotificationCenter.default.post(name: Notification.Name(PHAssetUploadManager.NOTIFY_UPLOAD_COUNT), object: countMsg)
        }
        PHAssetUploadManager.lock.unlock()
    }
    
    ///上传完成
    static func uploadFinish(_ identifier: String){
        PHAssetUploadManager.lock.lock()
        PHAssetUploadManager.uploading.removeValue(forKey: identifier)
        if PHAssetUploadManager.uploadList.isEmpty && PHAssetUploadManager.uploading.isEmpty{//全部上传完成
            PHAssetUploadManager.lock.unlock()
            Task{@MainActor in
                NotificationCenter.default.post(name: Notification.Name(PHAssetUploadManager.NOTIFY_UPLOAD_FINISH), object: nil)
            }
            return
        }
        if PHAssetUploadManager.isCancel{//如果用户已经取消
            PHAssetUploadManager.lock.unlock()
            return
        }
        PHAssetUploadManager.lock.unlock()
        Task.detached{
            PHAssetUploadManager.loopUpload()
        }
    }
    
    ///获取相册文件的md5
    static func getMD5(_ identifier: String) -> String?{
        PHAssetUploadManager.assetLock.lock()
        let md5 = PHAssetUploadManager.md5Map[identifier]
        PHAssetUploadManager.assetLock.unlock()
        return md5
    }
    
    ///设置相册文件的md5
    static func setMD5(_ identifier: String,_ md5: String){
        PHAssetUploadManager.assetLock.lock()
        let md5 = PHAssetUploadManager.md5Map[identifier] = md5
        PHAssetUploadManager.assetLock.unlock()
    }
    
    ///获取相册文件是否已经上传
    static func getMD5111(_ identifier: String) -> String?{
        PHAssetUploadManager.assetLock.lock()
        let md5 = PHAssetUploadManager.md5Map[identifier]
        PHAssetUploadManager.assetLock.unlock()
        return md5
    }
    
    ///设置相册文件已经存在
    static func setMD5111(_ identifier: String,_ md5: String){
        PHAssetUploadManager.assetLock.lock()
        let md5 = PHAssetUploadManager.md5Map[identifier] = md5
        PHAssetUploadManager.assetLock.unlock()
    }
    
    ///取消所有任务
    static func cancel(){
        PHAssetUploadManager.lock.lock()
        PHAssetUploadManager.isCancel = true
        
        //移除所有等待上传中的照片
        PHAssetUploadManager.uploadList.removeAll()
        for (k,v) in PHAssetUploadManager.uploading{//取消正在上传的额任务
            v.cancel()
        }
        PHAssetUploadManager.lock.unlock()
    }
}
