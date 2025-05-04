//
//  AlbumGridView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/04.
//

import SwiftUI

struct AlbumGridView: View {
    
    ///间距
    private let SPACING = CGFloat(2)
    
    
    ///列数
    let columnNum = 3
    
    @EnvironmentObject var fileVm: AlbumViewModel
    
    let columnWidth: CGFloat
    
    init() {
        self.columnWidth = (UIScreen.main.bounds.width - CGFloat(self.columnNum - 1) * self.SPACING) / 3
    }
    var body: some View {
        if self.fileVm.entityList.isEmpty{
            EmptyView()
        } else{
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: self.SPACING), count: self.columnNum), spacing: self.SPACING) {
                        ForEach(self.fileVm.entityList, id: \.self.model.id){item in
                            AlbumGridViewItem(item, size: self.columnWidth, isSelectMode: self.fileVm.isSelectMode)
                            //                        Spacer().frame(width: self.columnWidth, height: self.columnWidth).background(Color.cyan)
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
}

//#Preview {
//    AlbumGridView()
//}
