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
    
    init(_ dasset: PHAsset, _ isOnlyCheck: Bool) {
        self.asset = dasset
        self.isOnlyCheck = isOnlyCheck
        self.identifier = dasset.localIdentifier
    }
    
    lazy var session: URLSession = URLSession(configuration: .default,
                                              delegate: self,
                                              delegateQueue: nil)
    
    ///上传
    func upload() {
        self.computeMd5(false, self.checkExists)
    }
    
    ///计算图文件MD5
    /// - isIcloudAllowed 是否允许从iCloud下载
    /// - callback 计算完成之后的回调函数
    private func computeMd5(_ isIcloudAllowed: Bool, _ callback: @escaping () -> Void) {
        if self.asset.mediaSubtypes.contains(.photoLive) {
            // 实况照片
            self.finish("实况照片暂不支持")
            return
        }
        self.progress("文件校验中")
        if let md5 = PHAssetUploadManager.getMD5(self.identifier){
            self.md5 = md5
            callback()
            return
        }
        
        // 设置读取选项（可设置 isNetworkAccessAllowed 等）
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = isIcloudAllowed
        
        // 初始化 MD5 计算上下文
        var context = CC_MD5_CTX()
        CC_MD5_Init(&context)
        
        // 读取资源数据并计算 MD5
        self.assetDataRequestId = PHAssetResourceManager.default().requestData(for: PHAssetResource.assetResources(for: self.asset).first!, options: options, dataReceivedHandler: { data in
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
                    self.uploadStream()
                }
            }
    }
    
    ///开始上传
    private func uploadStream(){
        self.progress("准备上传")
        let serverURL = SettingShared.domainNotNull + "/app/file_upload/by_stream/" + self.md5!
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
        let originalFilename = PHAssetResource.assetResources(for: self.asset).first!.originalFilename
        
        //得到文件后缀
        let ext = (originalFilename as NSString).pathExtension.lowercased()
        self.progress("服务端处理中")
        
        let time = Int64(Date().timeIntervalSince1970 * 1_000_000)
        self.apiHttp = FileUploadApi.byMd5(md5: self.md5!, path: "/相册/\(time)." + ext, contentType: "").hide()
            .error{
                self.finish("失败:\($0)")
            }.fail{
                self.finish("失败:\($0.msg)")
            }
            .post {
                self.finish("上传完成")
            }
    }
    
    
    ///获取文件大小
    private func getFileSize() -> Int64{
        let resources = PHAssetResource.assetResources(for: self.asset)
        guard let resource = resources.first else {
            return -1
        }
        
        if let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong {//优先从属性中获取,不过这种方式并不是官方推介的,所有有else预备方案
            return Int64(unsignedInt64)
        } else {
            return -1
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
    
    func readPHAssetTask(){
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = false// 允许从iCloud下载
        
        // 读取资源数据并上传
        // 这里是单线程的,即使开启多线程读取数据,同时也只有一个任务在读,暂时还不知道解决方案
        self.assetDataRequestId = PHAssetResourceManager.default().requestData(for: PHAssetResource.assetResources(for: self.asset).first!, options: options, dataReceivedHandler: { data in
            
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
            while data.count > 0{
                let bytesWritten: Int = data.withUnsafeBytes() { (buffer: UnsafePointer<UInt8>) in
                    //                    self.canWrite = false
                    
                    //                    print("-->time:\(Date())")
                    
                    //实际验证:如果缓存满了,这里会线程阻塞
                    return self.boundStreams.output.write(buffer, maxLength: data.count)
                }
                //                print("-->本次\(Date()):写入:\(bytesWritten.fileSize)")
                if bytesWritten == 0{
                    Toast.show("-->error:write zero")
                    Thread.sleep(forTimeInterval: 1.0)
                }
                if bytesWritten == -1{//可能是写入数据超时,也可能服务器端取消接收文件
                    print("-->error:write -1")
                    PHAssetResourceManager.default().cancelDataRequest(self.assetDataRequestId!)
                    break
                }
                if bytesWritten > 0{
                    data.removeSubrange(0..<bytesWritten)
                }
            }
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
