import Foundation

enum MineApi {

  //获取当前用户信息
  static func info() -> ApiHttp<MineModel>{
    return ApiHttp<MineModel>(ApiConst.MINE_INFO,method: "GET")
  }

  //修改昵称,可以为空
  static func nickname(nickname: String) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.MINE_NICKNAME,method: "PUT",parameter: ["nickname":nickname])
  }

  //上传头像,服务器会裁剪成正方形
  static func uploadAvatar(jpeg: Data) -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.MINE_AVATAR,method: "POST").file(name: "file",fileName: "avatar.jpg",mimeType: "image/jpeg",data: jpeg)
  }

  //删除头像
  static func deleteAvatar() -> ApiHttp<EmptyModel>{
    return ApiHttp<EmptyModel>(ApiConst.MINE_AVATAR,method: "DELETE")
  }
}
