struct LoginAppOutModel : Codable {

  	/** 登录票据 **/
  var token: String

  	/** 用户名 **/
  var name: String

  	/** 是否管理员 **/
  var isAdmin: Bool

}
