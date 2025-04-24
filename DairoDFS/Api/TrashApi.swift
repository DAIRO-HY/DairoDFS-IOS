
struct TrashApi {

  static func html() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_TRASH_HTML)
  }

  //获取回收站文件列表
  static func getList() -> ApiHttp<[TrashModel]>{
    return ApiHttp<[TrashModel]>(ApiConst.APP_TRASH_GET_LIST)
  }

  //彻底删除文件
  //ids 选中的文件ID列表
  static func logicDelete(ids: [Int64]) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_TRASH_LOGIC_DELETE,parameter: ["ids":ids])
  }

  //从垃圾箱还原文件
  //ids 选中的文件ID列表
  static func trashRecover(ids: [Int64]) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_TRASH_TRASH_RECOVER,parameter: ["ids":ids])
  }

  //立即回收储存空间
  static func recycleStorage() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.APP_TRASH_RECYCLE_STORAGE)
  }
}