//
//  DfsFileShared.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/24.
//

import DairoUI_IOS

/// <summary>
/// DFS文件列表缓存
/// </summary>
enum DfsFileShared {
    
    ///缓存目录
    static let CACHE_FOLDER = "dfs_file_list";
    
    ///存储文件夹目录路径
    //  static String get cacheFolderPath => paths.normalize("${SyncVariable.supportPath}/$CACHE_FOLDER");
    
    ///请求文件列表的http请求
    private static var _apiHttp: ApiHttp<[FileModel]>?
    
    /**
     创建文件列表缓存目录
     */
    static func makeDir(){
        let folderPath = LocalObjectUtil.mFolder + "/" + DfsFileShared.CACHE_FOLDER
        let isOk = FileUtil.mkdirs(folderPath)
        if !isOk{
            print("文件夹:\(folderPath) 创建失败")
        }
    }
    
    ///获取文件列表
    static func getSubList(_ folder: String, callback: @escaping (_ files: [FileModel]) -> Void) {
        var fileName = folder
        if #available(iOS 16.0, *) {
            fileName.replace("/",with: "_")
        } else {
            fileName = fileName.replacingOccurrences(of: "/", with: "_")
        }
        
        //缓存文件名
        fileName = "\(CACHE_FOLDER)/root_\(fileName)";
        
        //得到本地缓存的文件列表
        if let cacheFileList = LocalObjectUtil.read([FileModel].self, fileName){
            callback(cacheFileList)
        }
        
        //将上一次的请求关闭
        DfsFileShared._apiHttp?.cancel()
        
        //Api请求文件列表
        DfsFileShared._apiHttp = FilesApi.getList(folder: folder).hide().finish{
            DfsFileShared._apiHttp = nil
        }.post{
            let isWrite = LocalObjectUtil.write($0, fileName)
            if (isWrite) {
                
                //文件列表有更新
                callback($0);
            }
        }
    }
    
    ///清空缓存的文件列表
    static func clear() {
        //    let folder = Directory(DfsFileShared.cacheFolderPath);
        //    if (folder.existsSync()) {
        //      folder.deleteSync(recursive: true);
        //    }
    }
}
