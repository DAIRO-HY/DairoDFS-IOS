//
//  FileOptionBarView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI
import DairoUI_IOS

struct FileOptionView: View {
    
    @EnvironmentObject var vm: FileViewModel
    
    //显示删除对话框
    @State private var showDeleteAlert = false
    
    //显示重命名输入框
    @State private var showRenameInput = false
    
    //显示重命名输入内容
    @State private var renameInput = ""
    
    var body: some View {
        if !self.vm.isSelectMode{
            EmptyView()
        } else {
            VStack(spacing: 8){
//                Divider()
//                HStack{
//                    Text("排序:").foregroundColor(.secondary)
//                    self.sortBtn("名称")
//                    self.sortBtn("时间")
//                    self.sortBtn("大小")
//                    self.sortBtn("类型")
//                    Spacer()
//                    Button(action:{}){
//                        Image(systemName: "square.grid.2x2")
//                    }.buttonStyle(.row)
//                }.padding(.horizontal, 5)
                Divider()
                HStack{
                    BottomOptionButton("全选", icon: "checklist.checked", action: self.vm.selectAll)
                    BottomOptionButton("复制", icon: "document.on.document", disabled: self.vm.selectedCount == 0, action: {
                        self.vm.toClipboard(2)
                    })
                    BottomOptionButton("剪切", icon: "scissors", disabled: self.vm.selectedCount == 0, action: {
                        self.vm.toClipboard(1)
                    })
                    BottomOptionButton("粘贴", icon: "document.on.clipboard", disabled: self.vm.clipboardType == 0, action: self.vm.onPasteClick)
//                    BottomOptionButton("分享", icon: "square.and.arrow.up", disabled: self.vm.selectedCount == 0, action: self.onShareClick)
                }
                HStack{
                    BottomOptionButton("删除", icon: "trash", disabled: self.vm.selectedCount == 0){
                        self.showDeleteAlert = true
                    }
                    .alert("确认删除吗？", isPresented: $showDeleteAlert) {
                        Button("删除", role: .destructive) {
                            self.vm.onDeleteClick()
                        }
                        Button("取消", role: .cancel) { }
                    } message: {
                        Text("此操作无法撤销")
                    }
                    BottomOptionButton("下载", icon: "square.and.arrow.down", disabled: self.vm.selectedCount == 0, action: self.vm.onDownloadClick)
                    BottomOptionButton("刷新", icon: "repeat", action: self.vm.reload)
                    BottomOptionButton("重命名", icon: "pencil", disabled: self.vm.selectedCount != 1){
                        
                        //当前选中文件名
                        let name = self.vm.entities.first{$0.isSelected}!.fm.name
                        self.renameInput = name
                        self.showRenameInput = true
                    }
                        .alert("重命名", isPresented: self.$showRenameInput) {
                            TextField("文件名", text: self.$renameInput)
                            Button("修改", role: .destructive){
                                let name = self.renameInput
                                
                                //清空输入值,避免下次被显示
                                self.renameInput = ""
                                self.vm.onRenameClick(name)
                            }
                            Button("取消", role: .cancel) {
                            }
                        }
//                    BottomOptionButton("属性", icon: "info", disabled: self.vm.selectedCount == 0, action: self.onPropertyClick)
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
