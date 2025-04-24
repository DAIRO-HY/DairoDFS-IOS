import 'dart:io';

import 'package:dairo_dfs_app/api/model/FileModel.dart';
import 'package:dairo_dfs_app/extension/String++.dart';
import 'package:dairo_dfs_app/api/FilesApi.dart';

//在windows平台使用/作为文件路径分隔符时会报错，使用paths.normalize(path)将路径转换成特定操作系统的分隔符
import 'package:path/path.dart' as paths;

import '../SyncVariable.dart';
import '../http/ApiHttp.dart';

/// <summary>
/// DFS文件列表缓存
/// </summary>
class DfsFileShared {
  ///缓存目录
  static const CACHE_FOLDER = "dfs_file_list";

  ///存储文件夹目录路径
  static String get cacheFolderPath => paths.normalize("${SyncVariable.supportPath}/$CACHE_FOLDER");

  ///请求文件列表的http请求
  static ApiHttp? _apiHttp;

  ///获取文件列表
  static void getSubList(String folder, void Function(List<FileModel>) callback) {
    //缓存文件名
    final fileName = "$CACHE_FOLDER/root_${folder.replaceAll("/", "_")}";

    //得到本地缓存的文件列表
    List<FileModel>? cacheFileList = fileName.localObj(FileModel.fromJsonList);
    if (cacheFileList == null) {
      callback([]);
    } else {
      callback(cacheFileList);
    }

    //将上一次的请求关闭
    DfsFileShared._apiHttp?.cancel();

    //Api请求文件列表
    final apiHttp = FilesApi.getList(folder: folder);
    DfsFileShared._apiHttp = apiHttp;
    apiHttp.finish(() async {
      DfsFileShared._apiHttp = null;
    });
    apiHttp.post((data) async {
      final isWrite = fileName.toLocalObj(data);
      if (isWrite) {
        //文件列表有更新
        callback(data);
      }
    });
  }

  ///清空缓存的文件列表
  static void clear() {
    final folder = Directory(DfsFileShared.cacheFolderPath);
    if (folder.existsSync()) {
      folder.deleteSync(recursive: true);
    }
  }
}
