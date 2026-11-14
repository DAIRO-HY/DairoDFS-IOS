//
//  AlbumViewerVideoView.swift
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
    
    
    @EnvironmentObject var vm: AlbumViewerViewModel
    
    
    public var body: some View {
        ZStack {
            Color.black
            if self.vm.videoIsPlayed{//如果视频播放过
                
                // 创建一个 AVPlayer 实例
                if let player = self.vm.videoPlayer{
                    VideoPlayer(player: self.vm.videoPlayer)
                        .frame(width: self.vm.screenWidth, height: self.vm.screenHeight)
                    
                    //                VideoPlayerView(player: player)
                    //                Color.red.frame(width: self.vm.screenWidth, height: self.vm.screenHeight).opacity(0.5)
                }
            }
            if !self.vm.videoIsPlayed || self.vm.videoIsLoading{//视频还没有开始播放时显示缩略图,否则加载期间是黑屏
                DfsImage(self.vm.fm.thumbSource, contentMode: .fit)
                    .frame(width: self.vm.screenWidth, height: self.vm.screenHeight)
            }
        }
        .onChange(of: self.vm.showActionView){ _ in
            if self.vm.showActionView{
                if self.vm.videoIsPlaying{
                    self.vm.startVideoTimer()
                }
            }else{
                self.vm.videoTimer?.invalidate()
            }
        }
        .edgesIgnoringSafeArea(.all)//忽略安全区域
    }
}

//#Preview {
//    ImageViewerPage(ImageViewerViewModel())
//}
