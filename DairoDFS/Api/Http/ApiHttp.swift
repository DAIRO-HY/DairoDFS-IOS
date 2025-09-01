import Foundation
import DairoUI_IOS

struct URLSessionManager{
    
    ///网络请求
    private static var mURLSession: URLSession? = nil
    
    ///网络请求
    static var urlSession: URLSession{
        if URLSessionManager.mURLSession == nil{
            URLSessionManager.mURLSession = URLSession.shared
        }
        return URLSessionManager.mURLSession!
    }
}

///api请求基类
protocol ApiHttpBase{
    
    //取消请求
    func cancel()
}

/**
 * API请求
 */
class ApiHttp<T: Codable> : ApiHttpBase{
    
    private let url: String
    
    ///API参数
    private let parameter: [String : Codable]
    
    ///http请求任务
    private var httpTask: URLSessionDataTask?
    
    ///是否显示加载中的遮罩层
    private var isShowWaiting = true
    
    /**
     * 失败时消息回调
     */
    private var failFunc: ((_ failModel: ApiFailModel) -> Void)?
    
    /**
     * 出错时消息回调
     */
    private var errorFunc: ((_ msg: String) -> Void)?
    
    /**
     * 最终回调
     */
    private var finishFunc: (() -> Void)?
    
    init(_ url: String, parameter: [String : Codable] = [String : Codable]()) {
        self.url = url
        self.parameter = parameter
        
        //        //超时设置
        //        self.httpUtil.connectTimeout = 15000
        //        self.httpUtil.readTimeout = 60000
        //        self.httpUtil.method = "POST"
        //
        //        // 设置请求的Content-Type为application/x-www-form-urlencoded
        //        self.httpUtil.setHeader("Content-Type","application/x-www-form-urlencoded")
        //
        //        self.httpUtil.addParam("_client",5)//IOS标识
        //        self.httpUtil.addParam("_versionCode",Bundle.main.infoDictionary?["CFBundleVersion"] as! String)//版本号
        //        self.httpUtil.addParam("_versionName",Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)//版本名
        //        if let token = UserShared.token {//携带登录信息
        //            self.httpUtil.addParam("_token",token)
        //        }
    }
    
    /**
     * 请求失败时的回调
     */
    func fail(block: @escaping (_ failModel: ApiFailModel) -> Void) -> ApiHttp {
        self.failFunc = block
        return self
    }
    
    /**
     * 请求异常时的回调
     */
    func error(block: @escaping (_ msg: String) -> Void) -> ApiHttp {
        self.errorFunc = block
        return self
    }
    
    /**
     * 最终回调
     */
    func finish(block: @escaping () -> Void) -> ApiHttp {
        self.finishFunc = block
        return self
    }
    
    /**
     * 不显示等待框
     */
    func hide() -> ApiHttp {
        self.isShowWaiting = false
        return self
    }
    
    /**
     * 调用失败函数
     */
    private func callFail(_ failModel: ApiFailModel) {
        if self.failFunc != nil {
            self.failFunc!(failModel)
        } else {
            if self.isShowWaiting{//有遮照层
                Toast.show(failModel.msg ?? "处理失败")
            }
        }
    }
    
    /**
     * 调用出错函数
     */
    private func callError(_ msg: String) {
        if (self.errorFunc != nil) {
            self.errorFunc!(msg)
        } else {
            if self.isShowWaiting{//有遮照层
                Toast.show(msg)
            }
        }
    }
    
    /**
     * 发起请求
     * 带参回调
     * - paramter successFunc  成功的返回值
     */
    func post(_ successFunc: @escaping (_ data: T) -> Void)  -> ApiHttp{
        self.request("POST") {
            successFunc($0!)
        }
        return self
    }
    
    /**
     * 发起请求
     * 无参回调
     * - paramter successFunc  成功的返回值
     */
    func post(_ successFunc: @escaping () -> Void)  -> ApiHttp{
        self.request("POST") {_ in
            successFunc()
        }
        return self
    }
    
    /**
     * 发起请求
     */
    func request(_ method: String, _ successFunc: @escaping((_ data: T?) -> Void)) {
        var request = URLRequest(url: URL(string: SettingShared.domainNotNull + self.url + "?_token=" + SettingShared.token)!)
        request.httpMethod = method//请求方式
        request.timeoutInterval = 15 // 设置超时(秒)
        
        //添加公共参数
        var body = ""
        for entry in self.parameter{
            let bodyValue: String
            if let value = entry.value as? String{//过滤掉空字符串的参数
                if value.isEmpty{
                    continue
                }
                bodyValue = value
            } else if let value  = entry.value as? [String]{//如果是一个字符串数组
                
                //@TODO: 数组里面的字符串的逗号(,)需要单独处理
                bodyValue = "[" + value.joined(separator: ",") + "]"
            } else if let value  = entry.value as? [any Codable]{//如果是一个数组
                bodyValue = "[" + value.map{"\($0)"}.joined(separator: ",") + "]"
            } else {
                bodyValue = "\(entry.value)"
            }
            body += "\(entry.key)=" + bodyValue + "&"
        }
        if !body.isEmpty{
            body.removeLast()
            request.httpBody = body.data(using: .utf8)
        }
        let httpTask = URLSession.shared.dataTask(with: request){ data, response, error in
            if self.isShowWaiting{
                Loading.hide()
            }
            if let error = error {
                self.callError(error.localizedDescription)
                return
            }
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode != 200{
                let responseText = String(data: data!, encoding: .utf8)!
                if responseText.hasPrefix("{"){//这是一个json字符串
                    let fm = try! JSONDecoder().decode(ApiFailModel.self, from: responseText.data(using: .utf8)!)
                    self.callFail(fm)
                }
                self.callError(responseText)
                return
            }
            let t = self.convert(data!)
            //使回调函数运行在主线程上
            Task{@MainActor in
                successFunc(t)
            }
        }
        self.httpTask = httpTask
        
        //如果需要显示等待框
        if self.isShowWaiting{
            Loading.show()
        }
        httpTask.resume()
    }
    
    /**
     * 将返回值转换成指定的类型
     */
    private func convert(_ data: Data) -> T{
        switch(T.self){
        case is String.Type:
            return String(data: data, encoding: .utf8) as! T
        case is Data.Type:
            return data as! T
        case is Int.Type:
            return Int(String(data: data, encoding: .utf8)!) as! T
        case is Double.Type:
            return Double(String(data: data, encoding: .utf8)!) as! T
        case is Bool.Type:
            return (String(data: data, encoding: .utf8)!.lowercased() == "true") as! T
        case is EmptyModel.Type:
            return EmptyModel() as! T
        default:
            return try! JSONDecoder().decode(T.self, from: data)
        }
    }
    
    /**
     * 取消请求
     */
    func cancel(){
        self.httpTask?.cancel()
    }
    
    deinit{
        debugPrint("-->ApiHttp:deinit")
    }
}


/**
 * 不需要返回结果的Model
 */
struct EmptyModel: Codable {
}

/**
 * API返回失败Model
 */
struct ApiFailModel: Codable {
    
    /**
     * 返回代码
     */
    let code: Int
    
    /**
     * 执行结果
     */
    let msg: String?
}


/**
 * Api请求Error
 */
struct ApiFailError : Error{
    let failModel: ApiFailModel
}

