//
//  FileViewModel.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import Foundation
import SwiftUI
import DairoUI_IOS


class AlbumViewModel : ObservableObject{
    
    /// 显示查看相册页面
    @Published var showViewerPage = false
    
    ///记录当前选中的文件数
    @Published var selectedCount = 0
    
    @Published var entityList = [AlbumEntity]()
    
    ///  剪切板模式
    @Published var clipboardType = 0
    
    ///选择模式
    @Published var isSelectMode = false
    
    @Published var index = -1
    
    ///文件列表
    var fileModels = [FileModel]()
    
    /// 当前请求的文件夹
    var currentFolder = ""
    
    /// 记录当前点击的序号
    private var currentClickIndex = -1
    
    /// 是否需要重新加载数据
    var isNeedReloadData = false
    
    init(){
        self.loadData()
    }
    
    ///获取文件列表
    func loadData() {
        
        //从本地缓存读取数据
        if let modelList = LocalObjectUtil.read([FileModel].self, "albums"){
            self.toEntity(modelList)
        }
        FilesApi.getAlbumList().hide().post(){ modelList in
            if LocalObjectUtil.write(modelList, "albums"){
                Task{@MainActor in
                    self.toEntity(modelList)
                }
            }
        }
    }
    
    /// 整理列表数据
    private func toEntity(_ modelList: [FileModel]){
        var entityList = [AlbumEntity]()
        for i in modelList.indices{
            let model = modelList[i]
            entityList.append(AlbumEntity(i, model))
        }
        
        self.entityList = entityList
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
    
    /// 相册点击事件
    func onItemClick(_ entity: AlbumEntity){
        if self.isSelectMode{
            entity.isSelected = !entity.isSelected
            self.selectedCount += (entity.isSelected ? 1 : -1)
            return
        }
        self.currentClickIndex = entity.index
        self.showViewerPage = true
    }
    
    /// 获取相册查看页面的ViewModel
    func getAlbumViewerViewModel() -> AlbumViewerViewModel{
        var fileModels = [FileModel]()
        for i in self.entityList.indices{
            let item = self.entityList[i]
            fileModels.append(item.fm)
        }
        let viewModel = AlbumViewerViewModel(fileModels, self.currentClickIndex)
        return viewModel
    }
    
    deinit{
        debugPrint("-->FileViewModel.deinit")
    }
}
