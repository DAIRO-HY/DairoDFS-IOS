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

//class MidleData{
//    var fileModels = [FileModel]()
//    var index = 0
//}
//

/////由于SwiftUI内部机制,就算页面返回之后,页面的一些特殊数据不会立即被回收
/////先通过一个页面中转可以解决该问题,暂时没有更好的解决方案
//struct AlbumViewerPage: View {
//
//    private var vm: MidleData
//
//    @State var isShow = true
//
//    @Environment(\.dismiss) var dismiss
//
//
//
//    init(_ vm: MidleData) {
//        self.vm = vm
//    }
//
//    private func getImageViewerViewModel()->ImageViewerViewModel{
//        let vvm = ImageViewerViewModel()
//        vvm.initData(self.vm.fileModels, self.vm.index)
//        return vvm
//    }
//
//    var body: some View {
//        VStack{
//
//            //由于图片浏览需要消耗大量内存,如果不通过中间页面中转一下,图片浏览页面返回时,内存不会被自动回收
//            //@TODO:暂时无解
//            NavigationLink(destination: AlbumViewerRecyclePage(getImageViewerViewModel()), isActive: self.$isShow){
//                EmptyView()
//            }
//        }
//        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("BACK_IMAGE_VIEW"))){ _ in
//            self.dismiss()
//        }.onDisappear{
//            print("-->AlbumViewerPage.onDisappear")
//        }
//    }
//}

struct AlbumViewerPage: View {
    
    @Binding var showViewerPage: Bool
    
    ///记录该页面是否已经被打开过
    private static var isInited = false
    
    ///正在拖拽中的偏移量
    @GestureState private var dragingOffset: CGFloat = 0
    
    @ObservedObject private var vm: AlbumViewerViewModel
    
    init(_ vm: AlbumViewerViewModel, _ showViewerPage: Binding<Bool>) {
        self.vm = vm
        self._showViewerPage = showViewerPage
    }
    
    var body: some View {
        
        //为了实现懒加载,这里始终只显示上一张,本张,下一张共3张图片
        ZStack{
            HStack(spacing: 0) {
                
                //当前图片上一张之前的图片全部不显示,这些不显示的图片总宽度用这个占位
                Spacer().frame(width: self.vm.notShowWidth)
                self.getThumb(self.vm.currentIndex - 1)
                if self.vm.isVideo {//视频
                    AlbumViewerVideoView().frame(width: self.vm.screenWidth).environmentObject(self.vm)
                }else{//照片
                    AlbumViewerImageView().frame(width: self.vm.screenWidth).environmentObject(self.vm)
                }
                self.getThumb(self.vm.currentIndex + 1)
            }
            .frame(width: self.vm.screenWidth, alignment: .leading)
            .offset(x: self.vm.hStackOffset)
            .animation(.linear(duration: AlbumViewerViewModel.ANIMATION_TIME), value: dragingOffset == 0)
            
            //避免事件穿透,专门用一个视图来操作屏幕
            //另外一个目的是禁止默认视频播放控件
            Color.clear.contentShape(Rectangle()).frame(width: self.vm.screenWidth, height: self.vm.screenHeight)
                .onTapGesture(count: 2) {//双击事件
                    self.vm.doubleClick()
                }
                .onTapGesture(count: 1) {//单击事件
                    self.vm.showActionView.toggle()
                }
                .gesture(
                    MagnificationGesture()
                        .onChanged { amount in
                            //两手指放到屏幕上没有开始缩放时,amount的值是1,代表当前大小的1倍缩放
                            self.vm.zoomingAmount = amount
                        }
                        .onEnded { amount in
                            self.vm.zoomAmount *= self.vm.zoomingAmount
                            if self.vm.zoomAmount > 8.0 {//放大倍数不能大于4倍
                                withAnimation {
                                    self.vm.zoomAmount = 8.0
                                }
                            }
                            self.vm.zoomingAmount = 1
                            withAnimation {
                                self.vm.fixCropImage()
                            }
                        }.simultaneously(with: DragGesture()
                            .updating($dragingOffset){ value, state, _ in
                                state = value.translation.width
                                self.vm.currentOffsetPosition = self.vm.computeDragPosition(value)
                            }
                            .onEnded { value in
                                self.vm.currentOffsetPosition = self.vm.computeDragPosition(value)
                                self.vm.preOffsetPosition = self.vm.currentOffsetPosition
                                self.vm.fixCropImage()
                            }
                        )
                )
            if self.vm.showActionView{//显示操作视图
                AlbumViewerOptionView().environmentObject(self.vm)
                AlbumViewerTopBarView(showViewerPage: self.$showViewerPage).environmentObject(self.vm)
            }
            
            if self.vm.isVideo{
                if !self.vm.videoIsPlaying || self.vm.showActionView{//暂停中或者显示操作视图中,显示播放控制按钮
                    
                    //播放/暂停按钮
                    Button(action: self.vm.onPlayOrPauseClick){
                        Image(systemName: self.vm.videoIsPlaying ? "pause.fill" : "play.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 3, x: 2, y: 2)
                    }
                }
            }
        }
        //        .frame(maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .onDisappear{
            //            if AlbumViewerRecyclePage.isInited{//由于该页面是中转过来的,第一次打开时会调用onDisappear函数,如果此时将self.vm.uiImage = nil会导致第一次打开图片黑屏
            self.vm.uiImage = nil
            
            self.vm.videoPlayer?.pause() // 离开时暂停
            self.vm.videoPlayer = nil
            //                NotificationCenter.default.post(name: Notification.Name("BACK_IMAGE_VIEW"), object: nil)
            //            }else{
            //                AlbumViewerRecyclePage.isInited = true
            //            }
        }
    }
    
    ///获取缩略图
    private func getThumb(_ index: Int) -> some View{
        return Section{
            if self.vm.fileModels.indices.contains(index){
                CacheImage(self.vm.fileModels[index].thumbUrl, downloadId: self.vm.fileModels[index].thumbDownloadId).frame(width: self.vm.screenWidth, height: self.vm.screenHeight).aspectRatio(.fit).edgesIgnoringSafeArea(.all)//忽略安全区域
            }else{
                Spacer().frame(width: self.vm.screenWidth, height: self.vm.screenHeight)
            }
        }
    }
}

//#Preview {
//    AlbumViewerPage(getTestImageViewerViewModel(), self.vm.showViewerPage)
//}
//
//private func getTestImageViewerViewModel() -> AlbumViewerViewModel{
//    let model = FileModel(id: 1753616814866, name: "1753616814872371.heic", size: 1772687, fileFlag: true, date: "1232342", thumb: "", other1: "s34")
//    let vm = AlbumViewerViewModel([model], 0)
//    return vm
//}
