//
//  AlbumShared.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/04.
//


enum AlbumShared {
///缓存目录
static let _CACHE_FOLDER = "album_list"

///请求相册列表的http请求
//static ApiHttp? _apiHttp

///获取相册列表
//static func list(void Function(List<AlbumModel>) callback) {

//  //得到本地缓存的文件列表
//  List<AlbumModel>? cacheFileList = _CACHE_FOLDER.localObj(AlbumModel.fromJsonList);
//  if (cacheFileList == null) {
//    callback([]);
//  } else {
//    callback(cacheFileList);
//  }
//
//  //将上一次的请求关闭
//  AlbumShared._apiHttp?.cancel();
//
//  //Api请求文件列表
//  final apiHttp = FilesApi.getAlbumList();
//  AlbumShared._apiHttp = apiHttp;
//  apiHttp.finish(() async {
//    AlbumShared._apiHttp = null;
//  });
//  apiHttp.post((data) async {
//    final isWrite = _CACHE_FOLDER.toLocalObj(data);
//    if (isWrite) {
//      //相册列表有更新
//      callback(data);
//    }
//  });
//}

///清空缓存的文件列表
// static void clear() {
//   final folder = Directory(AlbumShared.cacheFolderPath);
//   if (folder.existsSync()) {
//     folder.deleteSync(recursive: true);
//   }
// }
}
