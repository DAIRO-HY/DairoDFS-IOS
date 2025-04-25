
enum MagickInstallApi {

  static func html() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_INSTALL_MAGICK)
  }

  //资源回收
  static func recycle() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_INSTALL_MAGICK_RECYCLE)
  }

  static func install() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_INSTALL_MAGICK_INSTALL)
  }

  //当前安装进度
  static func progress() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_INSTALL_MAGICK_PROGRESS)
  }
}