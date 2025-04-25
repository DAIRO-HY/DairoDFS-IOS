
enum AdvancedValidateFileApi {

  //高级功能：文件验证
  //文件验证同步锁
  //当前正在文件验证的writer
  //停止标记
  //标记是否正在运行
  //当前正在验证的文件数量
  //验证失败的文件
  //验证文件完整
  static func validateFileMD5(isInit: Bool) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_ADVANCED_VALIDATE_FILE_MD5,parameter: ["isInit":isInit])
  }
}