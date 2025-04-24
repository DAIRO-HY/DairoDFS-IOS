
struct LoginApi {

  //登录页面
  static func _init() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_LOGIN)
  }

  static func doLogin(name: String,pwd: String,deviceId: String) -> ApiHttp<LoginAppOutModel>{
    return ApiHttp<LoginAppOutModel>(ApiConst.APP_LOGIN_DO_LOGIN,parameter: ["name":name,"pwd":pwd,"deviceId":deviceId])
  }

  static func logout() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_LOGIN_LOGOUT)
  }
}