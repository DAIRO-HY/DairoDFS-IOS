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
    
    /// 用户主动取消
    case cancel
}

class FileUploader: NSObject,
                    URLSessionTaskDelegate,
                    StreamDelegate,
                    URLSessionDataDelegate {
    
    //要上传的文件url
    private let dto: FileUploaderDto
    
    //断点续传偏移长度
    private  var offset: Int64 = 0
    
    //文件的MD5
    private var fileMD5: String?
    
    //当前请求的apiHttp
    private var apiHttp: ApiHttpBase?
    
    /// 标记是否已经被主动取消
    private var isCancel = false
    
    //当前上传任务,用于取消
    private var task: URLSessionTask?
    
    ///记录已经读取了的数据大小
    private var readedDataSize: Int64 = 0
    
    /// 上回统计的上传大小,用来计算网速
    private var uploadedSize: Int64 = 0
    
    /// 最后一次记录的上传时间
    private var lastSendTime = Date()
    
    lazy var session: URLSession = URLSession(configuration: .default,
                                              delegate: self,
                                              delegateQueue: nil)
    
    init(_ dto: FileUploaderDto) {
        self.dto = dto
    }
    
    ///上传
    func upload() {
        if self.dto.md5 == nil{//如果文件MD5没有设置,则设置md5
            var isStale = false
            
            //通过data恢复URL,确保app退出后该文件依然能够访问
            let fileURL = try! URL(resolvingBookmarkData: self.dto.bookmarkData,
                                   options: [.withoutImplicitStartAccessing], // ✅ 在恢复时加
                                   relativeTo: nil,
                                   bookmarkDataIsStale: &isStale)
            fileURL.startAccessingSecurityScopedResource()
            
            //获取文件的MD5
            self.fileMD5 = FileUtil.getMD5(fileURL)
            fileURL.stopAccessingSecurityScopedResource()
            FileUploaderDBUtil.setMd5(self.dto.id, self.fileMD5!)
        } else {
            self.fileMD5 = self.dto.md5
        }
        self.uploadByMd5_step1()
    }
    
    ///第一次直接通过MD5上传
    private func uploadByMd5_step1(){
        self.apiHttp = FileUploadApi.byMd5(md5: self.fileMD5!, path: self.dto.dfsPath, contentType: "").hide()
            .error{
                self.callFinishAndNotify($0)
            }.fail{
                if $0.code == 1004{//文件没有被上传
                    self.getUploadedSize()
                    return
                }
                self.callFinishAndNotify($0.msg ?? "")
            }.post {
                self.callFinishAndNotify()
            }
    }
    
    //从服务器端获取已经上传文件大小
    private func getUploadedSize(){
        self.apiHttp = FileUploadApi.getUploadedSize(md5: self.fileMD5!).hide()
            .error{
                self.callFinishAndNotify($0)
            }.fail{
                self.callFinishAndNotify($0.msg ?? "")
            }.post{
                self.offset = $0
                if $0 == self.dto.size{//文件已经上传完成
                    self.uploadByMd5()
                } else {
                    self.uploadStream()
                }
            }
    }
    
    ///开始上传
    private func uploadStream(){
        let serverURL = SettingShared.domainNotNull + "/app/file_upload/by_stream/" + self.fileMD5! + "?_token=" + SettingShared.token
        let url = URL(string: serverURL)!
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 60)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        //要监听上传进度,这个参数必须传
        request.setValue("\(self.dto.size - self.offset)", forHTTPHeaderField: "Content-Length")
        let uploadTask = self.session.uploadTask(withStreamedRequest: request)
        uploadTask.resume()
        self.task = uploadTask
        request.httpBodyStream = boundStreams.input
    }
    
    ///通过MD5上传
    private func uploadByMd5(){
        self.apiHttp = FileUploadApi.byMd5(md5: self.fileMD5!, path: self.dto.dfsPath, contentType: "").hide()
            .error{
                self.callFinishAndNotify($0)
            }.fail{
                self.callFinishAndNotify($0.msg ?? "")
            }.post {
                self.callFinishAndNotify()
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
        
        //得到已经上传大小
        let uploadedSize = totalBytesSent + self.offset
        
        //下载速度
        let speed = Double(uploadedSize - self.uploadedSize) / now.timeIntervalSince(self.lastSendTime)
        
        //完成之后回调下载进度,避免出现下载进度无法100%
        self.notify(.progress, [self.dto.size, uploadedSize, Int64(speed)])
        
        //更新最后记录时间
        self.lastSendTime = now
        
        //更新上次上传大小
        self.uploadedSize = uploadedSize
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
                self.callFinishAndNotify(self.resBody ?? "")
                return
            }
        }
        if let error = error{
            self.callFinishAndNotify(error.localizedDescription)
            return
        }
        self.uploadByMd5()
    }
    
    private func readFile(){
        var isStale = false
        
        //通过data恢复URL,确保app退出后该文件依然能够访问
        let fileURL = try! URL(resolvingBookmarkData: self.dto.bookmarkData,
                               options: [.withoutImplicitStartAccessing], // ✅ 在恢复时加
                               relativeTo: nil,
                               bookmarkDataIsStale: &isStale)
        fileURL.startAccessingSecurityScopedResource()
        defer{
            self.boundStreams.output.close()
            fileURL.stopAccessingSecurityScopedResource()
        }
        guard let fileHandle = try? FileHandle(forReadingFrom: fileURL) else{
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
    private func callFinishAndNotify(_ errMsg: String? = nil){
        
        //一定要将apiHttp设置为nil,否则内存不会被回收
        self.apiHttp = nil
        if self.isCancel{//如果是用户主动取消
            self.notify(.pause)
            
            //修改数据库文件上传状态
            FileUploaderDBUtil.setState(self.dto.id, 2)
        } else if let errMsg = errMsg{//上传失败
            self.notify(.finish, errMsg)
            
            //修改数据库文件上传状态
            FileUploaderDBUtil.setState(self.dto.id, 3, errMsg)
        } else {// 上传成功
            self.notify(.finish)
            
            //修改数据库文件上传状态
            FileUploaderDBUtil.setState(self.dto.id, 10)
        }
        
        //设置已经上传大小
        FileUploaderDBUtil.setUploadedSize(self.dto.id, self.uploadedSize)
        FileUploaderManager.finish(self.dto.id)
    }
    
    /// 发送通知
    ///
    /// - Parameter type:通知类型
    /// - Parameter value:参数值
    private func notify(_ type: FileUploaderNotify, _ value: Sendable? = nil){
        Task{ @MainActor in
            NotificationCenter.default.post(
                name: Notification.Name(String(self.dto.id)),
                object: nil,
                userInfo: ["key": type, "value": value]
            )
        }
    }
    
    ///取消
    func cancel(){
        self.isCancel = true
        
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
