//
//  CachedListLoader.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/03.
//

import Foundation
import DairoUI_IOS

/// <summary>
/// 加载文件列表,先显示本地缓存,再从服务器更新
/// 数据量可能很大,缓存读写都不在主线程。所有回调都在主线程
/// </summary>
final class CachedListLoader {
    
    ///读写缓存的队列,串行执行可以保证先读完缓存,再写入新数据
    private static let cacheQueue = DispatchQueue(label: "CachedListLoader.cache")
    
    ///最后一次请求的序号,发起新请求之后,之前请求的结果不再回调
    private var requestId = 0
    
    ///取消当前请求
    private var cancelRequest: (() -> Void)?
    
    /**
     加载列表
     - Parameter cacheName: 缓存名,为nil时不使用缓存
     - Parameter http: 列表请求
     - Parameter failMsg: 服务器没有返回错误信息时的提示
     - Parameter toList: 将服务器返回的数据转换成列表,不在主线程执行
     - Parameter noCache: 本地没有缓存,需要等待服务器返回
     - Parameter failed: 请求服务器失败
     - Parameter callback: 文件列表
     */
    func load<T>(cacheName: String?,
                 http: ApiHttp<T>,
                 failMsg: String,
                 toList: @escaping (_ data: T) -> [FileModel],
                 noCache: @escaping () -> Void,
                 failed: @escaping () -> Void,
                 callback: @escaping (_ list: [FileModel]) -> Void) {
        self.requestId += 1
        let requestId = self.requestId
        
        //是否已经显示了本地缓存的列表
        var isCacheShown = false
        
        //得到本地缓存的列表
        CachedListLoader.cacheQueue.async {
            let cacheList = cacheName.flatMap{ LocalObjectUtil.read([FileModel].self, $0) }
            DispatchQueue.main.async {
                guard requestId == self.requestId else{
                    return
                }
                if let cacheList{
                    isCacheShown = true
                    callback(cacheList)
                } else {
                    noCache()
                }
            }
        }
        
        //将上一次的请求关闭
        self.cancelRequest?()
        
        let onFail = { (msg: String) in
            guard requestId == self.requestId else{
                return
            }
            Toast.show(msg)
            failed()
        }
        
        //Api请求列表
        let request = http.fail{
            onFail($0.msg ?? failMsg)
        }.error(block: onFail).finish{
            if requestId == self.requestId{
                self.cancelRequest = nil
            }
        }
        self.cancelRequest = { request.cancel() }
        request.send{ data in
            CachedListLoader.cacheQueue.async {
                let list = toList(data)
                let isChanged = cacheName.map{ LocalObjectUtil.write(list, $0) } ?? true
                DispatchQueue.main.async {
                    guard requestId == self.requestId else{
                        return
                    }
                    
                    //列表没有更新时不需要回调
                    if isChanged || !isCacheShown{
                        callback(list)
                    }
                }
            }
        }
    }
    
    /// 删除缓存,在这之后发起的加载不会读到这个缓存
    static func deleteCache(_ cacheName: String) {
        CachedListLoader.cacheQueue.async {
            LocalObjectUtil.delete(cacheName)
        }
    }
}
