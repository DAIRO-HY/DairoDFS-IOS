//
//  FileOptionBarView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import AVFoundation
import SwiftUI
import DairoUI_IOS

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
                        .foregroundColor(.white)
                        
                        Spacer().frame(height: 10)
                    }
                    .padding(.horizontal, 8)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(20)       // 圆角半径
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
                if self.vm.isDownloadFlag{//下载模式
                    OptionButton(self.vm.progress, icon: "square.and.arrow.down"){}
                } else {
                    OptionButton("下载", icon: "square.and.arrow.down"){
                        self.vm.onDownloadOnlyClick()
                    }
                }
                OptionButton("保存", icon: "rectangle.stack.badge.plus"){
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
            }
            Color.clear.frame(height: 40)
        }
        .frame(maxHeight: .infinity)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name(self.vm.fm.downloadId))){//文件下载时监听
            let userInfo = $0.userInfo!
            switch userInfo["key"] as! DownloadNotify{
            case .progress:/// 进度回调
                // 进度参数是一个数组,数组内容分别是 总大小,已下载大小,下载速度
                let progress = userInfo["value"] as! [Int64]
                self.vm.progress = String(Int(Float64(progress[1]) / Float64(progress[0]) * 100)) + "%"
            case .pause:
                break
            case .finish:
                if let error = userInfo["value"] as? Error {
                    if let error = error as? DownloaderError{
                        if case let .error(msg) = error {
                            self.vm.progress = msg
                        }
                    } else {
                        self.vm.progress = error.localizedDescription
                    }
                } else {
                    self.vm.progress = ""
                }
                
                //文件下载完成后的操作
                self.vm.downloadFinish()
            }
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

struct OptionButton: View {
    
    ///标题
    private let label: String
    
    ///图标
    private let icon: String
    
    ///字体颜色
    //    final Color? color;
    
    ///是否禁用
    private let disabled: Bool
    
    ///点击回调事件
    private let action: () -> Void
    
    public init(_ label: String, icon: String, disabled: Bool = false, action: @escaping () -> Void) {
        self.label = label
        self.icon = icon
        self.disabled = disabled
        self.action = action
    }
    
    public var body: some View {
        Button(action: self.action){
            VStack(spacing: 0){
                Image(systemName: self.icon)
                Text(self.label)
                    .font(.footnote)
                    .padding(.top, 1)
            }
            .foregroundColor(.white)
            .frame(width: 50, height: 50)
            .opacity(self.disabled ? 0.4 : 1)
        }
        .frame(maxWidth: .infinity)
        .background(
            Circle()
                .fill(Color.black.opacity(0.7)) // 圆形背景颜色
        )
        .buttonStyle(.row)
        .disabled(self.disabled)
    }
}



#Preview {
    AlbumViewerOptionTestView()
}

struct AlbumViewerOptionTestView: View {
    
    @StateObject
    private var vm = AlbumViewerViewModel([FileModel(id: 0, name: "xxx.mp4", size: 10, fileFlag: true, date: 10, hasThumb: false, other1: "")],0)
    var body: some View {
        NavigationView{
            AlbumViewerOptionView().environmentObject(self.vm)
                .navigationTitle("下载页面")
        }
    }
}
