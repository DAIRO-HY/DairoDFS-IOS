
enum IndexApi {

  //页面初始化
  static func index() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.INDEX_HTML)
  }
}