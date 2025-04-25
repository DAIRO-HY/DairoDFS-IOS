
enum SyncApi {

  //数据同步状态
  static func html() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_SYNC_HTML)
  }

  //页面数据初始化
  static func infoList() -> ApiHttp<[SyncServerModel]>{
    return ApiHttp<[SyncServerModel]>(ApiConst.APP_SYNC_INFO_LIST)
  }

  //日志同步
  static func bySync() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_SYNC_BY_LOG)
  }

  //全量同步
  static func byTable() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_SYNC_BY_TABLE)
  }

  //当前同步状态
  static func info() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_SYNC_INFO)
  }
}