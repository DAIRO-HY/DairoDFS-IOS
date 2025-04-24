
struct FolderSelectorApi {

  //获取文件夹结构
  static func getList(folder: String) -> ApiHttp<[FolderModel]>{
    return ApiHttp<[FolderModel]>(ApiConst.APP_FOLDER_SELECTOR_GET_LIST,parameter: ["folder":folder])
  }
}