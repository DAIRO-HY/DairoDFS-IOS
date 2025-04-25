
enum MineApi {

  //系统设置
  //页面初始化
  static func html() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_MINE_HTML)
  }

  //页面初始化
  static func _init() -> ApiHttp<MineModel>{
    return ApiHttp<MineModel>(ApiConst.APP_MINE_INIT)
  }

  static func makeApiToken(flag: Int) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_MINE_MAKE_API_TOKEN,parameter: ["flag":flag])
  }

  static func makeUrlPath(flag: Int) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_MINE_MAKE_URL_PATH,parameter: ["flag":flag])
  }

  static func makeEncryption(flag: Int) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_MINE_MAKE_ENCRYPTION,parameter: ["flag":flag])
  }
}