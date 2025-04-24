
struct AdvancedApi {

  //高级功能
  static func html() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_ADVANCED_HTML)
  }

  static func _init() -> ApiHttp<[String : String]>{
    return ApiHttp<[String : String]>(ApiConst.APP_ADVANCED_INIT)
  }

  //页面数据初始化
  static func execSql(sql: String) -> ApiHttp<String>{
    return ApiHttp<String>(ApiConst.APP_ADVANCED_EXEC_SQL,parameter: ["sql":sql])
  }

  //开始处理线程
  static func reHandle() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_ADVANCED_RE_HANDLE)
  }

  //获取DFS正在使用的文件大小
  static func usedSize() -> ApiHttp<String>{
    return ApiHttp<String>(ApiConst.APP_ADVANCED_USED_SIZE)
  }

  //立即回收未使用的文件
  static func recycleNow() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_ADVANCED_RECYCLE_NOW)
  }
}