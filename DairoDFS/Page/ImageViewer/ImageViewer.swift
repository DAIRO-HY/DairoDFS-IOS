//
//  ImageViewerPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/05.
//

import SwiftUI
import DairoUI_IOS

struct ImageViewer: View {
    
    
    @State private var progress = ""
    
    ///刷新图标标识
    @State private var freshImage: UInt64 = 0
    
    private let url: String
    
    @ObservedObject private var dragVM: ImageViewerDragViewModel
    
    init(_ url: String, _ vm: ImageViewerDragViewModel) {
        self.url = url
        self.dragVM = vm
    }
    
    public var body: some View {
        ZStack {
            Color.black
            if let uiImage = self.dragVM.uiImage{
                Image(uiImage: uiImage)
                    .resizable()
                    .scaleEffect(self.dragVM.zoomAmount * self.dragVM.zoomingAmount)
                    .scaledToFill()
                    .aspectRatio(contentMode: .fit)
                    .offset(x: self.dragVM.currentOffsetPosition.width, y: self.dragVM.currentOffsetPosition.height)
                    .frame(width: self.dragVM.screenWidth, height: self.dragVM.screenHeight)
                    .clipped()
            } else {
                // 加载中
                ZStack{
                    Text(self.progress)
                    ProgressView()
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name(self.url))){
                    //                debugPrint("url2count = \(DownloadBridge.url2count[self.url])   url2downloading = \(DownloadBridge.url2downloading.count)")
                    let msg = $0.object as! String
                    //                print(msg)
                    if msg.starts(with: "p:"){//下载进度
                        let data = msg.split(separator: ":")
                        self.progress = String(Int(Float64(data[2])! / Float64(data[1])! * 100)) + "%"
                    } else if msg.starts(with: "f:nil"){//下载完成
                        
                        //重新加载图片
                        self.dragVM.setUrl(self.url)
                    } else if msg.starts(with: "f:"){//下载失败
                        self.progress = "加载失败"
                    }
                }
                .onAppear(perform: self.dragVM.fixCropImage )
                .onDisappear{//视图被注销时,取消下载
                    CacheImageHelper.cancel(self.url)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)//忽略安全区域
    }
}

//#Preview {
//    ImageViewerPage(ImageViewerViewModel())
//}
