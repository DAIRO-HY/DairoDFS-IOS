//
//  AlbumViewerImageView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/05.
//

import SwiftUI
import DairoUI_IOS
import _AVKit_SwiftUI

struct AlbumViewerImageView: View {
    
    
    @EnvironmentObject var vm: AlbumViewerViewModel
    
    public var body: some View {
        ZStack {
            if let uiImage = self.vm.uiImage{
                Image(uiImage: uiImage)
                    .resizable()
                    .scaleEffect(self.vm.zoomAmount)
                    .scaledToFill()
                    .aspectRatio(contentMode: .fit)
                    .offset(x: self.vm.currentOffsetPosition.width, y: self.vm.currentOffsetPosition.height)
                    .frame(width: self.vm.screenWidth, height: self.vm.screenHeight)
                    .clipped()
            }
            if self.vm.fm.isDlive{
                AlbumViewerDliveView(self.vm.dliveVm)
            }
            if !self.vm.errorMsg.isEmpty{
                Text(self.vm.errorMsg)
                    .foregroundColor(.white)
                    .shadow(color: .black,radius: 3, x: 2, y: 2)
            }
        }
        
        .onAppear(perform: self.vm.fixCropImage)
        .onDisappear{//视图被注销时,取消下载
            self.vm.cancelFetch()
        }
        .edgesIgnoringSafeArea(.all)//忽略安全区域
    }
}

//#Preview {
//    ImageViewerPage(ImageViewerViewModel())
//}
