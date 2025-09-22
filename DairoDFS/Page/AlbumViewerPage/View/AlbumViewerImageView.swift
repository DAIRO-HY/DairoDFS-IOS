//
//  ImageViewerPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/05.
//

import SwiftUI
import DairoUI_IOS

struct AlbumViewerImageView: View {
    
    ///刷新图标标识
    @State private var freshImage: UInt64 = 0
    
    @EnvironmentObject var vm: AlbumViewerViewModel
    
    public var body: some View {
        ZStack {
            if let uiImage = self.vm.uiImage{
                Image(uiImage: uiImage)
                    .resizable()
                    .scaleEffect(self.vm.zoomAmount * self.vm.zoomingAmount)
                    .scaledToFill()
                    .aspectRatio(contentMode: .fit)
                    .offset(x: self.vm.currentOffsetPosition.width, y: self.vm.currentOffsetPosition.height)
                    .frame(width: self.vm.screenWidth, height: self.vm.screenHeight)
                    .clipped()
            }
            if let dlivePlayer = self.vm.dlivePlayer{
                VideoPlayer(player: self.vm.dlivePlayer)
                .frame(width: self.vm.screenWidth, height: self.vm.screenHeight)
            }
            if !self.vm.progress.isEmpty{
                Text(self.vm.progress)
                    .foregroundColor(.white)
                    .shadow(color: .black,radius: 3, x: 2, y: 2)
            }
        }
        
        //加载原图通知
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name(self.vm.fm.previewDownloadId)), perform: self.loadImageNotity)
        
        //加载原缩略图通知
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name(self.vm.fm.thumbDownloadId)), perform: self.loadImageNotity)
        .onAppear(perform: self.vm.fixCropImage)
        .onDisappear{//视图被注销时,取消下载
            DownloadManager.cancel(self.vm.fm.previewDownloadId)
        }
        .edgesIgnoringSafeArea(.all)//忽略安全区域
    }
    
    /// 加载图片通知事件
    private func loadImageNotity(npo: NotificationCenter.Publisher.Output){
        let userInfo = npo.userInfo!
        switch userInfo["key"] as! DownloadNotify{
        case .progress:/// 进度回调
            // 进度参数是一个数组,数组内容分别是 总大小,已下载大小,下载速度
            let progress = userInfo["value"] as! [Int64]
            self.vm.progress = String(Int(Float64(progress[1]) / Float64(progress[0]) * 100)) + "%"
        case .pause:
            break
        case .finish:
            guard let error = userInfo["value"] as? Error else{
                
                //刷新视图
                self.vm.loadPicture()
                return
            }
            if let error = error as? DownloaderError{
                if case let .error(msg) = error {
                    self.vm.progress = msg
                }
            } else {
                self.vm.progress = error.localizedDescription
            }
        }
    }
}

//#Preview {
//    ImageViewerPage(ImageViewerViewModel())
//}
