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
    
    
    @EnvironmentObject var vm: AlbumViewModel
    
    /// 根据可用宽度计算列数,手机上是3列,屏幕越宽列数越多
    static func columnCount(_ width: CGFloat) -> Int{
        return max(3, Int(width / 150))
    }
    
    var body: some View {
        if self.vm.isLoading{
            ProgressView("加载中")
        } else if self.vm.entityList.isEmpty{
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
            GeometryReader { geometry in
                let columnNum = AlbumGridView.columnCount(geometry.size.width)
                
                //每列宽度
                let columnWidth = (geometry.size.width - CGFloat(columnNum - 1) * self.SPACING) / CGFloat(columnNum)
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: self.SPACING), count: columnNum), spacing: self.SPACING) {
                            ForEach(self.vm.entityList, id: \.self.fm.id){item in
                                Button(action: {
                                    self.vm.onItemClick(item)
                                }){
                                    AlbumGridViewItem(item, size: columnWidth, isSelected: item.isSelected, isSelectMode: self.vm.isSelectMode)
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
                }
            }.ignoresSafeArea(.all)
        }
    }
}

//#Preview {
//    AlbumGridView()
//}
