
enum LibrawInstallApi {

  static func html() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_INSTALL_LIBRAW)
  }

  //资源回收
  static func recycle() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_INSTALL_LIBRAW_RECYCLE)
  }

  static func install() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_INSTALL_LIBRAW_INSTALL)
  }

  //当前安装进度
  static func progress() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_INSTALL_LIBRAW_PROGRESS)
  }
}