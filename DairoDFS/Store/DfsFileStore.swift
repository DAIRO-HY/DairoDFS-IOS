//
//  DfsFileStore.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/24.
//

/// <summary>
/// DFS文件列表缓存
/// </summary>
enum DfsFileStore {
    
    ///文件列表加载器
    private static let loader = CachedListLoader()
    
    ///获取文件列表,所有回调都在主线程
    /// - Parameter noCache: 本地没有缓存,需要等待服务器返回
    /// - Parameter failed: 请求服务器失败
    /// - Parameter callback: 文件列表
    static func getSubList(_ folder: String, noCache: @escaping () -> Void, failed: @escaping () -> Void, callback: @escaping (_ files: [FileModel]) -> Void) {
        var fileName = folder
        if #available(iOS 16.0, *) {
            fileName.replace("/",with: "_")
        } else {
            fileName = fileName.replacingOccurrences(of: "/", with: "_")
        }
        
        //缓存文件名,不同账号的缓存互相隔离
        let cacheName = SettingStore.accountObjectName("file_list_root_\(fileName)")
        DfsFileStore.loader.load(
            cacheName: cacheName,
            http: FilesApi.getList(folder: folder).hide(),
            failMsg: "加载文件列表失败",
            toList: { $0.list },
            noCache: noCache,
            failed: failed,
            callback: callback
        )
    }
}
