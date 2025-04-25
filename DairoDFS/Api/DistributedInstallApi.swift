
enum DistributedInstallApi {

  static func html() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_INSTALL_DISTRIBUTED)
  }

  static func set(syncUrl: [String]) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_INSTALL_DISTRIBUTED_SET,parameter: ["syncUrl":syncUrl])
  }
}