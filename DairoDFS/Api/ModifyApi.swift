enum ModifyApi {

  //修改密码,成功之后该用户所有设备的票据都会失效
  static func modify(oldPwd: String,pwd: String) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.MODIFY_PWD,method: "PUT",parameter: ["oldPwd":oldPwd,"pwd":pwd])
  }
}
