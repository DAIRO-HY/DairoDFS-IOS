//
//  DfsFileShared.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/24.
//

/// <summary>
/// DFS文件列表缓存
/// </summary>
struct DfsFileShared {
    
    ///缓存目录
    static let CACHE_FOLDER = "dfs_file_list";
    
    ///存储文件夹目录路径
    //  static String get cacheFolderPath => paths.normalize("${SyncVariable.supportPath}/$CACHE_FOLDER");
    
    //  ///请求文件列表的http请求
    //  static ApiHttp? _apiHttp;
    
    ///获取文件列表
    static func getSubList( folder: String, callback: (_ files: [FileModel]) -> Void) {
        
        //    //缓存文件名
        //    let fileName = "$CACHE_FOLDER/root_${folder.replaceAll("/", "_")}";
        
        //    //得到本地缓存的文件列表
        //    List<FileModel>? cacheFileList = fileName.localObj(FileModel.fromJsonList);
        //    if (cacheFileList == null) {
        //      callback([]);
        //    } else {
        //      callback(cacheFileList);
        //    }
        //
        //    //将上一次的请求关闭
        //    DfsFileShared._apiHttp?.cancel();
        //
        //    //Api请求文件列表
        //    final apiHttp = FilesApi.getList(folder: folder);
        //    DfsFileShared._apiHttp = apiHttp;
        //    apiHttp.finish(() async {
        //      DfsFileShared._apiHttp = null;
        //    });
        //    apiHttp.post((data) async {
        //      final isWrite = fileName.toLocalObj(data);
        //      if (isWrite) {
        //        //文件列表有更新
        //        callback(data);
        //      }
        //    });
    }
    
    ///清空缓存的文件列表
    static func clear() {
        //    let folder = Directory(DfsFileShared.cacheFolderPath);
        //    if (folder.existsSync()) {
        //      folder.deleteSync(recursive: true);
        //    }
    }
}
