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
                ForEach(self.fileVm.dfsFileList, id: \.self.dfsModel.id) { item in
                    FileListViewItem(item){
                        if item.isFolder{//如果这是一个文件夹
                            self.fileVm.loadSubFile(self.fileVm.currentFolder + "/" + item.dfsModel.name)
                        }
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    FilesView()
}
