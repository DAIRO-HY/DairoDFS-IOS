
enum UserEditApi {

  //用户编辑
  static func editHtml() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_USER_EDIT_HTML)
  }

  static func editInit(id: Int64) -> ApiHttp<UserEditInoutModel>{
    return ApiHttp<UserEditInoutModel>(ApiConst.APP_USER_EDIT_INIT,parameter: ["id":id])
  }

  static func edit(id: Int64,name: String,email: String,state: Int8,date: String,pwd: String) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_USER_EDIT_EDIT,parameter: ["id":id,"name":name,"email":email,"state":state,"date":date,"pwd":pwd])
  }
}