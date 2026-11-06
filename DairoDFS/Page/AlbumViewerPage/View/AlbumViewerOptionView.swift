//
//  FileOptionBarView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import AVFoundation
import SwiftUI
import DairoUI_IOS
import DairoFileSDK

struct AlbumViewerOptionView: View {
    
    @EnvironmentObject var vm: AlbumViewerViewModel
    @State private var showDeleteAlert = false
    
    /// 视频分辨率选择框是否显示
    @State private var showVideoResolutionActionMenu = false
    
    var body: some View {
        VStack(spacing: 0){
            Spacer()
            if self.vm.isVideo{//如果这是一个视频的话
                ZStack{
                    VStack{
                        Spacer().frame(height: 10)
                        Slider(
                            value: self.$vm.videoCurrentTime,
                            in:0 ... self.vm.videoDuration,
                            step: 1,
                            onEditingChanged:  { flag in//true:代表编辑开始。 false:代表编辑结束
#if DEBUG
                                debugPrint("-->拖动编辑状态:\(flag)  值:\(self.vm.videoCurrentTime)")
#endif
                                self.vm.videoSliderDragging = flag
                                if !flag{//拖动结束
                                    let time = CMTime(seconds: self.vm.videoCurrentTime / 1000, preferredTimescale: 600)
                                    self.vm.videoPlayer?.seek(to: time)
                                }
                            }
                        )
                        HStack{
                            Text(self.vm.videoCurrentTime.timeFormat).font(.subheadline)
                            Spacer()
                            Text(self.vm.videoDuration.timeFormat).font(.subheadline)
                        }
                        .foregroundColor(.primary)
                        
                        Spacer().frame(height: 10)
                    }
                    .padding(.horizontal, 8)
                    .liquidGlassBackground(in: RoundedRectangle(cornerRadius: 20))
                    .environment(\.colorScheme, .dark)//视频背景是黑色的,浅色模式下也使用深色
                }
                .padding()
            }
            
            HStack{
                //                BottomOptionButton("分享", icon: "square.and.arrow.up", action: self.vm.onShareClick)
                
                OptionButton("删除", icon: "trash"){
                    self.showDeleteAlert = true
                }
                .alert("确认删除吗？", isPresented: $showDeleteAlert) {
                    Button("删除", role: .destructive) {
                        self.vm.onDeleteClick()
                    }
                    Button("取消", role: .cancel) { }
                } message: {
                    Text("此操作无法撤销")
                }

                //下载进度显示在加载提示里,下载期间不能再次点击
                OptionButton("下载", icon: "square.and.arrow.down", disabled: self.vm.isDownloading){
                    self.vm.onDownloadOnlyClick()
                }
                OptionButton("保存", icon: "rectangle.stack.badge.plus", disabled: self.vm.isDownloading){
                    self.vm.onDownloadOnlyClick(true)
                }
                
                if self.vm.isImage{//图片时
                    OptionButton("原图", icon: "photo.on.rectangle.angled", disabled: self.vm.isShowDownloaded){
                        self.vm.onLoadOriginalClick()
                    }
                } else {//视频时
                    OptionButton(self.vm.videoQualityLabel, icon: "play.rectangle", disabled: self.vm.isShowDownloaded){
                        self.showVideoResolutionActionMenu.toggle()
                    }
                }
                OptionButton("属性", icon: "info.circle", action: self.vm.onInfoClick)
            }
            Color.clear.frame(height: 40)
        }
        .frame(maxHeight: .infinity)
        .onReceive(NotificationCenter.default.publisher(for: FileSdkUtil.EVENT)){//文件下载时监听
            self.vm.onFileSdkEvent($0.object as! Event)
        }
        .confirmationDialog("视频清晰度", isPresented: self.$showVideoResolutionActionMenu, titleVisibility: .visible) {
            Button("\(SettingShared.videoQuality == SettingShared.VIDEO_QUALITY_AUTO ? "✓" : "")自动") {
                SettingShared.videoQuality = SettingShared.VIDEO_QUALITY_AUTO
                self.vm.videoQualityLabel = SettingShared.videoQualityLabel
                self.vm.onVideoSelectResolutionClick()
            }
            Button("\(SettingShared.videoQuality == SettingShared.VIDEO_QUALITY_ORIGINAL ? "✓" : "")原画") {
                SettingShared.videoQuality = SettingShared.VIDEO_QUALITY_ORIGINAL
                self.vm.videoQualityLabel = SettingShared.videoQualityLabel
                self.vm.onVideoSelectResolutionClick()
            }
            Button("\(SettingShared.videoQuality == SettingShared.VIDEO_QUALITY_SMOOTH ? "✓" : "")流畅") {
                SettingShared.videoQuality = SettingShared.VIDEO_QUALITY_SMOOTH
                self.vm.videoQualityLabel = SettingShared.videoQualityLabel
                self.vm.onVideoSelectResolutionClick()
            }
            Button("取消", role: .cancel) {}
        }
    }
}

#Preview {
    AlbumViewerOptionTestView()
}

struct AlbumViewerOptionTestView: View {
    
    @StateObject
    private var vm = AlbumViewerViewModel([FileModel(id: 0, name: "xxx.mp4", size: 10, fileFlag: true, date: 10, hasThumb: false)],0)
    var body: some View {
        NavigationView{
            AlbumViewerOptionView().environmentObject(self.vm)
                .navigationTitle("下载页面")
        }
    }
}
