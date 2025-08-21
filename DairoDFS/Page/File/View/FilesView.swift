//
//  FilesView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI

struct FilesView: View {
    @EnvironmentObject var fileVm: FileViewModel
    var body: some View {
        ScrollView{
            LazyVStack{
                ForEach(self.fileVm.dfsFileList, id: \.self.fm.id) { item in
                    Button(action: { self.onFileClick(item) }){
                        FileListViewItem(item, isSelectMode: self.fileVm.isSelectMode)
                    }
                    .buttonStyle(.row)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    /**
     文件点击事件
     */
    private func onFileClick(_ item: DfsFileEntity){
        if self.fileVm.isSelectMode{
            item.isSelected = !item.isSelected
            self.fileVm.selectedCount += (item.isSelected ? 1 : -1)
            return
        }
        if item.fm.isFolder{//如果这是一个文件夹
            self.fileVm.loadSubFile(self.fileVm.currentFolder + "/" + item.fm.name)
        }
    }
}
//
//#Preview {
//    FilesView()
//}
