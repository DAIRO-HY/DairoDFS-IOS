//
//  FileOptionBarView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI
import DairoUI_IOS
import DairoFileSDK

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
                HStack{
                    OptionButton("上传文件", icon: "arrow.up.document"){
                        self.showFilePicker = true
                    }
                    OptionButton("上传文件夹", icon: "square.grid.3x1.folder.badge.plus"){
                        self.showFolderPicker = true
                    }
                    OptionButton("图片/视频", icon: "rectangle.stack.badge.plus"){
                        self.showAlbunSyncPage = true
                    }
                    OptionButton("创建文件夹", icon: "folder.badge.plus"){
                        self.showCreateFolderAlter = true
                    }
                }
            }
            .padding(.vertical, 8)
            .sheet(isPresented: self.$showFilePicker) {//显示文件选择器
                DocumentPicker(.data, true) { urls in
                    self.upload(urls)
                }
            }
            .sheet(isPresented: self.$showFolderPicker) {//显示文件夹选择器
                DocumentPicker(.folder, false) { urls in
                    self.upload(urls)
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
                    FilesApi.createFolder(folder: SettingShared.lastOpenFolder + "/" + name).send {
                        self.vm.reload()
                    }
                }
                Button("取消", role: .cancel) {
                }
            }
            //        this.redrawVN.value++;
        }
    }
    
    /// 添加上传任务
    private func upload(_ urls: [URL]){
        do {
            let items = try self.makeUploadItems(SettingShared.lastOpenFolder, urls)
            _ = try FileSdkUtil.get().addUploads(items: items)
        } catch {
            Toast.show(error.fileSdkMessage)
        }
    }
    
    /// 生成上传任务列表
    private func makeUploadItems(_ folder: String, _ urls: [URL]) throws -> [UploadItem] {
        var items = [UploadItem]()
        let fileManager = FileManager.default
        for url in urls {
            
            //文件名/文件夹名
            let filename = url.lastPathComponent
            
            //开启访问权限
            let isAccessing = url.startAccessingSecurityScopedResource()
            defer{
                if isAccessing{
                    url.stopAccessingSecurityScopedResource()
                }
            }
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: url.path, isDirectory: &isDir) {
                
                // 如果是目录，递归
                if isDir.boolValue {
                    let subUrls = try fileManager.contentsOfDirectory(
                        at: url,
                        includingPropertiesForKeys: [.isDirectoryKey],
                        options: [.skipsHiddenFiles])
                    items.append(contentsOf: try self.makeUploadItems(folder + "/" + filename, subUrls))
                }else{
                    
                    //获取url的bookmarkData,确保app退出后该文件依然能够访问
                    let bookmarkData = try url.bookmarkData(options: [.withoutImplicitSecurityScope],
                                                            includingResourceValuesForKeys: nil,
                                                            relativeTo: nil)
                    items.append(UploadItem(source: .custom(id: FileUploadSource.makeId(bookmark: bookmarkData)), dfsPath: folder + "/" + filename))
                }
            }
        }
        return items
    }
    
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
