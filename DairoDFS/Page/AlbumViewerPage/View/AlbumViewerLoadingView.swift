//
//  AlbumViewerLoadingView.swift
//  DairoDFS
//

import SwiftUI

/// 加载大图、原图以及下载、保存时的进度提示,显示在右上角,不响应点击和滑动,所以不影响左右滑动切换
/// 图片因为网络问题加载失败时,在同一个位置显示红色的联网失败图标
struct AlbumViewerLoadingView: View {
    
    /// 加载超过这个时间才显示,避免网络较好时提示一闪而过,单位:纳秒
    private static let SHOW_DELAY: UInt64 = 500_000_000
    
    @State private var isShow = false
    
    @EnvironmentObject var vm: AlbumViewerViewModel
    
    var body: some View {
        VStack(spacing: 0){
            
            //放在顶部按钮和时间的下方,避免屏幕较窄时重叠
            Spacer().frame(height: 106)
            HStack{
                Spacer()
                if self.isShow, let progressTip = self.vm.progressTip{
                    HStack(spacing: 4){
                        ProgressView()
                            .scaleEffect(0.8)
                        if !progressTip.isEmpty{
                            Text(progressTip)
                                .font(.caption)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                                .fixedSize()
                        }
                    }
                    .padding(.horizontal, 10)
                    .frame(height: 32)
                    .liquidGlassBackground(in: Capsule())
                } else if self.vm.isNetworkFail{
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(width: 44, height: 32)
                        .liquidGlassBackground(in: Capsule())
                }
            }
            .padding(.trailing, 8)
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .allowsHitTesting(false)
        .task(id: self.vm.progressTip != nil){
            self.isShow = false
            if self.vm.progressTip != nil{
                try? await Task.sleep(nanoseconds: AlbumViewerLoadingView.SHOW_DELAY)
                if !Task.isCancelled{
                    self.isShow = true
                }
            }
        }
    }
}
