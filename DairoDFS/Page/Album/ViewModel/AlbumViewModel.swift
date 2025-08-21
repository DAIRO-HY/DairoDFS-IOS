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
    
    /// 相册列表数据缓存key
    static let LOCAL_OBJ_KEY_ALBUM = "albums"
    
    /// 显示查看相册页面
    @Published var showViewerPage = false
    
    //跳转相册同步班页面
    @Published var showAlbunSyncPage = false
    
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
        if let modelList = LocalObjectUtil.read([FileModel].self, AlbumViewModel.LOCAL_OBJ_KEY_ALBUM){
            self.toEntity(modelList)
        }
        FilesApi.getAlbumList().hide().post(){ modelList in
            if LocalObjectUtil.write(modelList, AlbumViewModel.LOCAL_OBJ_KEY_ALBUM){
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
    
    /// 删除按钮点击事件
    func onDeleteClick(){
        var deleteIds = [Int64]()
        for item in self.entityList{
            if !item.isSelected{
                continue
            }
            deleteIds.append(item.fm.id)
        }
        FilesApi.deleteByIds(ids: deleteIds).post{
            Toast.show("删除成功")
            
            //删除数据缓存
            LocalObjectUtil.delete(AlbumViewModel.LOCAL_OBJ_KEY_ALBUM)
            self.loadData()
        }
    }
    
    /// 下载按钮点击事件
    func onDownloadClick(){
        var downloadIds = [(id: String, url: String)]()
        for item in self.entityList{
            if !item.isSelected{
                continue
            }
            downloadIds.append((id: item.fm.downloadId, url: item.fm.download))
        }
        
        //将选中的文件添加到下载列表
        DownloadManager.save(downloadIds)
        Toast.show("已添加到下载列表")
    }
    
    deinit{
        debugPrint("-->FileViewModel.deinit")
    }
}
