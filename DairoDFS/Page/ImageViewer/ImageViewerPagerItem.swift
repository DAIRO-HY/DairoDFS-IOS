//
//  ImageViewerPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/05.
//

import SwiftUI
import DairoUI_IOS

struct ImageViewerPagerItem: View {
    
    
    @State private var progress = ""
    
    ///刷新图标标识
    @State private var freshImage: UInt64 = 0
    
    private let url: String
    
    @ObservedObject private var dragVM: ImageViewerDragViewModel
    
    init(_ url: String, _ vm: ImageViewerDragViewModel) {
        self.url = url
        self.dragVM = vm
    }
    
    var body: some View {
        if self.freshImage > 0{
            //用来下载完成之后更新视图,不做任何处理
        }
        if self.dragVM.uiImage != nil{
            ImageViewer(self.dragVM)
        } else {
            // 加载中
            ZStack{
                Text(self.progress)
                ProgressView().onAppear{
                    self.dragVM.setUrl(self.url)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name(self.url))){
                //                debugPrint("url2count = \(DownloadBridge.url2count[self.url])   url2downloading = \(DownloadBridge.url2downloading.count)")
                let msg = $0.object as! String
                //                print(msg)
                if msg.starts(with: "p:"){//下载进度
                    let data = msg.split(separator: ":")
                    self.progress = String(Int(Float64(data[2])! / Float64(data[1])! * 100)) + "%"
                } else if msg.starts(with: "f:nil"){//下载完成
                    self.dragVM.setUrl(self.url)
//                    self.freshImage += 1
                } else if msg.starts(with: "f:"){//下载失败
                    self.progress = "加载失败"
                }
            }
            .onDisappear{//视图被注销时,取消下载
                CacheImageHelper.cancel(self.url)
            }
//            .frame(width: self.width, height: self.height)
        }
    }
}

#Preview {
    ImageViewerPage(ImageViewerViewModel())
}
