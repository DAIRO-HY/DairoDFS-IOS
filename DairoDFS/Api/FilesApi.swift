enum FilesApi {

  //获取文件列表
  //folder 文件夹路径,空字符串表示根目录
  static func getList(folder: String) -> ApiHttp<FileListModel>{
    return ApiHttp<FileListModel>(ApiConst.FILES_LIST,method: "GET",parameter: ["folder":folder])
  }

  //获取相册列表
  static func getAlbumList() -> ApiHttp<[AlbumItemModel]>{
    return ApiHttp<[AlbumItemModel]>(ApiConst.FILES_ALBUM,method: "GET")
  }

  //创建文件夹
  static func createFolder(folder: String) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.FILES_CREATE_FOLDER,method: "POST",parameter: ["folder":folder])
  }

  //删除文件
  static func delete(ids: [Int64]) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.FILES_DELETE,method: "DELETE",parameter: ["ids":ids])
  }

  //重命名
  //id 文件ID
  //name 新名称
  static func rename(id: Int64,name: String) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.FILES_RENAME,method: "PUT",parameter: ["id":id,"name":name])
  }

  //修改拍摄时间
  //id 文件ID
  //date 拍摄时间(毫秒),0表示恢复成照片本身的拍摄时间
  static func updateCaptureTime(id: Int64,date: Int64) -> ApiHttp<FilePropertyModel>{
    return ApiHttp<FilePropertyModel>(ApiConst.FILES_CAPTURE_TIME,method: "PUT",parameter: ["id":id,"date":date])
  }

  //文件复制
  //ids 文件ID列表
  //targetFolder 目标文件夹
  //isOverWrite 是否覆盖目标文件
  static func copy(ids: [Int64],targetFolder: String,isOverWrite: Bool) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.FILES_COPY,method: "POST",parameter: ["ids":ids,"targetFolder":targetFolder,"isOverWrite":isOverWrite])
  }

  //文件移动
  //ids 文件ID列表
  //targetFolder 目标文件夹
  //isOverWrite 是否覆盖目标文件
  static func move(ids: [Int64],targetFolder: String,isOverWrite: Bool) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.FILES_MOVE,method: "POST",parameter: ["ids":ids,"targetFolder":targetFolder,"isOverWrite":isOverWrite])
  }

  //文件或文件夹属性
  //ids 选择的文件ID列表
  static func getProperty(ids: [Int64]) -> ApiHttp<FilePropertyModel>{
    return ApiHttp<FilePropertyModel>(ApiConst.FILES_PROPERTY,method: "GET",parameter: ["ids":ids])
  }
}
