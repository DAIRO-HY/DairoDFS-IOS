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
    
    //通知:上传完成通知
    static let NOTIFY_UPLOAD_FINISH = "NOTIFY_UPLOAD_FINISH"
    
    private static let MAX_LIMIT = 1
    
    private static let lock = NSLock()
    
    //准备上传中的相册
    private static var uploadList = [PHAsset]()
    
    //正在上传中的任务
    private static var uploading = [String : StreamUploader]()
    
    //当前上传总数
    private static var total = 0
    
    //开始上传
    static func upload(_ uploadList: [PHAsset]){
        
        PHAssetUploadManager.lock.lock()
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
            let uploader = StreamUploader(asset,nil)
            PHAssetUploadManager.uploading[asset.localIdentifier] = uploader
            
            //移除第一个元素
            PHAssetUploadManager.uploadList.remove(at: 0)
            uploader.upload()
        }
        let countMsg = "上传进度:\(PHAssetUploadManager.total - PHAssetUploadManager.uploadList.count - PHAssetUploadManager.uploading.count)/\(PHAssetUploadManager.total)"
        Task{@MainActor in
            NotificationCenter.default.post(name: Notification.Name(PHAssetUploadManager.NOTIFY_UPLOAD_COUNT), object: countMsg)
        }
        PHAssetUploadManager.lock.unlock()
    }
    
    ///上传完成
    static func uploadFinish(_ localIdentifier: String){
        PHAssetUploadManager.lock.lock()
        PHAssetUploadManager.uploading.removeValue(forKey: localIdentifier)
        PHAssetUploadManager.lock.unlock()
        PHAssetUploadManager.loopUpload()
    }
}
