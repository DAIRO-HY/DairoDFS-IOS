//
//  FileOptionBarView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI

struct FileOptionView: View {
    
    @EnvironmentObject var fileVm: FileViewModel
    
    var body: some View {
        if !self.fileVm.isSelectMode{
            EmptyView()
        } else {
            VStack(spacing: 8){
                Divider()
                HStack{
                    Text("排序:").foregroundColor(.secondary)
                    self.sortBtn("名称")
                    self.sortBtn("时间")
                    self.sortBtn("大小")
                    self.sortBtn("类型")
                    Spacer()
                    Button(action:{}){
                        Image(systemName: "square.grid.2x2")
                    }.buttonStyle(.row)
                }.padding(.horizontal, 5)
                Divider()
                HStack{
                    UCOptionMenuButton("全选", icon: "checklist.checked", action: self.fileVm.selectAll)
                    UCOptionMenuButton("复制", icon: "document.on.document", disabled: self.fileVm.selectedCount == 0, action: {
                        self.toClipboard(2)
                    })
                    UCOptionMenuButton("剪切", icon: "scissors", disabled: self.fileVm.selectedCount == 0, action: {
                        self.toClipboard(1)
                    })
                    UCOptionMenuButton("粘贴", icon: "document.on.clipboard", disabled: self.fileVm.clipboardType == 0, action: self.onClipboardClick)
                    UCOptionMenuButton("分享", icon: "square.and.arrow.up", disabled: self.fileVm.selectedCount == 0, action: self.onShareClick)
                }
                HStack{
                    UCOptionMenuButton("删除", icon: "trash", disabled: self.fileVm.selectedCount == 0, action: self.onDeleteClick)
                    UCOptionMenuButton("下载", icon: "square.and.arrow.down", disabled: self.fileVm.selectedCount == 0, action: self.onDownloadClick)
                    UCOptionMenuButton("刷新", icon: "repeat", action: self.fileVm.reload)
                    UCOptionMenuButton("重命名", icon: "pencil", disabled: self.fileVm.selectedCount != 1, action: self.onRenameClick)
                    UCOptionMenuButton("属性", icon: "info", disabled: self.fileVm.selectedCount == 0, action: self.onPropertyClick)
                }
            }
            //        this.redrawVN.value++;
        }
    }
    
    /**
     排序按钮
     */
    private func sortBtn(_ label: String) -> some View{
        return Button(action:{
            
        }){
            Text(label)
        }.buttonStyle(.row)
    }
    
    
    
    ///全选
    private func onCheckAllClick() {
        //      for (var it in this.filePageState.filesView.dfsFileList) {
        //        it.isSelected = true;
        //      }
        //      this.filePageState.selectedCount = this.filePageState.filesView.dfsFileList.length;
        //      this.redraw();
        //      this.filePageState.filesView.redraw();
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
