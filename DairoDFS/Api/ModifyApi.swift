
enum ModifyApi {

  //密码修改
  static func html() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_MODIFY_PWD_HTML)
  }

  //修改密码
  static func modify(oldPwd: String,pwd: String) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_MODIFY_PWD_MODIFY,parameter: ["oldPwd":oldPwd,"pwd":pwd])
  }
}