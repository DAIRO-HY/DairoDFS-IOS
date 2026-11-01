enum TrashApi {

  //获取回收站文件列表
  static func getList() -> ApiHttp<[TrashModel]>{
    return ApiHttp<[TrashModel]>(ApiConst.TRASH_LIST,method: "GET")
  }

  //彻底删除文件
  //ids 选中的文件ID列表
  static func delete(ids: [Int64]) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.TRASH_DELETE,method: "DELETE",parameter: ["ids":ids])
  }

  //从垃圾箱还原文件
  //ids 选中的文件ID列表
  static func recover(ids: [Int64]) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.TRASH_RECOVER,method: "PUT",parameter: ["ids":ids])
  }
}
