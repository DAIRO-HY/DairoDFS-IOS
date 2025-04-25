
enum ProfileApi {

  //系统配置
  //页面初始化
  static func html() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_PROFILE_HTML)
  }

  //页面数据初始化
  static func _init() -> ApiHttp<ProfileModel>{
    return ApiHttp<ProfileModel>(ApiConst.APP_PROFILE_INIT)
  }

  //页面初始化
  static func update(openSqlLog: Bool,hasReadOnly: Bool,uploadMaxSize: Int64,folders: String,syncDomains: String,token: String,trashTimeout: Int64,deleteStorageTimeout: Int64,thumbMaxSize: Int,ignoreSyncError: Bool) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_PROFILE_UPDATE,parameter: ["openSqlLog":openSqlLog,"hasReadOnly":hasReadOnly,"uploadMaxSize":uploadMaxSize,"folders":folders,"syncDomains":syncDomains,"token":token,"trashTimeout":trashTimeout,"deleteStorageTimeout":deleteStorageTimeout,"thumbMaxSize":thumbMaxSize,"ignoreSyncError":ignoreSyncError])
  }

  //切换token
  static func makeToken() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_PROFILE_MAKE_TOKEN)
  }
}