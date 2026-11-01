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
    
    ///请求方式
    private let method: String
    
    ///API参数
    private let parameter: [String : Codable]
    
    ///http请求任务
    private var httpTask: URLSessionDataTask?
    
    ///是否显示加载中的遮罩层
    private var isShowWaiting = true
    
    ///是否携带登录票据
    private var isAuth = true
    
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
    
    init(_ url: String, method: String, parameter: [String : Codable] = [String : Codable]()) {
        self.url = url
        self.method = method
        self.parameter = parameter
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
     * 不携带登录票据,用于登录等不需要登录的接口
     */
    func noAuth() -> ApiHttp {
        self.isAuth = false
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
    @discardableResult
    func send(_ successFunc: @escaping (_ data: T) -> Void)  -> ApiHttp{
        self.request(successFunc)
        return self
    }
    
    /**
     * 发起请求
     * 无参回调
     * - paramter successFunc  成功的返回值
     */
    @discardableResult
    func send(_ successFunc: @escaping () -> Void)  -> ApiHttp{
        self.request{_ in
            successFunc()
        }
        return self
    }
    
    /**
     * 发起请求
     */
    private func request(_ successFunc: @escaping((_ data: T) -> Void)) {
        let parameterStr = self.parameterStr
        var urlStr = SettingShared.domainNotNull + self.url
        if self.method == "GET" && !parameterStr.isEmpty{
            urlStr += "?" + parameterStr
        }
        guard let url = URL(string: urlStr) else{
            self.callError("服务器地址不正确:" + urlStr)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = self.method//请求方式
        request.timeoutInterval = 15 // 设置超时(秒)
        if self.isAuth{
            request.setValue("Bearer " + SettingShared.token, forHTTPHeaderField: "Authorization")
        }
        if self.method != "GET" && !parameterStr.isEmpty{
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = parameterStr.data(using: .utf8)
        }
        let httpTask = URLSession.shared.dataTask(with: request){ data, response, error in
            
            //使回调函数运行在主线程上
            Task{@MainActor in
                if self.isShowWaiting{
                    Loading.hide()
                }
                if let error = error as? URLError, error.code == .cancelled{//请求被取消
                    return
                }
                defer{
                    self.finishFunc?()
                }
                if let error = error {
                    self.callError(error.localizedDescription)
                    return
                }
                self.onResponse(response as! HTTPURLResponse, data ?? Data(), successFunc)
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
     * 将参数拼接成字符串,数组参数使用重复的key
     */
    private var parameterStr: String{
        var items = [String]()
        for entry in self.parameter{
            let values: [Any]
            if let value = entry.value as? [any Codable]{
                values = value
            } else {
                values = [entry.value]
            }
            for value in values{
                items.append(ApiHttp.encode(entry.key) + "=" + ApiHttp.encode("\(value)"))
            }
        }
        return items.joined(separator: "&")
    }
    
    /**
     * 对参数进行URL编码
     */
    private static func encode(_ value: String) -> String{
        return value.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "-._~").union(.alphanumerics)) ?? value
    }
    
    /**
     * 处理服务器返回结果
     * 200:成功 401:登录失效 其他:失败,返回内容是错误信息
     */
    private func onResponse(_ response: HTTPURLResponse, _ data: Data, _ successFunc: (_ data: T) -> Void){
        if response.statusCode == 200{
            guard let t = self.convert(data) else{
                self.callError("服务器返回数据格式不正确")
                return
            }
            successFunc(t)
            return
        }
        if response.statusCode == 401 && self.isAuth && SettingShared.isLogin{
            Toast.show("登录已失效,请重新登录")
            SettingShared.toLoginPage()
            return
        }
        self.callFail(self.makeFailModel(response.statusCode, data))
    }
    
    /**
     * 生成失败信息,表单验证失败时优先显示字段的错误信息
     */
    private func makeFailModel(_ statusCode: Int, _ data: Data) -> ApiFailModel{
        if let formFail = try? JSONDecoder().decode(ApiFormFailModel.self, from: data){
            let msg = formFail.data?.values.first{ !$0.isEmpty }?.first ?? formFail.msg
            return ApiFailModel(code: statusCode, msg: msg)
        }
        let msg = String(data: data, encoding: .utf8) ?? ""
        return ApiFailModel(code: statusCode, msg: msg.isEmpty ? nil : msg)
    }
    
    /**
     * 将返回值转换成指定的类型
     */
    private func convert(_ data: Data) -> T?{
        switch(T.self){
        case is String.Type:
            return String(data: data, encoding: .utf8) as? T
        case is Bool.Type:
            return (String(data: data, encoding: .utf8)?.lowercased() == "true") as? T
        case is EmptyModel.Type:
            return EmptyModel() as? T
        default:
            return try? JSONDecoder().decode(T.self, from: data)
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
     * HTTP状态码
     */
    let code: Int
    
    /**
     * 错误信息
     */
    let msg: String?
}

/**
 * 表单验证失败Model
 */
private struct ApiFormFailModel: Codable {
    
    /**
     * 错误信息
     */
    let msg: String?
    
    /**
     * 字段名 => 错误信息
     */
    let data: [String : [String]]?
}


/**
 * Api请求Error
 */
struct ApiFailError : Error{
    let failModel: ApiFailModel
}

