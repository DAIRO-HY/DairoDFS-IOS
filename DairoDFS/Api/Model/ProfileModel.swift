/*工具自动生成代码,请勿手动修改*/
struct ProfileModel : Codable {

  	/** 记录同步日志 **/
  var openSqlLog: Bool

  	/** 将当前服务器设置为只读,仅作为备份使用 **/
  var hasReadOnly: Bool

  	/** 文件上传限制 **/
  var uploadMaxSize: Int64

  	/** 存储目录 **/
  var folders: String

  	/** 同步域名 **/
  var syncDomains: String

  	/** 分机与主机同步连接票据 **/
  var token: String

  	// 回收站超时(单位：天)
  var trashTimeout: Int64

  	// 删除没有被使用的文件超时设置(单位：天)
  var deleteStorageTimeout: Int64

  	/** 缩略图最大边尺寸 **/
  var thumbMaxSize: Int

  	/** 忽略本机同步错误 **/
  var ignoreSyncError: Bool

  	/**  数据库备份天数 **/
  var dbBackupExpireDay: Int

}
