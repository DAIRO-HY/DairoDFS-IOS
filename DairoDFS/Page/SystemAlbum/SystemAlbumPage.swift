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
    
    //列数
    private let COLUMN_NUM = 3
    
    /// 上传模式
    private let uploadMode: UploadMode
    
    @ObservedObject private var viewModel: SystemAlbumViewModel
    
    init(mode: UploadMode) {
        self.uploadMode = mode
        self.viewModel = SystemAlbumViewModel(mode)
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            //每列宽度 = (屏幕宽度 - (列数 - 1) * 列间距) / 列数
            let width = (geometry.size.width - CGFloat(self.COLUMN_NUM - 1) * self.SPACING) / CGFloat(self.COLUMN_NUM)
            VStack{
                if !self.viewModel.albumList.isEmpty{
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: self.SPACING), count: self.COLUMN_NUM), spacing: self.SPACING) {
                                ForEach(self.viewModel.albumList, id:\.identifier) { item in
                                    Button(action:{
                                        self.viewModel.onItemClick(item)
                                    }){
                                        SystemAlbumImageView(size: width,albumBean: item)
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
                SystemAlbumOptionView().environmentObject(self.viewModel)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("所有照片")
        .onDisappear{
            PHAssetUploadManager.cancel()
            let identifierList = self.viewModel.albumList.map{$0.identifier}
            PHAssetUploadManager.saveAlbumMd5(identifierList)
        }
    }
}


//#Preview {
//    SystemAlbumPage()
//}
