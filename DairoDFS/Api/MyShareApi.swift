
struct MyShareApi {

  static func html() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_MY_SHARE_HTML)
  }

  //获取所有的分享
  static func getList() -> ApiHttp<[MyShareModel]>{
    return ApiHttp<[MyShareModel]>(ApiConst.APP_MY_SHARE_GET_LIST)
  }

  //获取分享详细
  //id 分享id
  static func getDetail(id: Int64) -> ApiHttp<MyShareDetailModel>{
    return ApiHttp<MyShareDetailModel>(ApiConst.APP_MY_SHARE_GET_DETAIL,parameter: ["id":id])
  }

  //取消所选分享
  //ids 分享id列表
  static func delete(ids: [Int64]) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_MY_SHARE_DELETE,parameter: ["ids":ids])
  }
}