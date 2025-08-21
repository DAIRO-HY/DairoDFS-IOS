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
    
    @State private var showPicker = false
    
    @EnvironmentObject var vm: FileViewModel
    
    var body: some View {
        if !self.vm.isShowAddView{
            EmptyView()
        } else {
            VStack(spacing: 8){
                Divider()
                HStack{
                    BottomOptionButton("上传文件", icon: "arrow.up.document", action: self.onUploadFileClick)
                    BottomOptionButton("上传文件夹", icon: "square.grid.3x1.folder.badge.plus", action: self.vm.selectAll)
                    BottomOptionButton("图片/视频", icon: "rectangle.stack.badge.plus", action: self.vm.selectAll)
                    BottomOptionButton("创建文件夹", icon: "folder.badge.plus", action: self.vm.selectAll)
                }
            }
            .sheet(isPresented: $showPicker) {
                DocumentPicker { urls in
                    print("-->:\(urls)")
                    FileUploaderManager.upload(urls)
                }
            }
            //        this.redrawVN.value++;
        }
    }
    
    ///文件上传点击事件
    private func onUploadFileClick() {
        self.showPicker = true
    }
    
    ///全取消
    private func onUncheckAllClick() {
        //      for (var it in this.filePageState.filesView.dfsFileList) {
        //        it.isSelected = false;
        //      }
        //      this.filePageState.selectedCount = 0;
        //      this.redraw();
        //      this.filePageState.filesView.redraw();
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
