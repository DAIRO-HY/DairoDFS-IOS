//
//  ImageViewerPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/05.
//

import SwiftUI
import DairoUI_IOS
import AVFoundation
import AVKit

struct AlbumViewerVideoView: View {
    
    
    @State private var progress = ""
    
    ///刷新图标标识
    @State private var freshImage: UInt64 = 0
    
    @EnvironmentObject var vm: AlbumViewerViewModel
    
    
    public var body: some View {
        ZStack {
            Color.black
            
            // 创建一个 AVPlayer 实例
            if let player = self.vm.videoPlayer{
                VideoPlayer(player: self.vm.videoPlayer)
                //                    .scaleEffect(self.dragVM.zoomAmount * self.dragVM.zoomingAmount)
                //                    .scaledToFill()
                //                .aspectRatio(contentMode: .fit)
                //                    .offset(x: self.dragVM.currentOffsetPosition.width, y: self.dragVM.currentOffsetPosition.height)
                    .frame(width: self.vm.screenWidth, height: self.vm.screenHeight)
                //                    .clipped()
                //                .onAppear {
                //                    player.play() // 自动播放
                //                }
            }
            
            
            
            //            if let uiImage = self.vm.uiImage{
            //                Image(uiImage: uiImage)
            //                    .resizable()
            //                    .scaleEffect(self.vm.zoomAmount * self.vm.zoomingAmount)
            //                    .scaledToFill()
            //                    .aspectRatio(contentMode: .fit)
            //                    .offset(x: self.vm.currentOffsetPosition.width, y: self.vm.currentOffsetPosition.height)
            //                    .frame(width: self.vm.screenWidth, height: self.vm.screenHeight)
            //                    .clipped()
            //            } else {
            //                let url = self.vm.fm.thumbUrl
            //
            //                // 加载中
            //                ZStack{
            //                    Text(self.progress)
            //                    ProgressView()
            //                }
            //                .onReceive(NotificationCenter.default.publisher(for: Notification.Name(url))){
            //                    let msg = $0.object as! String
            //                    //                print(msg)
            //                    if msg.starts(with: "p:"){//下载进度
            //                        let data = msg.split(separator: ":")
            //                        self.progress = String(Int(Float64(data[2])! / Float64(data[1])! * 100)) + "%"
            //                    } else if msg.starts(with: "f:nil"){//下载完成
            //
            //                        //刷新视图
            //                        self.vm.currentIndex = self.vm.currentIndex
            //                    } else if msg.starts(with: "f:"){//下载失败
            //                        self.progress = "加载失败"
            //                    }
            //                }
            //                .onAppear(perform: self.vm.fixCropImage )
            //                .onDisappear{//视图被注销时,取消下载
            //                    CacheImageHelper.cancel(url)
            //                }
            //            }
        }
        .edgesIgnoringSafeArea(.all)//忽略安全区域
    }
}

//#Preview {
//    ImageViewerPage(ImageViewerViewModel())
//}
