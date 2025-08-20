//
//  FileOptionBarView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

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
            }.background(Color.gl.bgPrimary)
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
