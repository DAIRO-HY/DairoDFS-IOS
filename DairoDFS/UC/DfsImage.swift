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
        return cache
    }()
    
    private let source: FileSource
    
    //填充模式
    private let contentMode: ContentMode
    
    @State private var uiImage: UIImage?
    
    ///图片是否加载失败
    @State private var isFail = false
    
    init(_ source: FileSource, contentMode: ContentMode = .fill) {
        self.source = source
        self.contentMode = contentMode
    }
    
    var body: some View {
        ZStack{
            if let uiImage = self.uiImage{
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: self.contentMode)
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
        .task(id: self.source.cacheKey){
            await self.load()
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
        guard let url = FileSdkUtil.localUrl(self.source) else{
            self.isFail = true
            return
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            let uiImage = await Task.detached{
                return UIImage(data: data)?.preparingForDisplay()
            }.value
            if Task.isCancelled{
                return
            }
            guard (response as? HTTPURLResponse)?.statusCode == 200, let uiImage else{
                self.isFail = true
                return
            }
            DfsImage.memoryCache.setObject(uiImage, forKey: key)
            self.uiImage = uiImage
        } catch {
            if !Task.isCancelled{
                self.isFail = true
            }
        }
    }
}
