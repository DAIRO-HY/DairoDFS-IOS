struct FileListModel : Codable {

  	/** 当前文件夹ID **/
  var folderId: Int64

  	/** 文件列表 **/
  var list: [FileModel]

}
