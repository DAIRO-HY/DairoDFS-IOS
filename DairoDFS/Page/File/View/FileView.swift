//
//  FileView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI

struct FileView: View {
    @EnvironmentObject var vm: FileViewModel
    var body: some View {
        ScrollView{
            LazyVStack{
                ForEach(self.vm.dfsFileList, id: \.self.fm.id) { item in
                    
                    //是否在剪切板标记
                    let isMoveFlag = self.vm.clipboardType == 1 && self.vm.clipboardSet.contains(item.fm.id)
                    Button(action: { self.onFileClick(item) }){
                        FileListItemView(item, isSelectMode: self.vm.isSelectMode)
                    }
                    .buttonStyle(.row)
                    .opacity(isMoveFlag ? 0.5 : 1)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    /// 文件点击事件
    private func onFileClick(_ item: DfsFileEntity){
        if self.vm.isSelectMode{
            item.isSelected.toggle()
            self.vm.selectedCount += (item.isSelected ? 1 : -1)
            return
        }
        if item.fm.isFolder{//如果这是一个文件夹
            self.vm.loadSubFile(SettingShared.lastOpenFolder + "/" + item.fm.name)
        }
    }
}
//
//#Preview {
//    FilesView()
//}
