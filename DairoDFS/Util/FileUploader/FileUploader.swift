//
//  StreamUploader.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/07/12.
//
import Foundation
import CommonCrypto
import DairoUI_IOS

///文件上传失败错误
public enum UploaderError: Error {
    case error(_ msg: String)
}

class FileUploader: NSObject,
                    URLSessionTaskDelegate,
                    StreamDelegate,
                    URLSessionDataDelegate {
    
    //要上传的文件url
    private let bean: FileUploaderDto
    
    //断点续传偏移长度
    private  var offset: Int64 = 0
    
    //文件的MD5
    private var fileMD5: String?
    
    //当前请求的apiHttp
    private var apiHttp: ApiHttpBase?
    
    //是否取消
    private var isCancel = false
    
    //当前上传任务,用于取消
    private var task: URLSessionTask?
    
    ///记录已经读取了的数据大小
    private var readedDataSize: Int64 = 0
    
    /// 上回统计的上传大小,用来计算网速
    private var preTotalBytesSent: Int64 = 0
    
    /// 最后一次记录的上传时间
    private var lastSendTime = Date()
    
    lazy var session: URLSession = URLSession(configuration: .default,
                                              delegate: self,
                                              delegateQueue: nil)
    
    init(_ bean: FileUploaderDto) {
        self.bean = bean
    }
    
    ///上传
    func upload() {
//        self.progress("文件校验中")
        
            
        //IOS端必须调用该函数才允许访问文件
        let fileURL = URL(string: "file://" +  self.bean.path)!
        fileURL.startAccessingSecurityScopedResource()
        
        //获取文件的MD5
        self.fileMD5 = FileUtil.getMD5(self.bean.path)
        fileURL.stopAccessingSecurityScopedResource()
        self.checkExists()
    }
    
    ///检查文件是否已经上传
    private func checkExists(){
//        self.progress("校验上传状态")
        self.apiHttp = FileUploadApi.checkExistsByMd5(md5: self.fileMD5!).hide()
            .error{
                self.finish(UploaderError.error($0))
            }.fail{
                self.finish(UploaderError.error($0.msg ?? ""))
            }.post {
                if $0{//文件已经上传
                    self.finish()
                    return
                }
                self.getUploadedSize()
            }
    }
    
    //从服务器端获取已经上传文件大小
    private func getUploadedSize(){
//        self.progress("校验断点续传")
        self.apiHttp = FileUploadApi.getUploadedSize(md5: self.fileMD5!).hide()
            .error{
                self.finish(UploaderError.error($0))
            }.fail{
                self.finish(UploaderError.error($0.msg ?? ""))
            }.post{
                self.offset = $0
                if $0 == self.bean.size{//文件已经上传完成
                    self.uploadByMd5()
                }else{
                    self.uploadStream()
                }
            }
    }
    
    ///开始上传
    private func uploadStream(){
//        self.progress("准备上传")
        let serverURL = SettingShared.domainNotNull + "/app/file_upload/by_stream/" + self.fileMD5!
        let url = URL(string: serverURL)!
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 60)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        //要监听上传进度,这个参数必须传
        request.setValue("\(self.bean.size - self.offset)", forHTTPHeaderField: "Content-Length")
        let uploadTask = self.session.uploadTask(withStreamedRequest: request)
        uploadTask.resume()
        self.task = uploadTask
        request.httpBodyStream = boundStreams.input
    }
    
    ///通过MD5上传
    private func uploadByMd5(){
        
        //得到文件名
        let originalFilename = self.bean.name
        
        //得到文件后缀
        let ext = (originalFilename as NSString).pathExtension.lowercased()
//        self.progress("服务端处理中")
        
        let time = Int64(Date().timeIntervalSince1970 * 1_000_000)
        self.apiHttp = FileUploadApi.byMd5(md5: self.fileMD5!, path: "/相册/\(time)." + ext, contentType: "").hide()
            .error{
                self.finish(UploaderError.error($0))
            }.fail{
                self.finish(UploaderError.error($0.msg ?? ""))
            }
            .post {
                self.finish()
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
        Task.detached{
            self.readFile()
        }
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
//        let progress = (totalBytesSent + self.offset).fileSize + "/" +  (totalBytesExpectedToSend + self.offset).fileSize
//        self.progress(progress)
        
        //当前时间戳秒
        let now = Date()
        
        //下载速度
        let speed = Double(totalBytesSent - self.preTotalBytesSent) / now.timeIntervalSince(self.lastSendTime)
        
        //完成之后回调下载进度,避免出现下载进度无法100%
        self.notify(.progress, [self.bean.size, totalBytesSent + self.offset, Int64(speed)])
        
        //更新最后记录时间
        self.lastSendTime = now
        
        //更新上次上传大小
        self.preTotalBytesSent = totalBytesSent
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
        if let response = task.response as? HTTPURLResponse{
            if response.statusCode != 200{
                self.finish(UploaderError.error(self.resBody ?? ""))
                return
            }
        }
        if let error = error {
            self.finish(error)
            return
        }
        self.uploadByMd5()
    }
    
    private func readFile(){
        
        //IOS端必须调用该函数才允许访问文件
        let fileURL = URL(string: "file://" +  self.bean.path)!
        fileURL.startAccessingSecurityScopedResource()
        defer{
            self.boundStreams.output.close()
            fileURL.stopAccessingSecurityScopedResource()
        }
        guard let fileHandle = try? FileHandle(forReadingAtPath: self.bean.path) else{
            return
        }
        defer{
            try? fileHandle.close()
        }
        try? fileHandle.seek(toOffset: UInt64(self.offset)) // 跳过前 n 字节
//        let chunkSize = 1024 * 1024
        let chunkSize = 1024
        while true {
            var data = fileHandle.readData(ofLength: chunkSize)
            
            //测试用
//            Thread.sleep(forTimeInterval: 0.01)
            if data.isEmpty { break } // 文件读完
            while data.count > 0{
                let bytesWritten: Int = data.withUnsafeBytes() { (buffer: UnsafePointer<UInt8>) in
                    
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
                    return
                }
                if bytesWritten > 0{
                    data.removeSubrange(0..<bytesWritten)
                }
            }
        }
    }
    
    
    ///上传完成执行函数
    private func finish(_ err: Error? = nil){
        
        //一定要将apiHttp设置为nil,否则内存不会被回收
        self.apiHttp = nil
        FileUploaderManager.uploadFinish(self.bean, err)
        
            
            //回调下载结束函数
            self.notify(.finish, err)
//        Task{@MainActor in
//            NotificationCenter.default.post(name: Notification.Name(FileUploaderManager.NOTIFY_UPLOAD_ITEM_FINISH), object: [self.bean.id, msg])
//        }
    }
    
//    ///上传进度执行函数
//    private func progress(_ msg: String){
//        Task{@MainActor in
//            NotificationCenter.default.post(name: Notification.Name(FileUploaderManager.NOTIFY_UPLOAD_PROGRESS), object: [self.bean.id, msg])
//        }
//    }
    
    /// 发送通知
    ///
    /// - Parameter type:通知类型
    /// - Parameter value:参数值
    private func notify(_ type: FileUploadNotify, _ value: Sendable? = nil){
        Task{ @MainActor in
            NotificationCenter.default.post(
                name: Notification.Name(self.bean.id),
                object: nil,
                userInfo: ["key": type, "value": value]
            )
        }
    }
    
    ///取消
    func cancel(){
        
        //手动取消正在上传的task,否则服务端无法知道客户端结束,造成阻塞直到超时
        self.task?.cancel()
        if let apiHttp{
            apiHttp.cancel()
        }
    }
    deinit{
        print("-->deinit:FileUploader")
    }
}
