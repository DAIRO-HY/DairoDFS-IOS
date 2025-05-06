//
//  AlbumGridView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/04.
//

import SwiftUI

struct AlbumGridView: View {
    
    ///表格间距
    private let SPACING = CGFloat(2)
    
    
    ///表格列数
    let columnNum = 3
    
    @EnvironmentObject var fileVm: AlbumViewModel
    
    ///每列宽度
    let columnWidth: CGFloat
    
    ///图片预览页面
    @State private var imageViewerActive = false
    
    ///图片预览页面的ViewModel
    private let imageViewerVM = ImageViewerViewModel()
    
    init() {
        self.columnWidth = (UIScreen.main.bounds.width - CGFloat(self.columnNum - 1) * self.SPACING) / 3
    }
    var body: some View {
        
        //图片预览页面
        NavigationLink(destination: ImageViewerPage(self.imageViewerVM), isActive: self.$imageViewerActive){EmptyView()}
        if self.fileVm.entityList.isEmpty{
            EmptyView()
        } else{
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: self.SPACING), count: self.columnNum), spacing: self.SPACING) {
                        ForEach(self.fileVm.entityList, id: \.self.model.id){item in
                            Button(action: { self.onFileClick(item) }){
                                AlbumGridViewItem(item, size: self.columnWidth, isSelectMode: self.fileVm.isSelectMode)
                            }
                            .buttonStyle(.row)
                        }
                    }
                    
                    //初期化滚动到最底部的目的
                    Color.clear.frame(height: 1).id("BOTTOM")
                }
                .onAppear {
                    proxy.scrollTo("BOTTOM", anchor: .bottomTrailing)
                }
            }.ignoresSafeArea(.all)
        }
    }
    
    /**
     文件点击事件
     */
    private func onFileClick(_ entity: AlbumEntity){
        if self.fileVm.isSelectMode{
            entity.isSelected = !entity.isSelected
            self.fileVm.selectedCount += (entity.isSelected ? 1 : -1)
            return
        }
        var index = 0
        var imageViewerEntitys = [ImageViewerEntity]()
        for i in self.fileVm.entityList.indices{
            let item = self.fileVm.entityList[i]
            let imageViewerEntity = ImageViewerEntity(id: item.model.id, name: item.model.name, thumb: item.model.thumb)
            imageViewerEntitys.append(imageViewerEntity)
            if entity === item{
                index = i
            }
        }
        self.imageViewerVM.setEntitys(imageViewerEntitys, index: index)
        self.imageViewerActive = true
    }
}

//#Preview {
//    AlbumGridView()
//}
