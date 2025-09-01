//
//  FileViewModel.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import Foundation
import SwiftUI

class FileViewModel : ObservableObject{
    
    /// 当前请求的文件夹
    @Published var currentFolder = ""
    
    ///记录当前选中的文件数
    @Published var selectedCount = 0
    
    @Published var dfsFileList = [DfsFileEntity]()
    
    ///  剪切板模式
    @Published var clipboardType = 0
    
    ///选择模式
    @Published var isSelectMode = false
    
    ///是否添加视图
    @Published var isShowAddView = false
    
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
            
            var dfsFileList = [DfsFileEntity]()
            for item in list{
                dfsFileList.append(DfsFileEntity(item))
            }
            self.dfsFileList = dfsFileList
            //        this.dfsFileList = list.map((it) => DfsFileVM(folderPath, it)).toList();
            //        this.filePageState.selectedCount = 0;
            
            //        //设置当前显示的文件夹路径
            //        this.filePageState.currentFolderVN.value = folderPath;
            //
            //        //重回文件页面
            //        this.redraw();
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
        for item in self.dfsFileList{
            item.isSelected = false
        }
        self.selectedCount = 0
    }
    
    /**
     全选
     */
    func selectAll(){
        for item in self.dfsFileList{
            item.isSelected = true
        }
        self.selectedCount = self.dfsFileList.count
    }
    
    
    /// 创建文件夹点击事件
    func onCreatFolderClick(){
        
    }
    
    deinit{
        debugPrint("-->FileViewModel.deinit")
    }
}
