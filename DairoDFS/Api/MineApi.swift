enum MineApi {

  //获取当前用户信息
  static func info() -> ApiHttp<MineModel>{
    return ApiHttp<MineModel>(ApiConst.MINE_INFO,method: "GET")
  }
}
