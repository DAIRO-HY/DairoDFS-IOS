//
//  AlbumSync.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/06/24.
//

import SwiftUI
import Photos
import CommonCrypto
import DairoUI_IOS

struct SystemAlbumPage: View {
    
    ///表间距
    private let SPACING = CGFloat(2)
    
    /// 上传模式
    private let uploadMode: UploadMode
    
    @StateObject private var vm: SystemAlbumViewModel
    
    init(mode: UploadMode) {
        self.uploadMode = mode
        self._vm = StateObject(wrappedValue: SystemAlbumViewModel(mode))
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            //列数
            let columnNum = AlbumGridView.columnCount(geometry.size.width)
            
            //每列宽度 = (屏幕宽度 - (列数 - 1) * 列间距) / 列数
            let width = (geometry.size.width - CGFloat(columnNum - 1) * self.SPACING) / CGFloat(columnNum)
            VStack{
                if self.vm.freashFlag > 0{
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: self.SPACING), count: columnNum), spacing: self.SPACING) {
                                ForEach(self.vm.albumList, id:\.identifier) { item in
                                    Button(action:{
                                        self.vm.onItemClick(item)
                                    }){
                                        let index = self.vm.identifier2index[item.identifier]
                                        SystemAlbumImageView(width, index!, item.identifier).environmentObject(self.vm)
                                        //Text("-->:\(width)")
                                        //                            Text("\(index)-\(getAssetFileExtension(imageInfo.asset)!)-\(Costom.getCostom())")
                                        //                                Text("\(item.isExistsFlag)")
                                        //                                Text("\(item.identifier)-\(item.name)")
                                        //                            Text(getAssetFilePath(asset))
                                    }
                                }
                            }
                            
                            //初期化滚动到最底部的目的
                            Color.clear.frame(height: 1).id("BOTTOM")
                        }.onAppear {
                            proxy.scrollTo("BOTTOM", anchor: .bottomTrailing)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            //操作按钮浮在照片上面
            .safeAreaInset(edge: .bottom, spacing: 0){
                SystemAlbumOptionView().environmentObject(self.vm)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("所有照片")
        .onAppear{
            self.vm.fetchPhotos()
        }
        .onDisappear{
            self.vm.saveMd5()
        }
    }
}


//#Preview {
//    SystemAlbumPage()
//}
