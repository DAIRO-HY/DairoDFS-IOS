//
//  AlbumViewerBackdropView.swift
//  DairoDFS
//

import SwiftUI

/// 查看页的背景,图片不够显示的区域用模糊的缩略图填充,视频是黑色
struct AlbumViewerBackdropView: View {
    
    ///先缩小再模糊,减少模糊的计算量
    private static let SCALE: CGFloat = 4
    
    ///模糊半径(缩小之后的尺寸)
    private static let BLUR_RADIUS: CGFloat = 10
    
    ///压暗程度,让图片和背景有明显的边界
    private static let DIM_OPACITY = 0.25
    
    @EnvironmentObject var vm: AlbumViewerViewModel
    
    var body: some View {
        ZStack{
            Color.black
            ForEach([self.vm.currentIndex - 1, self.vm.currentIndex, self.vm.currentIndex + 1].filter{ self.vm.fileModels.indices.contains($0) }, id: \.self){ index in
                self.getBackdrop(self.vm.fileModels[index])
                    .opacity(self.getOpacity(index))
                    .zIndex(index == self.vm.currentIndex ? 0 : 1)
            }
            Color.black.opacity(AlbumViewerBackdropView.DIM_OPACITY)
        }
        .frame(width: self.vm.screenWidth, height: self.vm.screenHeight)
        .clipped()
        .allowsHitTesting(false)
    }
    
    /// 一个文件的背景
    @ViewBuilder
    private func getBackdrop(_ fm: FileModel) -> some View{
        if fm.isVideo || !fm.hasThumb{
            Color.black
        } else {
            DfsImage(fm.thumbSource)
                .frame(width: self.vm.screenWidth / AlbumViewerBackdropView.SCALE, height: self.vm.screenHeight / AlbumViewerBackdropView.SCALE)
                .clipped()
                .blur(radius: AlbumViewerBackdropView.BLUR_RADIUS, opaque: true)
                .scaleEffect(AlbumViewerBackdropView.SCALE)
        }
    }
    
    /// 背景的透明度,滑动页面时当前页的背景不变,要切换到的页面的背景逐渐显示出来
    private func getOpacity(_ index: Int) -> Double{
        if index == self.vm.currentIndex{
            return 1
        }
        if self.vm.screenWidth == 0{
            return 0
        }
        
        //滑动进度,向左滑动切换到下一张时为正数
        let progress = (-CGFloat(self.vm.currentIndex + 1) * self.vm.screenWidth - self.vm.hStackOffset) / self.vm.screenWidth
        let isTarget = index > self.vm.currentIndex ? progress > 0 : progress < 0
        return isTarget ? Double(min(abs(progress), 1)) : 0
    }
}
