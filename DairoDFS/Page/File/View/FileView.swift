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
                        FileListItemView(item, isSelected: item.isSelected, isSelectMode: self.vm.isSelectMode)
                    }
                    .buttonStyle(.row)
                    .opacity(isMoveFlag ? 0.5 : 1)
                }
            }
            .padding(.top, 10)
            .padding(.bottom)
        }
        .frame(maxHeight: .infinity)
        .overlay{
            if self.vm.isLoading{
                ProgressView("加载中")
            }
        }
        .fullScreenCover(isPresented: self.$vm.showViewerPage) {
            let viewModel = self.vm.getAlbumViewerViewModel()
            RootView{
                AlbumViewerPage(viewModel, self.$vm.showViewerPage)
            }
        }
        .sheet(isPresented: Binding(get: { self.vm.audioFile != nil }, set: { if !$0 { self.vm.audioFile = nil } })) {
            if let audioFile = self.vm.audioFile{
                AudioPlayerPage(audioFile)
            }
        }
    }
}
//
//#Preview {
//    FilesView()
//}
