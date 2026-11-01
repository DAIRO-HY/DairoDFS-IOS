enum CommonApi {

  //获取服务器公共信息,不需要登录
  static func global() -> ApiHttp<GlobalModel>{
    return ApiHttp<GlobalModel>(ApiConst.COMMON_GLOBAL,method: "GET").noAuth()
  }
}
