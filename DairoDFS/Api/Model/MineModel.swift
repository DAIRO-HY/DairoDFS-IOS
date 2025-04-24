/*工具自动生成代码,请勿手动修改*/
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

}
