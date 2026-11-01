enum FileUploadApi {

  //检查当前用户的文件里是否已经有相同的文件
  //- md5 文件的md5
  static func exists(md5: String) -> ApiHttp<Bool>{
    return ApiHttp<Bool>(ApiConst.FILE_UPLOAD_EXISTS,method: "GET",parameter: ["md5":md5])
  }
}
