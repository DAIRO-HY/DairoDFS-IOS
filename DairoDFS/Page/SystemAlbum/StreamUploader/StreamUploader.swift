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
//                        URLSessionTaskDelegate,
StreamDelegate,
URLSessionDataDelegate {
    
    //相册数据
    private let asset: PHAsset
    
    //相册数据
    private var md5: String?
    init(_ dasset: PHAsset, _ md5: String?) {
        self.asset = dasset
        self.md5 = md5
    }
    
    lazy var session: URLSession = URLSession(configuration: .default,
                                              delegate: self,
                                              delegateQueue: nil)
    
    ///上传
    func upload() {
        if self.md5 != nil{
            self.start()
        }else{
            self.computeMd5(self.start)
        }
    }
    
    
    ///开始上传
    private func start(){
        let serverURL = SettingShared.domainNotNull + "/app/file_upload/by_stream/" + self.md5!
        let url = URL(string: serverURL)!
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 10)
        request.httpMethod = "POST"
        let uploadTask = session.uploadTask(withStreamedRequest: request)
        uploadTask.resume()
        request.httpBodyStream = boundStreams.input
    }
    
    ///计算图片MD5
    /// - index 当前计算的下标
    private func computeMd5(_ callback: @escaping () -> Void) {
        // 确保是视频类型
        //        guard asset.mediaType == .video else {
        //            completion(nil)
        //            return
        //        }
        
        // 获取视频资源（注意有多个时可能需要更精确过滤）
        //        guard let resource = PHAssetResource.assetResources(for: asset).first(where: { $0.type == .video }) else {
        //            print("未找到视频资源")
        //            completion(nil)
        //            return
        //        }
        
        
        // 设置读取选项（可设置 isNetworkAccessAllowed 等）
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = false
        
        // 初始化 MD5 计算上下文
        var context = CC_MD5_CTX()
        CC_MD5_Init(&context)
        
        // 读取资源数据并计算 MD5
        PHAssetResourceManager.default().requestData(for: PHAssetResource.assetResources(for: self.asset).first!, options: options, dataReceivedHandler: { data in
            data.withUnsafeBytes { buffer in
                _ = CC_MD5_Update(&context, buffer.baseAddress, CC_LONG(data.count))
            }
        }, completionHandler: { error in
            if let error = error {
                print("读取失败: \(error)")
                //                completion(nil)
            } else {
                // 计算最终的 MD5 值
                var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
                CC_MD5_Final(&digest, &context)
                
                // 转换为十六进制字符串
                self.md5 = digest.map { String(format: "%02x", $0) }.joined()
                    callback()
            }
        })
    }
    
    
    struct Streams {
        let input: InputStream
        let output: OutputStream
    }
    lazy var boundStreams: Streams = {
        var inputOrNil: InputStream? = nil
        var outputOrNil: OutputStream? = nil
        Stream.getBoundStreams(withBufferSize: 10 * 1024 * 1024,
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
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        // 服务器返回的数据
        print("收到服务器响应数据: \(String(data: data, encoding: .utf8) ?? "")")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        //z最后一定要调用该函数,否则析构函数不会被调用
        session.invalidateAndCancel()
        if let error = error {
            if let requestId{
                PHAssetResourceManager.default().cancelDataRequest(requestId)
            }
            print("上传失败: \(error)")
        } else {
            print("上传完成:\(Date())")
        }
        Thread.sleep(forTimeInterval: 1)
        Task{@MainActor in
            NotificationCenter.default.post(name: Notification.Name(PHAssetUploadManager.NOTIFY_UPLOAD_FINISH), object: [self.asset.localIdentifier, error == nil ? "上传完成":"上传失败"])
        }
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
    
    var requestId :PHAssetResourceDataRequestID?
    func readPHAssetTask(){
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = false// 允许从iCloud下载
        
        // 读取资源数据并计算 MD5
        self.requestId = PHAssetResourceManager.default().requestData(for: PHAssetResource.assetResources(for: self.asset).first!, options: options, dataReceivedHandler: { data in
            //            self.semaphore.wait()
            //            self.dataLock.lock()
            //            self.data.append(data)
            //            self.dataLock.unlock()
            //            while self.data.count > 10 * 1024 * 1024{//如果缓存中的数据超过了指定大小,则暂停读取数据
            //                self.semaphore.wait()
            //            }
            
            print("-->count:\(data.count)")
            
            
            var data = data
            while data.count > 0{
                let bytesWritten: Int = data.withUnsafeBytes() { (buffer: UnsafePointer<UInt8>) in
                    //                    self.canWrite = false
                    
                    print("-->time:\(Date())")
                    
                    //实际验证:如果缓存满了,这里会线程阻塞
                    return self.boundStreams.output.write(buffer, maxLength: data.count)
                }
                print("-->本次\(Date()):写入:\(bytesWritten.fileSize)")
                if bytesWritten == 0{
                    print("-->error:write zero")
                    Toast.show("-->error:write zero")
                    Thread.sleep(forTimeInterval: 1.0)
                }
                if bytesWritten == -1{//可能是写入数据超时
                    print("-->error:write -1")
                    PHAssetResourceManager.default().cancelDataRequest(self.requestId!)
                    break
                }
                if bytesWritten > 0{
                    data.removeSubrange(0..<bytesWritten)
                }
            }
            print("-->本次写入完毕")
            //            let bytesWritten: Int = data.withUnsafeBytes() { (buffer: UnsafePointer<UInt8>) in
            //                self.canWrite = false
            //                return self.boundStreams.output.write(buffer, maxLength: data.count)
            //            }
            //            if bytesWritten < data.count {
            //                // Handle writing less data than expected.
            //                // 处理比预期写入更少的数据。
            //                print("-->处理比预期写入更少的数据。")
            //            }
            
            //            _ = data.withUnsafeBytes {
            //                self.outputStream.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: data.count)
            //            }
        }, completionHandler: { error in
            if let error = error {
                print("读取失败: \(error)")
            } else {
                self.boundStreams.output.close()
                print("读取完毕")
            }
        })
    }
    deinit{
        print("-->deinit:StreamUploader")
    }
}
