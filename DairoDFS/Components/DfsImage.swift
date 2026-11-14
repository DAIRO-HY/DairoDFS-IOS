//
//  DfsImage.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/01.
//

import SwiftUI
import DairoFileSDK

/**
 通过SDK加载DFS图片的视图,尺寸由调用方通过frame指定
 视图消失时连接断开,SDK会自动取消下载
 */
struct DfsImage: View {
    
    ///已解码图片的内存缓存,避免列表滑动时重新解码
    private static let memoryCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 300
        
        //分组列表的大图占用内存较多,这里同时限制总大小
        cache.totalCostLimit = 200 * 1024 * 1024
        return cache
    }()
    
    /// 请求的都是SDK的本机服务,真正的下载并发由SDK控制
    /// URLSession.shared在iOS上同一个地址最多同时4个连接,在线生成的图片很慢时,已经缓存好的缩略图也要排在后面等待
    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 64
        
        //SDK已经缓存了图片,这里不用再缓存
        config.urlCache = nil
        return URLSession(configuration: config)
    }()
    
    /// 重新加载失败图片的通知
    private static let RETRY = Notification.Name("DfsImage.RETRY")
    
    /// 重新加载所有加载失败的图片,比如服务器刚上传完文件还在生成缩略图时,超时失败的图片
    static func retryFailed(){
        NotificationCenter.default.post(name: DfsImage.RETRY, object: nil)
    }
    
    private let source: FileSource
    
    ///图片加载中或加载失败时显示的图片
    private let fallback: FileSource?
    
    ///图片显示出来之前的占位图标,不指定时加载中显示空白
    private let placeholder: String?
    
    //填充模式
    private let contentMode: ContentMode
    
    @State private var uiImage: UIImage?
    
    ///图片是否加载失败
    @State private var isFail = false
    
    ///重试次数,改变时重新加载
    @State private var retryCount = 0
    
    init(_ source: FileSource, fallback: FileSource? = nil, placeholder: String? = nil, contentMode: ContentMode = .fill) {
        self.source = source
        self.fallback = fallback
        self.placeholder = placeholder
        self.contentMode = contentMode
    }
    
    var body: some View {
        ZStack{
            if let uiImage = self.uiImage{
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: self.contentMode)
            } else if let fallback = self.fallback{
                DfsImage(fallback, placeholder: self.placeholder, contentMode: self.contentMode)
            } else if let placeholder = self.placeholder{
                ImagePlaceholder(placeholder)
            } else if self.isFail{
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.secondary)
                    .padding(8)
            } else {
                Color.clear
            }
        }
        .task(id: "\(self.source.cacheKey)#\(self.retryCount)"){
            await self.load()
        }
        .onReceive(NotificationCenter.default.publisher(for: DfsImage.RETRY)){ _ in
            
            //正在加载的不用重试,否则会取消之后重新排队
            if self.isFail{
                self.retryCount += 1
            }
        }
    }
    
    /// 加载图片
    private func load() async {
        let key = self.source.cacheKey as NSString
        if let uiImage = DfsImage.memoryCache.object(forKey: key){
            self.uiImage = uiImage
            self.isFail = false
            return
        }
        self.uiImage = nil
        self.isFail = false
        let uiImage = await self.loadImage()
        if Task.isCancelled{
            return
        }
        guard let uiImage else{
            self.isFail = true
            return
        }
        let cost = Int(uiImage.size.width * uiImage.size.height * uiImage.scale * uiImage.scale * 4)
        DfsImage.memoryCache.setObject(uiImage, forKey: key, cost: cost)
        self.uiImage = uiImage
    }
    
    /// 已经下载完成的图片直接读文件,否则通过SDK的本机服务加载
    /// App挂起或锁屏后iOS会收回本机服务的端口,已经缓存的图片直接读文件不受影响
    private func loadImage() async -> UIImage? {
        var local = FileSdkUtil.localSource(self.source)
        if case .file(let path) = local{
            let uiImage = await Task.detached{
                return UIImage(contentsOfFile: path)?.preparingForDisplay()
            }.value
            if let uiImage{
                return uiImage
            }
            
            //拿到路径之后文件正好被清理掉了,再获取一次,这时会返回本机地址
            local = FileSdkUtil.localSource(self.source)
        }
        guard case .http(let urlStr) = local, let url = URL(string: urlStr) else{
            return nil
        }
        guard let (data, response) = try? await DfsImage.session.data(from: url),
              (response as? HTTPURLResponse)?.statusCode == 200 else{
            return nil
        }
        return await Task.detached{
            return UIImage(data: data)?.preparingForDisplay()
        }.value
    }
}
