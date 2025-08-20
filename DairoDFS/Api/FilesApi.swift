
enum FilesApi {

  //文件列表页面
  static func html() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_FILES_HTML)
  }

  //获取文件列表
  static func getList(folder: String) -> ApiHttp<[FileModel]>{
    return ApiHttp<[FileModel]>(ApiConst.APP_FILES_GET_LIST,parameter: ["folder":folder])
  }

  //获取相册列表
  static func getAlbumList() -> ApiHttp<[FileModel]>{
    return ApiHttp<[FileModel]>(ApiConst.APP_FILES_GET_ALBUM_LIST)
  }

  //获取扩展文件的所有key值
  //id 文件id
  static func getExtraKeys(id: Int64) -> ApiHttp<[String]>{
    return ApiHttp<[String]>(ApiConst.APP_FILES_GET_EXTRA_KEYS,parameter: ["id":id])
  }

  //创建文件夹
  static func createFolder(folder: String) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_FILES_CREATE_FOLDER,parameter: ["folder":folder])
  }

  //删除文件
  static func delete(paths: [String]) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_FILES_DELETE,parameter: ["paths":paths])
  }

  //删除文件
  static func deleteByIds(ids: [Int64]) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_FILES_DELETE_BY_IDS,parameter: ["ids":ids])
  }

  //重命名
  //sourcePath 源路径
  //name 新名称
  static func rename(sourcePath: String,name: String) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_FILES_RENAME,parameter: ["sourcePath":sourcePath,"name":name])
  }

  //文件复制
  //sourcePaths 源路径
  //targetFolder 目标文件夹
  //isOverWrite 是否覆盖目标文件
  static func copy(sourcePaths: [String],targetFolder: String,isOverWrite: Bool) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_FILES_COPY,parameter: ["sourcePaths":sourcePaths,"targetFolder":targetFolder,"isOverWrite":isOverWrite])
  }

  //文件移动
  //sourcePaths 源路径
  //targetFolder 目标文件夹
  //isOverWrite 是否覆盖目标文件
  static func move(sourcePaths: [String],targetFolder: String,isOverWrite: Bool) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_FILES_MOVE,parameter: ["sourcePaths":sourcePaths,"targetFolder":targetFolder,"isOverWrite":isOverWrite])
  }

  //分享文件
  static func share(endDateTime: Int64,pwd: String,folder: String,names: [String]) -> ApiHttp<Int64>{
    return ApiHttp<Int64>(ApiConst.APP_FILES_SHARE,parameter: ["endDateTime":endDateTime,"pwd":pwd,"folder":folder,"names":names])
  }

  //文件或文件夹属性
  //paths 选择的路径列表
  static func getProperty(paths: [String]) -> ApiHttp<FilePropertyModel>{
    return ApiHttp<FilePropertyModel>(ApiConst.APP_FILES_GET_PROPERTY,parameter: ["paths":paths])
  }

  //修改文件类型
  //path 文件路径
  //contentType 文件类型
  static func setContentType(path: String,contentType: String) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_FILES_SET_CONTENT_TYPE,parameter: ["path":path,"contentType":contentType])
  }

  static func downloadByHistory(id: Int64) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_FILES_DOWNLOAD_HISTORY_,parameter: ["id":id])
  }

  //文件预览
  //dfsId dfs文件ID
  //name 文件名
  //extra 要预览的附属文件名
  static func preview(dfsId: Int64,name: String,extra: String) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_FILES_PREVIEW_DFSID_NAME_,parameter: ["dfsId":dfsId,"name":name,"extra":extra])
  }

  //文件下载
  //name 文件名
  //folder 所在文件夹
  static func download() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_FILES_DOWNLOAD_)
  }

  //缩略图下载
  //id 文件ID
  static func thumb(id: Int64) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_FILES_THUMB_ID_,parameter: ["id":id])
  }
}