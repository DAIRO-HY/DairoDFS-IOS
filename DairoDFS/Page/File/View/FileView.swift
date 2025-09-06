//
//  FileView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI
import DairoUI_IOS

struct FileView: View {
    @EnvironmentObject var vm: FileViewModel
    var body: some View {
        ScrollView{
            LazyVStack{
                ForEach(self.vm.entities, id: \.self.fm.id) { item in
                    
                    //是否在剪切板标记
                    let isMoveFlag = self.vm.clipboardType == 1 && self.vm.clipboardSet.contains(item.fm.id)
                    Button(action: { self.vm.onFileClick(item) }){
                        FileListItemView(item, isSelectMode: self.vm.isSelectMode)
                    }
                    .buttonStyle(.row)
                    .opacity(isMoveFlag ? 0.5 : 1)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .fullScreenCover(isPresented: self.$vm.showViewerPage) {
            let viewModel = self.vm.getAlbumViewerViewModel()
            RootView{
                AlbumViewerPage(viewModel, self.$vm.showViewerPage)
            }
        }
    }
}
//
//#Preview {
//    FilesView()
//}
