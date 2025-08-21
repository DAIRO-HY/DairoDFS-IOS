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
    
    @EnvironmentObject var vm: AlbumViewModel
    
    ///每列宽度
    let columnWidth: CGFloat
    
    init() {
        self.columnWidth = (UIScreen.main.bounds.width - CGFloat(self.columnNum - 1) * self.SPACING) / 3
    }
    var body: some View {
        if self.vm.entityList.isEmpty{
            Button(action:{
                self.vm.showAlbunSyncPage = true
            }){
                VStack{
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .foregroundColor(Color.gl.black)
                        .frame(width: 36,height: 36)
                    Text("添加")
                }
            }
            .buttonStyle(.row)
        } else{
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: self.SPACING), count: self.columnNum), spacing: self.SPACING) {
                        ForEach(self.vm.entityList, id: \.self.fm.id){item in
                            Button(action: {
                                self.vm.onItemClick(item)
                            }){
                                AlbumGridViewItem(item, size: self.columnWidth, isSelectMode: self.vm.isSelectMode)
                            }
                            .buttonStyle(.row)
                        }
                    }
                    
                    //初期化滚动到最底部的
                    //让底部有一定控件显示操作按钮
                    Color.clear.frame(height: 80).id("BOTTOM")
                }.onAppear {
                    proxy.scrollTo("BOTTOM", anchor: .bottomTrailing)
                }
            }.ignoresSafeArea(.all)
        }
    }
}

//#Preview {
//    AlbumGridView()
//}
