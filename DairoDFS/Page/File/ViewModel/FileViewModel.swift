//
//  FileViewModel.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import Foundation
import SwiftUI
import DairoUI_IOS

class FileViewModel : ObservableObject{
    
    /// 当前请求的文件夹
    @Published var currentFolder = ""
    
    ///记录当前选中的文件数
    @Published var selectedCount = 0
    
    @Published var entities = [FileEntity]()
    
    ///选择模式
    @Published var isSelectMode = false
    
    ///是否添加视图
    @Published var isShowAddView = false
    
    /// 显示查看相册页面
    @Published var showViewerPage = false
    
    /// 剪切板中的文件ID
    var clipboardSet = Set<Int64>()
    
    /// 剪切板中的文件路径列表
    private var clipboardPaths = [String]()
    
    /// 剪切板类型 1:剪切 2:复制 
    @Published var clipboardType: Int8 = 0
    
    /// 记录当前点击的文件id
    private var currentClickFileId: Int64 = -1
    
    init(){
        self.reload()
    }
    
    ///重新加载
    func reload(){
        self.loadSubFile(SettingShared.lastOpenFolder)
    }
    
    ///获取文件列表
    func loadSubFile(_ folderPath: String) {
        let folderPath = folderPath == "/" ? "" : folderPath
        
        //记录最后打开的文件夹
        SettingShared.lastOpenFolder = folderPath
        self.currentFolder = folderPath.isEmpty ? "根目录" : folderPath
        DfsFileShared.getSubList(folderPath){list in
            //        if (this.filePageState.isFinish) {
            //          //如果页面已经关闭，那就什么也不做。防止异步操作时，页面被关闭报错
            //          return;
            //        }
            //        this.sortFile(list);
            
            var dfsFileList = [FileEntity]()
            for item in list{
                dfsFileList.append(FileEntity(item))
            }
            self.entities = dfsFileList
            //        this.dfsFileList = list.map((it) => DfsFileVM(folderPath, it)).toList();
            //        this.filePageState.selectedCount = 0;
            
            //        //设置当前显示的文件夹路径
            //        this.filePageState.currentFolderVN.value = folderPath;
            //
            //        //重回文件页面
            //        this.redraw();
            self.clearSelected()
            self.isSelectMode = false
        }
    }
    
    
    /// 文件点击事件
    func onFileClick(_ item: FileEntity){
        if self.isSelectMode{
            item.isSelected.toggle()
            self.selectedCount += (item.isSelected ? 1 : -1)
            return
        }
        if item.fm.isFolder{//如果这是一个文件夹
            self.loadSubFile(SettingShared.lastOpenFolder + "/" + item.fm.name)
            return
        }
        if item.fm.isImage || item.fm.isVideo{//这个文件是图片或者视频
            self.currentClickFileId = item.fm.id
            self.showViewerPage = true
            return
        }
    }
    
    ///文件排列
    private func sortFile(dfsList: [FileModel]) {
        
        //      //排序方式
        //      final sortType = SettingShared.sortType;
        //
        //      //升降序方式
        //      final sortOrderBy = SettingShared.sortOrderBy;
        //
        //      //排序
        //      dfsList.sort((p1, p2) {
        //        final int compareValue;
        //        if (sortType == FileSortType.NAME) {
        //          compareValue = p1.name.toLowerCase().compareTo(p2.name.toLowerCase());
        //        } else if (sortType == FileSortType.DATE) {
        //          compareValue = p1.date.compareTo(p2.date);
        //        } else if (sortType == FileSortType.SIZE) {
        //          compareValue = p1.size.compareTo(p2.size);
        //        } else if (sortType == FileSortType.EXT) {
        //          compareValue = p1.name.fileExt
        //              .toLowerCase()
        //              .compareTo(p2.name.fileExt.toLowerCase());
        //        } else {
        //          return 0;
        //        }
        //        if (sortOrderBy == FileOrderBy.UP) {
        //          //升降序方式
        //          return compareValue;
        //        }
        //        return compareValue * -1;
        //      });
        //
        //      //使文件夹始终在最上面
        //      dfsList.sort((p1, p2) {
        //        if (p1.fileFlag && !p2.fileFlag) {
        //          //都是文件夹
        //          return 1;
        //        } else if (!p1.fileFlag && p2.fileFlag) {
        //          //都是文件夹
        //          return -1;
        //        } else {
        //          return 0;
        //        }
        //      });
    }
    
    /**
     清空已经选择的文件
     */
    func clearSelected(){
        for item in self.entities{
            item.isSelected = false
        }
        self.selectedCount = 0
    }
    
    /// 存放剪切板
    func toClipboard(_ clipboardType: Int8){
        let lastOpenFolder = SettingShared.lastOpenFolder
        self.entities.forEach{
            if $0.isSelected{
                self.clipboardPaths.append(lastOpenFolder + "/" + $0.fm.name)
                self.clipboardSet.insert($0.fm.id)
            }
        }
        self.clipboardType = clipboardType
        Toast.show("操作成功,请选择文件夹后粘贴")
        self.clearSelected()
        self.isSelectMode = false
    }
    
    ///粘贴点击事件
    func onPasteClick(){
        let http: ApiHttp<EmptyModel>
        if self.clipboardType == 1{
            http = FilesApi.move(sourcePaths: self.clipboardPaths, targetFolder: SettingShared.lastOpenFolder, isOverWrite: false)
        }else{
            http = FilesApi.copy(sourcePaths: self.clipboardPaths, targetFolder: SettingShared.lastOpenFolder, isOverWrite: false)
        }
        http.post {
            self.clipboardType = 0
            self.clipboardSet.removeAll()
            self.clipboardPaths.removeAll()
            Toast.show("操作成功")
            self.reload()
        }
    }
    
    ///重命名点击事件
    func onRenameClick(_ newName: String){
        
        //当前选中文件名
        let name = self.entities.first{$0.isSelected}!.fm.name
        let path = SettingShared.lastOpenFolder + "/" + name
        self.isSelectMode = false
        FilesApi.rename(sourcePath: path, name: newName).post {
            Toast.show("操作成功")
            self.reload()
        }
    }
    
    /// 下载按钮点击事件
    func onDownloadClick(){
        let downloadList = self.entities.filter{$0.isSelected && $0.fm.isFile}.map{
            return ($0.fm.downloadId, $0.fm.download)
        }
        if downloadList.isEmpty{
            Toast.show("请选择要下载的文件,暂不支持文件夹下载")
            return
        }
        
        //添加到下载列表
        DownloadManager.save(downloadList)
        Toast.show("已经添加到下载列表")
        self.isSelectMode = false
        self.clearSelected()
    }
    
    /**
     全选
     */
    func selectAll(){
        for item in self.entities{
            item.isSelected = true
        }
        self.selectedCount = self.entities.count
    }
    
    /// 删除按钮点击事件
    func onDeleteClick(){
        let folder = SettingShared.lastOpenFolder
        let paths = self.entities.filter{$0.isSelected}.map{folder + "/" + $0.fm.name}
        FilesApi.delete(paths: paths).post {
            Toast.show("删除成功")
            
            //当前选中的数量归零
            self.selectedCount = 0
            self.reload()
        }
    }
    
    /// 获取相册查看页面的ViewModel
    func getAlbumViewerViewModel() -> AlbumViewerViewModel{
        
        //当前点击的文件在所有图片和视频中的序号
        var index = -1
        var fileModels = [FileModel]()
        for it in self.entities{
            let fm = it.fm
            if fm.isFolder{
                continue
            }
            if !fm.isVideo && !fm.isImage{
                continue
            }
            if fm.id == self.currentClickFileId{
                index = fileModels.count
            }
            fileModels.append(fm)
        }
        let viewModel = AlbumViewerViewModel(fileModels, index)
        return viewModel
    }
    
    deinit{
        debugPrint("-->FileViewModel.deinit")
    }
}
