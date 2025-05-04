//
//  FileViewModel.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import Foundation
import SwiftUI

class AlbumViewModel : ObservableObject{
    
    /// 当前请求的文件夹
    var currentFolder = ""
    
    ///记录当前选中的文件数
    @Published var selectedCount = 0
    
    @Published var entityList = [AlbumEntity]()
    
    ///  剪切板模式
    @Published var clipboardType = 0
    
    ///选择模式
    @Published var isSelectMode = false
    
    init(){
        self.loadSubFile()
    }
    
    /**
     重新加载
     */
    func reload(){
        self.loadSubFile()
    }
    
    ///获取文件列表
    func loadSubFile() {
        FilesApi.getAlbumList().post(){albumList in
            var entityList = [AlbumEntity]()
            for model in albumList{
                entityList.append(AlbumEntity(model))
            }
            self.entityList = entityList
        }
    }

    /**
     清空已经选择的文件
     */
    func clearSelected(){
        for item in self.entityList{
            item.isSelected = false
        }
        self.selectedCount = 0
    }
    
    /**
     全选
     */
    func selectAll(){
        for item in self.entityList{
            item.isSelected = true
        }
        self.selectedCount = self.entityList.count
    }
    
    deinit{
        debugPrint("-->FileViewModel.deinit")
    }
}
