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
    
    /// 是否跳转设置页面
    @State var isShowSet = false
    
    var body: some View {
        VStack(spacing: 0){
            Spacer()
            Divider()
            if self.vm.isVideo{
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
                            self.vm.videoSliderDarging = flag
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
                .background(Color.gl.bgPrimary)
            }
            
            HStack{
                BottomOptionButton("分享", icon: "square.and.arrow.up", action: self.vm.onShareClick)
                BottomOptionButton("删除", icon: "trash"){
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
                    BottomOptionButton(self.vm.progress, icon: "square.and.arrow.down"){}
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
                                }
                                
                                //文件下载完成后的操作
                                self.vm.downloadFinish()
                            }
                        }
                } else {
                    BottomOptionButton("下载", icon: "square.and.arrow.down"){
                        self.vm.onDownloadOnlyClick()
                    }
                }
                BottomOptionButton("保存相册", icon: "rectangle.stack.badge.plus"){
                    self.vm.onDownloadOnlyClick(true)
                }
//                BottomOptionButton("播放", icon: "square.and.arrow.up"){
//                    self.vm.videoPlayer?.play()
//                }
//                BottomOptionButton("暂停", icon: "square.and.arrow.up"){
//                    self.vm.videoPlayer?.pause()
//                }
            }
            .background(Color.gl.bgPrimary)
            Color.gl.bgPrimary.frame(height: 40)
        }
        .frame(maxHeight: .infinity)
    }
}


//#Preview {
//    AlbumViewerOptionTestView()
//}
//
//struct AlbumViewerOptionTestView: View {
//
//    @StateObject
//    private var vm = AlbumViewerViewModel()
//    var body: some View {
//        NavigationView{
//            AlbumViewerOptionView().environmentObject(self.vm)
//                .navigationTitle("下载页面")
//        }
//    }
//}
