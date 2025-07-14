//
//  StreamUploader.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/07/12.
//
import Foundation
import Photos

class StreamUploader: NSObject,
//                        URLSessionTaskDelegate,
StreamDelegate,
URLSessionDataDelegate {
    
    //最大缓存量
    private let MAX_CHACHE_LIMIT = 1 * 1024 * 1024
    
    //缓存中间件
    private var bufferData = Data()
    
    //相册数据
    private let asset: PHAsset
    init(_ dasset: PHAsset) {
        self.asset = dasset
    }
    
    lazy var session: URLSession = URLSession(configuration: .default,
                                              delegate: self,
                                              delegateQueue: nil)
    
    func upload(to serverURL: String) {
        let url = URL(string: serverURL)!
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 10)
        request.httpMethod = "POST"
        let uploadTask = session.uploadTask(withStreamedRequest: request)
        uploadTask.resume()
        request.httpBodyStream = boundStreams.input
    }
    
    
    struct Streams {
        let input: InputStream
        let output: OutputStream
    }
    lazy var boundStreams: Streams = {
        var inputOrNil: InputStream? = nil
        var outputOrNil: OutputStream? = nil
        Stream.getBoundStreams(withBufferSize: 40960,
                               inputStream: &inputOrNil,
                               outputStream: &outputOrNil)
        guard let input = inputOrNil, let output = outputOrNil else {
            fatalError("On return of `getBoundStreams`, both `inputStream` and `outputStream` will contain non-nil streams.")
        }
        // configure and open output stream
        output.delegate = self
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
        if let error = error {
            print("上传失败: \(error)")
        } else {
            print("上传完成:\(Date())")
        }
    }
    
    
    private var canWrite = false
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        guard aStream == boundStreams.output else {
            return
        }
        if eventCode.contains(.hasSpaceAvailable) {
            
            //有缓存空间写入数据,不能单靠OutputStream缓存满了时阻塞线程,Apple官方声明,OutputStream缓存满了时阻塞并不可靠,有可能不阻塞,而返回写入数据0,如果此时持续写入,可能导致CPU空转
            canWrite = true
            print("-->canWrite = true")
        }
        if eventCode.contains(.errorOccurred) {
            // Close the streams and alert the user that the upload failed.
            //关闭流并提醒用户上传失败。
        }
    }
    
    func readPHAssetTask(){
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = false// 允许从iCloud下载
        
        // 读取资源数据并计算 MD5
        PHAssetResourceManager.default().requestData(for: PHAssetResource.assetResources(for: self.asset).first!, options: options, dataReceivedHandler: { data in
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
                    print("-->write zero")
                }
                if bytesWritten == -1{//可能是写入数据超时
                    print("-->write -1")
                }
                data.removeSubrange(0..<bytesWritten)
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
    
}
