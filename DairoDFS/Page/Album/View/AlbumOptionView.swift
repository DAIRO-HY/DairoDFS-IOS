//
//  FileOptionBarView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI
import DairoUI_IOS

struct AlbumOptionView: View {
    @EnvironmentObject var vm: AlbumViewModel
    @State private var showDeleteAlert = false
    
    /// 是否跳转设置页面
    @State var isShowSet = false
    
    var body: some View {
        if self.vm.isSelectMode{
            VStack(spacing: 0){
                Spacer()
                Divider()
                HStack{
                    BottomOptionButton("刷新", icon: "arrow.trianglehead.2.clockwise"){
                        self.vm.loadData()
                    }
                    BottomOptionButton("删除", icon: "trash", disabled: self.vm.selectedCount == 0){
                        self.showDeleteAlert = true
                    }
                    BottomOptionButton("添加", icon: "plus.app"){
                        self.vm.showAlbunSyncPage = true
                    }
                    .alert("确认删除选中的\(self.vm.selectedCount)个文件吗？", isPresented: $showDeleteAlert) {
                        Button("删除", role: .destructive) {
                            self.vm.onDeleteClick()
                        }
                        Button("取消", role: .cancel) { }
                    } message: {
                        Text("此操作无法撤销")
                    }
                    BottomOptionButton("下载", icon: "square.and.arrow.down", disabled: self.vm.selectedCount == 0, action: self.vm.onDownloadClick)
                    BottomOptionButton("退出", icon: "arrow.right.to.line.square"){
                        FilePage().relaunch()
                    }
                }.background(Color.gl.bgPrimary)
                Color.gl.bgPrimary.frame(height: 30)
            }
            .frame(maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
        } else {
            EmptyView()
        }
    }
}
