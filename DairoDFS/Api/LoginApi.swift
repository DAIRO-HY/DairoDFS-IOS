import Foundation

enum LoginApi {

  //iOS客户端标识
  private static let CLIENT_FLAG = 2

  //pwd 明文密码
  static func doLogin(name: String,pwd: String,deviceId: String) -> ApiHttp<LoginAppOutModel>{
    let clientVersion = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "") ?? 0
    return ApiHttp<LoginAppOutModel>(ApiConst.LOGIN_DO_LOGIN,method: "POST",parameter: ["name":name,"pwd":pwd,"deviceId":deviceId,"clientFlag":CLIENT_FLAG,"clientVersion":clientVersion]).noAuth()
  }

  static func logout() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.LOGIN_LOGOUT,method: "DELETE")
  }
}
