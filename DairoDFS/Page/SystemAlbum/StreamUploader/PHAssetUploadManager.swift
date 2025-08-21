//
//  PHAssetUploadManager.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/07/16.
//

import Photos
import DairoUI_IOS

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
    static var md5Map = [String:String]()
    
    //已经上传的文件ID
    static var uploadedSet = Set<String>()
    
    //文件信息获取锁
    static let assetLock = NSLock()
    
    //由于PHAsset读取数据时单线程的,这里即使开启多线程上传,同时也只有一个上传任务,暂时无解
    private static let MAX_LIMIT = 1
    
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
        self.assetLock.lock()
        if self.md5Map.isEmpty{
            if let md5Map = LocalObjectUtil.read([String:String].self, "album-md5"){
                self.md5Map = md5Map
            }
        }
        PHAssetUploadManager.assetLock.unlock()
        
        
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
    
    
    /// @TODO: 该函数不应再页面调用,若页面被关闭了,这个函数无法被调用,导致正在上传中的数量不能更新
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
    
    ///保存计算好的相册文件md5
    static func saveAlbumMd5(_ identifierList: [String]){
        PHAssetUploadManager.assetLock.lock()
        
        //相册文件唯一ID对应的MD5
        var md5Map: Dictionary<String,String> = [String:String]()
        identifierList.forEach{ item in
            if self.md5Map.contains{$0.key == item}{//如果该id存在
                md5Map[item] = self.md5Map[item]
            }
        }
        
        //将已经计算好的相册文件md5保存到本地
        LocalObjectUtil.write(md5Map, "album-md5")
        PHAssetUploadManager.assetLock.unlock()
    }
}
