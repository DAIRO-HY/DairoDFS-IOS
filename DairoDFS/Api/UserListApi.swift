
struct UserListApi {

  //用户列表
  static func listHtml() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_USER_LIST_HTML)
  }

  static func listInit() -> ApiHttp<[UserListOutModel]>{
    return ApiHttp<[UserListOutModel]>(ApiConst.APP_USER_LIST_INIT)
  }
}