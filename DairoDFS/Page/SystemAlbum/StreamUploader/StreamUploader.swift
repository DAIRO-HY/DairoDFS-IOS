//
//  StreamUploader.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/07/12.
//
import Foundation
import Photos
import CommonCrypto
import DairoUI_IOS

/// 上传模式
enum UploadMode{
    
    /// 文件的方式上传
    case file
    
    /// 相册的方式上传
    case album
}

class StreamUploader: NSObject,
                      URLSessionTaskDelegate,
                      StreamDelegate,
                      URLSessionDataDelegate {
    
    //相册数据
    private let asset: PHAsset
    
    //相册文件唯一识别id
    private let identifier: String
    
    //文件大小
    private lazy var fileSize: Int64 = self.getFileSize()
    
    //断点续传偏移长度
    private  var offset: Int64 = 0
    
    //相册数据
    private var md5: String?
    
    //当前请求的apiHttp
    private var apiHttp: ApiHttpBase?
    
    //相册数据请求ID
    private var assetDataRequestId: PHAssetResourceDataRequestID?
    
    //是否取消
    private var isCancel = false
    
    //是否仅检查是否上传
    private var isOnlyCheck = false
    
    //当前上传任务,用于取消
    private var task: URLSessionTask?
    
    ///记录已经读取了的数据大小
    private var readedDataSize: Int64 = 0
    
    /// 上传模式
    private let uploadMode: UploadMode
    
    /// 这是一张实况照片
    private let isLivePhoto: Bool
    
    /// 实况照片头部信息
    private let liveHeadData: Data
    
    private lazy var session: URLSession = URLSession(configuration: .default,
                                                      delegate: self,
                                                      delegateQueue: nil)
    
    /// 要上传的资源文件
    private let resources: [PHAssetResource]
    
    init(_ asset: PHAsset, _ isOnlyCheck: Bool, mode: UploadMode) {
        self.asset = asset
        self.isOnlyCheck = isOnlyCheck
        self.uploadMode = mode
        self.identifier = asset.localIdentifier
        self.isLivePhoto = asset.mediaSubtypes.contains(.photoLive)
        
        let resources = PHAssetResource.assetResources(for: self.asset)
        if self.isLivePhoto{//实况照片时
            self.resources = resources.filter{$0.type == .photo || $0.type == .pairedVideo}
            
            //实况照片头部追加信息如下
            //图片格式|文件大小|视频格式-
            let photoHead = (self.resources[0].originalFilename as NSString).pathExtension.lowercased()
            + "|\(self.resources[0].value(forKey: "fileSize")!)|"
            + (self.resources[1].originalFilename as NSString).pathExtension.lowercased()
            + "|\(self.resources[1].value(forKey: "fileSize")!)-"
            self.liveHeadData = Data(photoHead.utf8)
        } else {
            self.resources = resources.filter{$0.type == .photo}
            self.liveHeadData = Data()
        }
    }
    
    /// 文件上传保存路径
    private var dfsPath: String{
        let ext: String
        if self.isLivePhoto{
            ext = "dlive"
        } else {
            let originalFilename = PHAssetResource.assetResources(for: self.asset).first!.originalFilename
            
            //得到文件后缀
            ext = (originalFilename as NSString).pathExtension.lowercased()
        }
        
        let time = Int64(Date().timeIntervalSince1970 * 1_000_000)
        switch self.uploadMode {
        case .file://文件上传时,上传到当前打开的文件夹下
            return SettingShared.lastOpenFolder + "/\(time)." + ext
        case .album://相册上传时上传到固定文件夹下
            return "/相册/\(time)." + ext
        }
    }
    
    /// 是否一次性读取所有数据标记
    private var isReadAllFlag: Bool{
        return self.fileSize < 100 * 1024 * 1024 || self.isLivePhoto
        //        return false
    }
    
    ///获取文件大小
    private func getFileSize() -> Int64{
        return self.resources.reduce(0){
            $0 + Int64($1.value(forKey: "fileSize") as! CLong)
        } + Int64(self.liveHeadData.count)
    }
    
    ///上传
    func upload() {
        Task.detached{//这里一定要开启异步任务,否则可能导致死锁
            self.progress("文件校验中")
            switch self.uploadMode {
            case .file://文件上传时
                self.computeMd5(false, self.uploadByMd5_step1)
            case .album:
                self.computeMd5(false, self.checkExists)
            }
        }
    }
    
    ///计算图文件MD5
    /// - isIcloudAllowed 是否允许从iCloud下载
    /// - callback 计算完成之后的回调函数
    private func computeMd5(_ isIcloudAllowed: Bool, _ callback: @escaping () -> Void) {
        //        if self.isLivePhoto {
        //            // 实况照片
        //            self.finish("实况照片暂不支持")
        //            return
        //        }
        if let md5 = PHAssetUploadManager.getMD5(self.identifier){
            self.md5 = md5
            callback()
            return
        }
        if self.isReadAllFlag{// 如果文件较小,则一次性全部读取
            self.readAll{
                
                //得到文件的md5
                self.md5 = self.allData.md5
                PHAssetUploadManager.setMD5(self.identifier, self.md5!)
                callback()
            }
            return
        }
        
        // 设置读取选项（可设置 isNetworkAccessAllowed 等）
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = isIcloudAllowed
        
        // 初始化 MD5 计算上下文
        var context = CC_MD5_CTX()
        CC_MD5_Init(&context)
        
        // 读取资源数据并计算 MD5
        self.assetDataRequestId = PHAssetResourceManager.default().requestData(for: self.resources[0], options: options, dataReceivedHandler: { data in
            data.withUnsafeBytes { buffer in
                _ = CC_MD5_Update(&context, buffer.baseAddress, CC_LONG(data.count))
            }
        }, completionHandler: { error in
            if let error = error as NSError? {
                if error.domain == PHPhotosErrorDomain && error.code == 3164{//文件在iCloud中
                    if isIcloudAllowed{
                        self.finish("从iCloud同步失败")
                        return
                    }
                    self.progress("从iCloud下载中")
                    self.computeMd5(true, callback)
                    return
                }
                if error.code == NSUserCancelledError {//请求被手动取消
                    self.finish("已取消")
                    return
                }
                self.finish("读取失败: \(error)")
            } else {
                // 计算最终的 MD5 值
                var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
                CC_MD5_Final(&digest, &context)
                
                // 转换为十六进制字符串
                self.md5 = digest.map { String(format: "%02x", $0) }.joined()
                PHAssetUploadManager.setMD5(self.identifier, self.md5!)
                callback()
            }
        })
    }
    
    /// 所有数据
    private var allData = Data()
    
    //    /// 一次性读取所有数据
    //    private func readAll(_ isIcloudAllowed: Bool = false, _ callback: @escaping () -> Void){
    //        if self.allData != nil{
    //            callback()
    //            return
    //        }
    //
    //        //用来存储所有数据
    //        var allData = Data()
    //
    //        // 设置读取选项（可设置 isNetworkAccessAllowed 等）
    //        let options = PHAssetResourceRequestOptions()
    //        options.isNetworkAccessAllowed = isIcloudAllowed
    //        if self.isLivePhoto{//如果这是一张实况照片
    //            print(PHAssetResource.assetResources(for: self.asset))
    ////            let readLivePhotoDataFunc: (_ index: Int)->() = { index in
    ////                self.assetDataRequestId = PHAssetResourceManager.default().requestData(for: PHAssetResource.assetResources(for: self.asset).first!, options: options, dataReceivedHandler: { data in
    ////                    allData.append(contentsOf: data)
    ////                }, completionHandler: { error in
    ////                    if let error = error as NSError? {
    ////                        if error.domain == PHPhotosErrorDomain && error.code == 3164{//文件在iCloud中
    ////                            if isIcloudAllowed{
    ////                                self.finish("从iCloud同步失败")
    ////                                return
    ////                            }
    ////                            self.progress("从iCloud下载中")
    ////                            self.readAll(true, callback)
    ////                            return
    ////                        }
    ////                        if error.code == NSUserCancelledError {//请求被手动取消
    ////                            self.finish("已取消")
    ////                            return
    ////                        }
    ////                        self.finish("读取失败: \(error)")
    ////                    } else {
    ////                        self.allData = allData
    ////                        callback()
    //////                        readLivePhotoDataFunc(2)
    ////                    }
    ////                })
    ////            }
    ////            readLivePhotoDataFunc(1)
    //            return
    //        }
    //
    //        // 读取资源数据并计算 MD5
    //        self.assetDataRequestId = PHAssetResourceManager.default().requestData(for: PHAssetResource.assetResources(for: self.asset).first!, options: options, dataReceivedHandler: { data in
    //            allData.append(contentsOf: data)
    //        }, completionHandler: { error in
    //            if let error = error as NSError? {
    //                if error.domain == PHPhotosErrorDomain && error.code == 3164{//文件在iCloud中
    //                    if isIcloudAllowed{
    //                        self.finish("从iCloud同步失败")
    //                        return
    //                    }
    //                    self.progress("从iCloud下载中")
    //                    self.readAll(true, callback)
    //                    return
    //                }
    //                if error.code == NSUserCancelledError {//请求被手动取消
    //                    self.finish("已取消")
    //                    return
    //                }
    //                self.finish("读取失败: \(error)")
    //            } else {
    //                self.allData = allData
    //                callback()
    //            }
    //        })
    //    }
    
    private func readAll(_ index: Int = 0, _ isIcloudAllowed: Bool = false, _ callback: @escaping () -> Void){
        if index == 0 && !self.allData.isEmpty{//如果文件已经全部读取完成
            callback()
            return
        }
        //        let resource: PHAssetResource
        //        if self.isLivePhoto{//如果这是实况照片
        //            if index == 1{
        //                resource = PHAssetResource.assetResources(for: self.asset).first{$0.type == .photo}!
        //            } else {
        //                resource = PHAssetResource.assetResources(for: self.asset).first{$0.type == .pairedVideo}!
        //            }
        //        } else {
        //            resource = PHAssetResource.assetResources(for: self.asset).first!
        //        }
        
        // 设置读取选项（可设置 isNetworkAccessAllowed 等）
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = isIcloudAllowed
        self.assetDataRequestId = PHAssetResourceManager.default().requestData(for: self.resources[index], options: options, dataReceivedHandler: { data in
            self.allData.append(contentsOf: data)
        }, completionHandler: { error in
            if let error = error as NSError? {
                if error.domain == PHPhotosErrorDomain && error.code == 3164{//文件在iCloud中
                    if isIcloudAllowed{
                        self.finish("从iCloud同步失败")
                        return
                    }
                    self.progress("从iCloud下载中")
                    self.readAll(index, true, callback)
                    return
                }
                if error.code == NSUserCancelledError {//请求被手动取消
                    self.finish("已取消")
                    return
                }
                self.finish("读取失败: \(error)")
                return
            }
            if self.isLivePhoto && index == 0{//实况照片时,继续获取实况照片的视频部分
                self.readAll(1, isIcloudAllowed, callback)
                return
            }
            if self.isLivePhoto{//实况照片时,前数据头部添加信息
                self.allData.insert(contentsOf: self.liveHeadData, at: 0)
            }
            callback()
        })
    }
    
    ///检查文件是否已经上传
    private func checkExists(){
        self.progress("校验上传状态")
        self.apiHttp = FileUploadApi.checkExistsByMd5(md5: self.md5!).hide()
            .error{
                self.finish("失败:\($0)")
            }.fail{
                self.finish("失败:\($0.msg)")
            }.post {
                if $0{//文件已经上传
                    self.finish("上传完成")
                    return
                }
                if self.isOnlyCheck{//如果仅仅是检查有没有上传
                    self.finish("未上传")
                    return
                }
                self.getUploadedSize()
            }
    }
    
    
    ///第一步直接通过MD5上传
    private func uploadByMd5_step1(){
        self.progress("服务端处理中")
        self.apiHttp = FileUploadApi.byMd5(md5: self.md5!, path: self.dfsPath, contentType: "").hide()
            .error{
                self.finish("失败:\($0)")
            }.fail{
                if $0.code == 1004{//md5文件不存在,则开始上传流
                    self.checkReadDataType()
                    return
                }
                self.finish("失败:\($0.msg)")
            }
            .post {
                self.finish("上传完成")
            }
    }
    
    //获取已经上传文件大小
    private func getUploadedSize(){
        self.progress("校验断点续传")
        self.apiHttp = FileUploadApi.getUploadedSize(md5: self.md5!).hide()
            .error{
                self.finish("失败:\($0)")
            }.fail{
                self.finish("失败:\($0.msg)")
            }.post{
                self.offset = $0
                if $0 == self.fileSize{//文件已经上传完成
                    self.uploadByMd5()
                }else{
                    self.checkReadDataType()
                }
            }
    }
    
    /// 检查读取文件的方式
    private func checkReadDataType(){
        if self.isReadAllFlag{// 一次性全部读取
            self.readAll{
                self.uploadStream()
            }
        } else {
            self.uploadStream()
        }
    }
    
    ///开始上传
    private func uploadStream(){
        self.progress("准备上传")
        let serverURL = SettingShared.domainNotNull + "/app/file_upload/by_stream/" + self.md5! + "?_token=" + SettingShared.token
        let url = URL(string: serverURL)!
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 60)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        //要监听上传进度,这个参数必须传
        request.setValue("\(self.fileSize - self.offset)", forHTTPHeaderField: "Content-Length")
        let uploadTask = self.session.uploadTask(withStreamedRequest: request)
        uploadTask.resume()
        self.task = uploadTask
        request.httpBodyStream = boundStreams.input
    }
    
    ///通过MD5上传
    private func uploadByMd5(){
        self.progress("服务端处理中")
        self.apiHttp = FileUploadApi.byMd5(md5: self.md5!, path: self.dfsPath, contentType: "").hide()
            .error{
                self.finish("失败:\($0)")
            }.fail{
                self.finish("失败:\($0.msg)")
            }
            .post {
                self.finish("上传完成")
            }
    }
    
    
    struct Streams {
        let input: InputStream
        let output: OutputStream
    }
    lazy var boundStreams: Streams = {
        var inputOrNil: InputStream? = nil
        var outputOrNil: OutputStream? = nil
        Stream.getBoundStreams(
            withBufferSize: 10 * 1024 * 1024,
            inputStream: &inputOrNil,
            outputStream: &outputOrNil)
        guard let input = inputOrNil, let output = outputOrNil else {
            fatalError("On return of `getBoundStreams`, both `inputStream` and `outputStream` will contain non-nil streams.")
        }
        // configure and open output stream
        //        output.delegate = self
        output.schedule(in: .current, forMode: .default)
        output.open()
        return Streams(input: input, output: output)
    }()
    
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        completionHandler(boundStreams.input)
        self.readPHAssetTask()
    }
    
    private func readPHAssetTask(){
        if !self.allData.isEmpty{//如果数据已经全部读取完毕
            self.write(self.allData)
            self.boundStreams.output.close()
            return
        }
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = false// 允许从iCloud下载
        
        // 读取资源数据并上传
        // 这里是单线程的,即使开启多线程读取数据,同时也只有一个任务在读,暂时还不知道解决方案
        self.assetDataRequestId = PHAssetResourceManager.default().requestData(for: self.resources[0], options: options, dataReceivedHandler: { data in
            self.write(data)
        }, completionHandler: { error in
            if let error = error as NSError? {
                if error.code == NSUserCancelledError {//请求被手动取消
                    self.finish("已取消")
                    return
                }
                self.finish("读取失败: \(error)")
            } else {
                self.boundStreams.output.close()
            }
        })
    }
    
    ///上传进度监听
    /// - totalBytesSent 已上传大小
    /// - totalBytesExpectedToSend 文件总大小,依旧是上传前配置的content-leng值
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        
        //通知上传进度
        let progress = (totalBytesSent + self.offset).fileSize + "/" +  (totalBytesExpectedToSend + self.offset).fileSize
        self.progress(progress)
    }
    
    //文件上传返回数据
    private var resBody:String?
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        // 服务器返回的数据
        self.resBody = (String(data: data, encoding: .utf8))
        //        print("收到服务器响应数据: \(String(data: data, encoding: .utf8) ?? "")")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.task = nil
        
        //z最后一定要调用该函数,否则析构函数不会被调用
        session.invalidateAndCancel()
        if let assetDataRequestId{
            PHAssetResourceManager.default().cancelDataRequest(assetDataRequestId)
        }
        if let response = task.response as? HTTPURLResponse{
            if response.statusCode != 200{
                self.finish("失败:\( self.resBody ?? "")")
                return
            }
        }
        if let error = error {
            self.finish("失败:\(error)")
            return
        }
        self.uploadByMd5()
    }
    
    
    //    private var canWrite = false
    //
    //    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
    //        guard aStream == boundStreams.output else {
    //            return
    //        }
    //        if eventCode.contains(.hasSpaceAvailable) {
    //
    //            //有缓存空间写入数据,不能单靠OutputStream缓存满了时阻塞线程,Apple官方声明,OutputStream缓存满了时阻塞并不可靠,有可能不阻塞,而返回写入数据0,如果此时持续写入,可能导致CPU空转
    //            canWrite = true
    //            print("-->canWrite = true")
    //        }
    //        if eventCode.contains(.errorOccurred) {
    //            // Close the streams and alert the user that the upload failed.
    //            //关闭流并提醒用户上传失败。
    //        }
    //    }
    
    /// 一次性写入所有数据
    private func write(_ data: Data) {
        
        //当前读取到的数据大小
        let currentSize = Int64(data.count)
        var data = data
        if self.readedDataSize + currentSize <= self.offset{//跳过指定偏移大小,这部分数据可能已经被上传
            data = Data()
        } else if self.readedDataSize < self.offset{//本次只需要部分数据
            
            //移除多余的数据
            data.removeSubrange(0 ..< Int(self.offset - self.readedDataSize))
        } else {
            //不做任何处理
        }
        self.readedDataSize += currentSize
        if data.isEmpty{//本次不需要上传数据
            return
        }
        
        data.withUnsafeBytes() { (buffer: UnsafePointer<UInt8>) in
            var totalWritten = 0
            var ptr = buffer
            var remaining = data.count
            while remaining > 0 {
                
                //这里不保证一次性写入所有数据,所以需要循环写入,知道数据全部写入
                let written = self.boundStreams.output.write(ptr, maxLength: remaining)
                //                if written <= 0 {
                //                    // 出错或者流关闭
                //                    return written
                //                }
                if written == 0{
                    // 出错或者流关闭
                    Toast.show("-->error:write zero")
                    PHAssetResourceManager.default().cancelDataRequest(self.assetDataRequestId!)
                    break
                }
                if written == -1{//可能是写入数据超时,也可能服务器端取消接收文件
#if DEBUG
                    print("-->error:write -1")
#endif
                    PHAssetResourceManager.default().cancelDataRequest(self.assetDataRequestId!)
                    break
                }
                totalWritten += written
                
                //把指针 ptr 向后移动 written 个字节
                ptr += written
                remaining -= written
            }
            return totalWritten
            
        }
    }
    
    ///上传完成执行函数
    private func finish(_ msg: String){
        
        //一定要将apiHttp设置为nil,否则内存不会被回收
        self.apiHttp = nil
        PHAssetUploadManager.uploadFinish(self.identifier)
        Task{@MainActor in
            NotificationCenter.default.post(name: Notification.Name(PHAssetUploadManager.NOTIFY_UPLOAD_ITEM_FINISH), object: [self.identifier, msg])
        }
    }
    
    ///上传进度执行函数
    private func progress(_ msg: String){
        Task{@MainActor in
            NotificationCenter.default.post(name: Notification.Name(PHAssetUploadManager.NOTIFY_UPLOAD_PROGRESS), object: [self.identifier, msg])
        }
    }
    
    ///取消
    func cancel(){
        if let assetDataRequestId{
            PHAssetResourceManager.default().cancelDataRequest(assetDataRequestId)
        }
        
        //手动取消正在上传的task,否则服务端无法知道客户端结束,造成阻塞直到超时
        self.task?.cancel()
        if let apiHttp{
            apiHttp.cancel()
        }
    }
    deinit{
        print("-->deinit:StreamUploader")
    }
}
