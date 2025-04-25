
enum CreateAdminApi {

  //管理员账号初始化
  static func _init() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_INSTALL_CREATE_ADMIN)
  }

  //账号初始化API
  static func addAdmin(name: String,pwd: String) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_INSTALL_CREATE_ADMIN_ADD_ADMIN,parameter: ["name":name,"pwd":pwd])
  }
}