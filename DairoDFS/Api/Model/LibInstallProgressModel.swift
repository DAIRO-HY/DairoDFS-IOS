/*工具自动生成代码,请勿手动修改*/
struct LibInstallProgressModel : Codable {

  /** 是否正在下载 **/
  var isRuning: Bool

  /** 是否已经安装完成 **/
  var isInstalled: Bool

  /** 文件总大小 **/
  var total: String

  /** 已经下载大小 **/
  var downloadedSize: String

  /** 下载速度 **/
  var speed: String

  /** 下载进度 **/
  var progress: Int

  /** 安装信息 **/
  var info: String

}
