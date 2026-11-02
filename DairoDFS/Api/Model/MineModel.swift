struct MineModel : Codable {

  	/** 主键 **/
  var id: Int64

  	/** 用户名 **/
  var name: String

  	/** 用户电子邮箱 **/
  var email: String

  	/** 创建日期 **/
  var date: String

  	/** 用户文件访问路径前缀 **/
  var urlPath: String

  	/** API操作TOKEN **/
  var apiToken: String

  	/** 端对端加密密钥 **/
  var encryptionKey: String

  	/** 是否管理员 **/
  var isAdmin: Bool

  	/** 昵称,本地保存的旧用户信息里没有这个字段 **/
  var nickname: String?

  	/** 头像的MD5,空表示没有头像,本地保存的旧用户信息里没有这个字段 **/
  var avatar: String?

  	/** 显示的名字,没有昵称时显示用户名 **/
  var displayName: String {
    return self.nickname?.isEmpty == false ? self.nickname! : self.name
  }

}
