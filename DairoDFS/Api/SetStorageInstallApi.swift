
enum SetStorageInstallApi {

  static func html() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_INSTALL_SET_STORAGE)
  }

  static func set(path: [String]) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_INSTALL_SET_STORAGE_SET,parameter: ["path":path])
  }
}