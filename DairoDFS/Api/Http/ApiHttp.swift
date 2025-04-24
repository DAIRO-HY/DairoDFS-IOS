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

/**
 * API请求
 */
class ApiHttp<T: Codable> {
    
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
     * 调用失败函数
     */
    private func callFail(_ failModel: ApiFailModel) {
//        if (self.failFunc != nil) {
//                self.failFunc!(failModel)
//        } else {
//            if self.isShowWaiting{//有遮照层
//                Toast.show(failModel.msg ?? "处理失败")
//            }
//        }
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
    func post(_ successFunc: @escaping (_ data: T) -> Void) {
        self.request("POST") {
            successFunc($0!)
        }
    }
    
    /**
     * 发起请求
     * 无参回调
     * - paramter successFunc  成功的返回值
     */
    func post(_ successFunc: @escaping () -> Void) {
        self.request("POST") {_ in
            successFunc()
        }
    }
    
    /**
     * 调用成功函数
     */
//    private func callRequestSuccess(_ data: Data){
//        if self.httpUtil.statusCode != 200 {//服务器异常
//            if let failModel = try? JSONDecoder().decode(ApiFailModel.self, from: data){
//                self.callFail(failModel)
//            }else{
//                self.callError("服务器异常,状态码:\(self.httpUtil.statusCode)")
//            }
//            return
//        }
//        if data.count == 0 {//服务器没有返回任何数据
//            if let f = self.voidSuccessFunc {//这是一个允许没有返回值的API
//                f()
//                return
//            }
//            if let f = self.nullSuccessFunc {//这是一个允返回null的API
//                f(nil)
//                return
//            }
//        }
//        let model:T
//        do{
//            model = try self.toT(data)
//        } catch {
//            self.callError("数据解析失败:\(String(data: data, encoding: .utf8))")
//            return
//        }
//        if let f = self.nullSuccessFunc {//这是一个允返回null的API
//            f(model)
//            return
//        }
//        if let f = self.notnullSuccessFunc {//这是一个不允返回null的API
//            f(model)
//            return
//        }
//    }
    
    /**
     * 调用最终函数
     */
//    private func callRequestFinish(_ error:Error?){
//            if error != nil{
//                self.callError("网络连接失败")
//            }
//            self.finishFunc?()
//            if self.isShowWaiting {
//                Loading.hide()
//            }
//    }
    
    /**
     * 发起请求
     */
    func request(_ method: String, _ successFunc: @escaping((_ data: T?) -> Void)) {
        var request = URLRequest(url: URL(string: SettingShared.domainNotNull + self.url)!)
        request.httpMethod = method
        if !self.parameter.isEmpty{//需要上传参数
            request.httpBody = self.parameter.filter{ entry in//过滤掉空字符串的参数
                if let value = entry.value as? String{
                    return !value.isEmpty
                }
                return true
            }.map{"\($0)=\($1)"}.joined(separator: "&").data(using: .utf8)
        }
        let httpTask = URLSessionManager.urlSession.dataTask(with: request){ data, response, error in
            Loading.hide()
            if let error = error {
                self.callError("\(error)")
                return
            }
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode != 200{
                self.callError(String(data: data!, encoding: .utf8)!)
                return
            }
            let t = self.convert(data!)
            successFunc(t)
        }
        self.httpTask = httpTask
        
        Loading.show()
        httpTask.resume()
//        self.httpUtil.success{data in
//            DispatchQueue.main.async{
//                self.callRequestSuccess(data)
//            }
//        }.finish{error in
//            DispatchQueue.main.async{
//                self.callRequestFinish(error)
//            }
//        }.request()
//        if self.isShowWaiting {
//            Loading.show()
//        }
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

