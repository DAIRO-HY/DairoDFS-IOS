//
//  ImageViewerPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/05.
//

import SwiftUI
import DairoUI_IOS

struct ImageViewerPage: View {
    
    private var vm: ImageViewerViewModel
    
    @State var isShow = true
    
    @Environment(\.dismiss) var dismiss
    
    init(_ vm: ImageViewerViewModel) {
        self.vm = vm
    }
    
    private func getImageViewerViewModel()->ImageViewerViewModel{
        let vvm = ImageViewerViewModel()
        vvm.setEntitys(self.vm.entitys, index: self.vm.currentIndex)
        return vvm
    }
    
    var body: some View {
        VStack{
            
            //由于图片浏览需要消耗大量内存,如果不通过中间页面中转一下,图片浏览页面返回时,内存不会被自动回收
            //@TODO:暂时无解
            NavigationLink(destination: ImageViewerPage123(getImageViewerViewModel()), isActive: self.$isShow){
                EmptyView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("BACK_IMAGE_VIEW"))){ _ in
            self.dismiss()
        }
    }
}

struct ImageViewerPage123: View {
    
    ///正在拖拽中的偏移量
    @GestureState private var dragingOffset: CGFloat = 0
    
    @ObservedObject private var vm: ImageViewerViewModel
    
    private let dragVM1: ImageViewerDragViewModel
    private let dragVM2: ImageViewerDragViewModel
    private let dragVM3: ImageViewerDragViewModel
    
    init(_ vm: ImageViewerViewModel) {
        self.vm = vm
        self.dragVM1 = ImageViewerDragViewModel(vm)
        self.dragVM2 = ImageViewerDragViewModel(vm)
        self.dragVM3 = ImageViewerDragViewModel(vm)
    }
    
    private func updateVm(){
        dragVM1.setUrl(self.vm.preview(self.vm.currentIndex - 1))
        dragVM2.setUrl(self.vm.preview(self.vm.currentIndex))
        dragVM3.setUrl(self.vm.preview(self.vm.currentIndex + 1))
    }
    
    var body: some View {
        
        //为了实现懒加载,这里始终只显示上一张,本张,下一张共3张图片
        HStack(spacing: 0) {
            
            //当前图片上一张之前的图片全部不显示,这些不显示的图片总宽度用这个占位
            Spacer().frame(width: self.vm.screenWidth * CGFloat(self.vm.currentIndex - 1))
            ImageViewer(self.vm.preview(self.vm.currentIndex - 1), dragVM1)
                .frame(width: self.vm.screenWidth)
                .id(self.vm.preview(self.vm.currentIndex - 1))
            ImageViewer(self.vm.preview(self.vm.currentIndex), dragVM2)
                .frame(width: self.vm.screenWidth)
                .id(self.vm.preview(self.vm.currentIndex))
            ImageViewer(self.vm.preview(self.vm.currentIndex + 1), dragVM3)
                .frame(width: self.vm.screenWidth)
                .id(self.vm.preview(self.vm.currentIndex + 1))
        }
        .frame(width: self.vm.screenWidth, alignment: .leading)
        .offset(x: self.vm.hStackOffset)
        .animation(.linear(duration: ImageViewerViewModel.ANIMATION_TIME), value: dragingOffset == 0)
        .onTapGesture(count: 2) {//双击事件
            self.dragVM2.doubleClick()
        }
        .gesture(
            //            DragGesture()
            //                .updating($dragingOffset){ value, state, _ in
            //                    state = value.translation.width
            //                    self.dragVM2.currentOffsetPosition = self.dragVM2.computeDragPosition(value)
            //                }
            //                .onEnded { value in
            //                    self.dragVM2.currentOffsetPosition = self.dragVM2.computeDragPosition(value)
            //                    self.dragVM2.preOffsetPosition = self.dragVM2.currentOffsetPosition
            //                    self.dragVM2.fixCropImage()
            //                }
            MagnificationGesture()
                .onChanged { amount in
                    //两手指放到屏幕上没有开始缩放时,amount的值是1,代表当前大小的1倍缩放
                    self.dragVM2.zoomingAmount = amount
                }
                .onEnded { amount in
                    self.dragVM2.zoomAmount *= self.dragVM2.zoomingAmount
                    if self.dragVM2.zoomAmount > 8.0 {//放大倍数不能大于4倍
                        withAnimation {
                            self.dragVM2.zoomAmount = 8.0
                        }
                    }
                    self.dragVM2.zoomingAmount = 1
                    withAnimation {
                        self.dragVM2.fixCropImage()
                    }
                }.simultaneously(with: DragGesture()
                    .updating($dragingOffset){ value, state, _ in
                        state = value.translation.width
                        self.dragVM2.currentOffsetPosition = self.dragVM2.computeDragPosition(value)
                    }
                    .onEnded { value in
                        self.dragVM2.currentOffsetPosition = self.dragVM2.computeDragPosition(value)
                        self.dragVM2.preOffsetPosition = self.dragVM2.currentOffsetPosition
                        self.dragVM2.fixCropImage()
                    }
                )
        )
        
        //            .gesture(
        //                DragGesture()
        //                    .updating($dragOffset, body: { value, state, _ in
        //                        state = value.translation.width
        //                        self.vm.hStackOffset = -CGFloat(self.vm.index) * self.vm.screenWidth + dragOffset
        //                    })
        //                    .onEnded { value in
        //                        let threshold = self.vm.screenWidth / 2
        //                        let dragDistance = value.translation.width
        //
        //                        var currentPage = self.vm.index
        //                        if dragDistance < -threshold, currentPage < self.vm.entitys.count - 1 {
        //                            currentPage += 1
        //                        } else if dragDistance > threshold, currentPage > 0 {
        //                            currentPage -= 1
        //                        }
        //                        self.vm.hStackOffset = -CGFloat(currentPage) * self.vm.screenWidth + dragOffset
        //                        Task{
        //                            await Task.sleep(200_000_000)
        //                            await MainActor.run{
        //                                self.vm.index = currentPage
        //                                self.updateVm()
        //                            }
        //                        }
        //                    }
        //            )
        .onAppear{
            self.updateVm()
        }
        .onChange(of: self.vm.currentIndex){ _ in
            self.updateVm()
        }
        .onDisappear{
            NotificationCenter.default.post(name: Notification.Name("BACK_IMAGE_VIEW"), object: nil)
        }
        //        }
        
        
        
        //            GeometryReader { geometry in
        //                LazyHStack(spacing: 0) {
        //                    ForEach(self.vm.entitys.indices, id: \.self) { index in
        //                        ZStack{
        ////                            Text("123")
        //
        //                                Text("\(index)")
        //                                    .background(Color.red)
        //                                    .frame(width: geometry.size.width, height: geometry.size.height)
        ////                            ImageViewerPagerItem(self.vm.preview(self.vm.index), dragVM).opacity(0.6)
        //                        }
        ////                        .frame(width: geometry.size.width, height: geometry.size.height)
        //                        .frame(width: 300, height: geometry.size.height)
        ////                        .frame(maxHeight: .infinity)
        //                        .background(Color.green)
        //                        .onAppear{
        //                            print("-->:\(index)")
        //                        }
        //                    }
        //                }
        //                .background(Color.cyan)
        //                .offset(x: -CGFloat(currentPage) * geometry.size.width + dragOffset)
        //                .animation(.easeInOut, value: dragOffset == 0)
        //                .gesture(
        //                    DragGesture()
        //                        .updating($dragOffset, body: { value, state, _ in
        //                            state = value.translation.width
        //                        })
        //                        .onEnded { value in
        //                            let threshold = geometry.size.width / 2
        //                            let dragDistance = value.translation.width
        //                            if dragDistance < -threshold, currentPage < self.vm.entitys.count - 1 {
        //                                currentPage += 1
        //                            } else if dragDistance > threshold, currentPage > 0 {
        //                                currentPage -= 1
        //                            }
        //                        }
        //                )
        //            }
        //            .clipped()
        
        //        ZStack {
        //            ImageViewerPagerItem(self.vm.preview(self.vm.index), dragVM).opacity(0.6)
        //        }
        //        .background(Color.cyan)
        //        .frame(maxWidth: .infinity,maxHeight: .infinity)
        //
        //        //MARK: - Gestures
        //        .gesture(
        //            MagnificationGesture()
        //                .onChanged { amount in
        //                    //两手指放到屏幕上没有开始缩放时,amount的值是1,代表当前大小的1倍缩放
        //                    self.dragVM.zoomingAmount = amount
        //                }
        //                .onEnded { amount in
        //                    self.dragVM.zoomAmount *= self.dragVM.zoomingAmount
        //                    if self.dragVM.zoomAmount > 8.0 {//放大倍数不能大于4倍
        //                        withAnimation {
        //                            self.dragVM.zoomAmount = 8.0
        //                        }
        //                    }
        //                    self.dragVM.zoomingAmount = 1
        //                    withAnimation {
        //                        self.dragVM.fixCropImage()
        //                    }
        //                }.simultaneously(with: DragGesture()
        //                    .onChanged { value in
        //                        self.dragVM.currentOffsetPosition = self.dragVM.computeDragPosition(value)
        //                    }
        //                    .onEnded { value in
        //                        self.dragVM.currentOffsetPosition = self.dragVM.computeDragPosition(value)
        //                        self.dragVM.preOffsetPosition = self.dragVM.currentOffsetPosition
        //                        withAnimation {
        //                            self.dragVM.fixCropImage()
        //                        }
        //                    }
        //                )
        //        )
    }
}

#Preview {
    ImageViewerPage(ImageViewerViewModel())
}
