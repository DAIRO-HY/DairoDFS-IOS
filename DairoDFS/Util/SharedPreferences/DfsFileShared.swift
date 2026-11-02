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
    
    ///请求文件列表的http请求
    private static var _apiHttp: ApiHttp<FileListModel>?
    
    ///获取文件列表
    static func getSubList(_ folder: String, callback: @escaping (_ files: [FileModel]) -> Void) {
        var fileName = folder
        if #available(iOS 16.0, *) {
            fileName.replace("/",with: "_")
        } else {
            fileName = fileName.replacingOccurrences(of: "/", with: "_")
        }
        
        //缓存文件名,不同账号的缓存互相隔离
        let cacheName = SettingShared.accountObjectName("file_list_root_\(fileName)")
        
        //得到本地缓存的文件列表
        if let cacheName, let cacheFileList = LocalObjectUtil.read([FileModel].self, cacheName){
            callback(cacheFileList)
        }
        
        //将上一次的请求关闭
        DfsFileShared._apiHttp?.cancel()
        
        //Api请求文件列表
        DfsFileShared._apiHttp = FilesApi.getList(folder: folder).hide().fail{
            Toast.show($0.msg ?? "加载文件列表失败")
        }.finish{
            DfsFileShared._apiHttp = nil
        }.send{
            let list = $0.list
            
            //文件列表没有更新时不需要回调
            if let cacheName, !LocalObjectUtil.write(list, cacheName){
                return
            }
            callback(list);
        }
    }
}
