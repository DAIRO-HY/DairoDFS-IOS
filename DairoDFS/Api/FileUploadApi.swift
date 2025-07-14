
enum FileUploadApi {

  //文件上传Controller
  //浏览器文件上传
  static func upload(folder: String,contentType: String) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_FILE_UPLOAD,parameter: ["folder":folder,"contentType":contentType])
  }

  //ByStream 以流的方式上传文件
  static func byStream(md5: String) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_FILE_UPLOAD_BY_STREAM_MD5_,parameter: ["md5":md5])
  }

  //GetUploadedSize 获取文件已经上传大小
  //md5 文件的MD5
  static func getUploadedSize(md5: String) -> ApiHttp<Int64>{
    return ApiHttp<Int64>(ApiConst.APP_FILE_UPLOAD_GET_UPLOADED_SIZE,parameter: ["md5":md5])
  }

  //stat 通过MD5上传
  //md5 文件md5
  //path 文件路径
  static func byMd5(md5: String,path: String,contentType: String) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_FILE_UPLOAD_BY_MD5,parameter: ["md5":md5,"path":path,"contentType":contentType])
  }

  //检查文件是否已经存在
  //- md5 文件的md5,多个以逗号分隔
  static func checkExistsByMd5(md5: String) -> ApiHttp<Bool>{
    return ApiHttp<Bool>(ApiConst.APP_FILE_UPLOAD_CHECK_EXISTS_BY_MD5,parameter: ["md5":md5])
  }
}