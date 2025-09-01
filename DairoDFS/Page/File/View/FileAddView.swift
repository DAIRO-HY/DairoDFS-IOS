//
//  FileOptionBarView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI
import DairoUI_IOS

struct FileAddView: View {
    
    /// 文件添加视图打开状态广播通知标识
    static let FILE_ADD_VIEW_SHOW_FLAG = "FILE_ADD_VIEW_SHOW_FLAG"
    
    /// 显示文件选择标记
    @State private var showFilePicker = false
    
    /// 显示文件夹选择标记
    @State private var showFolderPicker = false
    
    /// 显示文件夹名称输入框
    @State private var showCreateFolderAlter = false
    
    /// 文件夹名称输入内容
    @State private var createFolder = ""
    
    @State private var showUpload = false
    
    /// 打开相册上传页面
    @State private var showAlbunSyncPage = false
    
    @EnvironmentObject var vm: FileViewModel
    
    var body: some View {
        if !self.vm.isShowAddView{
            EmptyView()
        } else {
            VStack(spacing: 8){
                    
                //图片上传页面
                NavigationLink(destination: SystemAlbumPage(mode: .file), isActive: self.$showAlbunSyncPage){
                    EmptyView()
                }
                
                Divider()
                Button(action:{
                    self.showUpload = true
                }){
                    Text("下载页面")
                }
                HStack{
                    BottomOptionButton("上传文件", icon: "arrow.up.document"){
                        self.showFilePicker = true
                    }
                    BottomOptionButton("上传文件夹", icon: "square.grid.3x1.folder.badge.plus"){
                        self.showFolderPicker = true
                    }
                    BottomOptionButton("图片/视频", icon: "rectangle.stack.badge.plus"){
                        self.showAlbunSyncPage = true
                    }
                    BottomOptionButton("创建文件夹", icon: "folder.badge.plus"){
                        self.showCreateFolderAlter = true
                    }
                }
            }
            .sheet(isPresented: self.$showFilePicker) {//显示文件选择器
                DocumentPicker(.data, true) { urls in
                    let fileUploadDtoList = self.makeFileUploadDtoList(SettingShared.lastOpenFolder, urls)
                    FileUploaderManager.upload(fileUploadDtoList)
                }
            }
            .sheet(isPresented: self.$showFolderPicker) {//显示文件夹选择器
                DocumentPicker(.folder, false) { urls in
                    let fileUploadDtoList = self.makeFileUploadDtoList(SettingShared.lastOpenFolder, urls)
                    FileUploaderManager.upload(fileUploadDtoList)
                }
            }
            .sheet(isPresented: self.$showUpload){
                RootView{
                    FileUploadPage()
                }
            }
            .alert("创建文件夹", isPresented: self.$showCreateFolderAlter) {
                TextField("文件夹名", text: self.$createFolder)
                Button("创建", role: .destructive){
                    let name = self.createFolder
                    
                    //清空输入值,避免下次被显示
                    self.createFolder = ""
                    FilesApi.createFolder(folder: SettingShared.lastOpenFolder + "/" + name).post {
                        self.vm.reload()
                    }
                }
                Button("取消", role: .cancel) {
                }
            }
            //        this.redrawVN.value++;
        }
    }
    
    /// 生成文件上传Dto列表
    private func makeFileUploadDtoList(_ folder: String, _ urls: [URL]) -> [FileUploaderDto] {
        var dtoList = [FileUploaderDto]()
        let fileManager = FileManager.default
        for url in urls {
            
            //文件名/文件夹名
            let filename = url.lastPathComponent
            
            //开启访问权限
            url.startAccessingSecurityScopedResource()
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: url.path, isDirectory: &isDir) {
                
                // 如果是目录，递归
                if isDir.boolValue {
                    let subUrls = try! fileManager.contentsOfDirectory(
                        at: url,
                        includingPropertiesForKeys: [.isDirectoryKey],
                        options: [.skipsHiddenFiles])
                    let subDtoList = self.makeFileUploadDtoList(folder + "/" + filename,subUrls)
                    dtoList.append(contentsOf: subDtoList)
                }else{
                    let size = FileUtil.getFileSize(url.path) ?? 0
                    
                    //获取url的bookmarkData
                    let bookmarkData = try! url.bookmarkData(options: [.withoutImplicitSecurityScope],
                                                             includingResourceValuesForKeys: nil,
                                                             relativeTo: nil)
                    let dto = FileUploaderDto(
                        id: 0,
                        bookmarkData: bookmarkData,
                        name: filename,
                        size: size,
                        uploadedSize: 0,
                        md5: nil,
                        dfsPath: folder + "/" + filename,
                        state: 0,
                        date: 0,
                        error: nil
                    )
                    dtoList.append(dto)
                }
            }
            
            //停止访问权限
            url.stopAccessingSecurityScopedResource()
        }
        return dtoList
    }
    
    //    private func makeFileUploadDto(_ folderURL: URL) -> [FileUploaderDto] {
    //        var result = [FileUploaderDto]()
    //        let fileManager = FileManager.default
    //        do {
    //            let items = try fileManager.contentsOfDirectory(
    //                at: folderURL,
    //                includingPropertiesForKeys: [.isDirectoryKey],
    //                options: [.skipsHiddenFiles])
    //            for item in items {
    //                var isDir: ObjCBool = false
    //                if fileManager.fileExists(atPath: item.path, isDirectory: &isDir) {
    //                    item.startAccessingSecurityScopedResource()
    //                    let size = FileUtil.getFileSize(item.path) ?? 0
    //
    //                    //获取url的bookmarkData
    //                    let bookmarkData = try! item.bookmarkData(options: [.withoutImplicitSecurityScope],
    //                                                              includingResourceValuesForKeys: nil,
    //                                                              relativeTo: nil)
    //                    item.stopAccessingSecurityScopedResource()
    //
    //                    let dfsPath = "/相册/" + item.lastPathComponent
    //                    let dto = FileUploaderDto(
    //                        id: 0,
    //                        bookmarkData: bookmarkData,
    //                        name: item.lastPathComponent,
    //                        size: size,
    //                        uploadedSize: 0,
    //                        md5: nil,
    //                        dfsPath: dfsPath,
    //                        state: 0,
    //                        date: 0,
    //                        error: nil
    //                    )
    //                    result.append(dto)
    //
    //                    // 如果是目录，递归
    //                    if isDir.boolValue {
    //                        let subResult = makeFileUploadDto(item)
    //                        result.append(contentsOf: subResult)
    //                    }
    //                }
    //            }
    //        } catch {
    //            print("读取文件夹失败: \(error)")
    //        }
    //
    //        return result
    //    }
    
    ///全取消
    private func onUncheckAllClick() {
        //      for (var it in this.filePageState.filesView.dfsFileList) {
        //        it.isSelected = false;
        //      }
        //      this.filePageState.selectedCount = 0;
        //      this.redraw();
        //      this.filePageState.filesView.redraw();
        ///private/var/mobile/Containers/Data/Application/48D7B39D-5613-4B55-9ACA-0B42413E1EF4/Documents/image.png
        ///private/var/mobile/Containers/Data/Application/48D7B39D-5613-4B55-9ACA-0B42413E1EF4/Documents/image.png
        ///private/var/mobile/Containers/Data/Application/48D7B39D-5613-4B55-9ACA-0B42413E1EF4/Documents/image.png
    }
    
    ///重命名
    private func onRenameClick() {
        //      final dfsFile = this.filePageState.filesView.dfsFileList.firstWhere((it) => it.isSelected);
        //      UCInputDialog.show(this._context, title: "重命名", value: dfsFile.name, okFun: (value) {
        //        if (value == dfsFile.name) {
        //          //没有修改
        //          return;
        //        }
        //        FilesApi.rename(sourcePath: dfsFile.path, name: value).post(() async {
        //          this.filePageState.filesView.reload();
        //        }, this._context);
        //      });
    }
    
    ///删除
    private func onDeleteClick() {
        //      UCAlertDialog.show(this._context, title: "删除确认", msg: "确定要删除选中的${this.filePageState.selectedCount}个文件或文件夹吗？", okFun: () {
        //        FilesApi.delete(paths: this.filePageState.filesView.selectedPaths).post(() async {
        //          this.filePageState.filesView.reload();
        //          this._context.toast("删除成功");
        //        }, this._context);
        //      }, cancelFun: () {});
    }
    
    ///下载按钮点击事件
    private func onDownloadClick() {
        //      DownloadWaitDialogView(this._context, this.filePageState.filesView.selected).show();
    }
    
    /// 放到剪贴板
    /// [clipboardType] 剪贴板类型,1:剪切  2:复制
    private func toClipboard(_ clipboardType: Int) {
        //      final clipboardPaths = <String>{};
        //      clipboardPaths.addAll(this.filePageState.filesView.selectedPaths);
        //      if (clipboardPaths.isEmpty) {
        //        return;
        //      }
        //      FileOptionView.clipboardType = clipboardType;
        //      FileOptionView.clipboardPaths = clipboardPaths;
        //
        //      //隐藏底部操作菜单
        //      this.hide();
        //      this._context.toast("选择的文件已放到剪切板,请选择一个文件夹然后粘贴。");
    }
    
    ///粘贴
    private func onClipboardClick() {
        //      if(FileOptionView.clipboardPaths == null){
        //        return;
        //      }
        //      final clipboardPaths = <String>[];
        //      clipboardPaths.addAll(FileOptionView.clipboardPaths as Iterable<String>);
        //
        //      final folder = this.filePageState.currentFolderVN.value;
        //
        //      successFun() async {
        //        //清空剪切板
        //        FileOptionView.clipboardType = null;
        //        FileOptionView.clipboardPaths = null;
        //        this.hide();
        //      }
        //      if (FileOptionView.clipboardType == 1) {
        //        FilesApi.move(sourcePaths: clipboardPaths, targetFolder: folder, isOverWrite: false).post(successFun, this._context);
        //      } else {
        //        FilesApi.copy(sourcePaths: clipboardPaths, targetFolder: folder, isOverWrite: false).post(successFun, this._context);
        //      }
    }
    
    ///属性点击事件
    private func onPropertyClick() {
        //      PropertyDialogView.show(this._context, this.filePageState.filesView.selectedPaths);
    }
    
    ///分享按钮点击事件
    private func onShareClick(){
        //      ShareView.show(this._context, this.filePageState.filesView.selectedPaths);
    }
}

#Preview {
    FileOptionView_preview()
}

private struct FileOptionView_preview: View {
    
    @StateObject var fileVm = FileViewModel()
    
    var body: some View {
        FileOptionView().environmentObject(self.fileVm)
    }
}
