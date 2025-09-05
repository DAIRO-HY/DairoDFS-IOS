//
//  FileOptionBarView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI
import DairoUI_IOS

struct TrashOptionView: View {
    
    @EnvironmentObject var vm: TrashViewModel
    
    //显示还原对话框
    @State private var showRecoverAlert = false
    
    //显示删除对话框
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 8){
            Divider()
            HStack{
                BottomOptionButton("全选", icon: "checklist.checked", action: self.vm.selectAll)
                BottomOptionButton("还原", icon: "checkmark.arrow.trianglehead.counterclockwise", disabled: self.vm.selectedCount == 0){
                    self.showRecoverAlert = true
                }
                .alert("确认还原选中的吗？", isPresented: $showRecoverAlert) {
                    Button("还原", role: .destructive) {
                        self.vm.onRecoverClick()
                    }
                    Button("取消", role: .cancel) { }
                }
                BottomOptionButton("彻底删除", icon: "trash", disabled: self.vm.selectedCount == 0){
                    self.showDeleteAlert = true
                }
                .alert("确认彻底删除吗？", isPresented: $showDeleteAlert) {
                    Button("彻底删除", role: .destructive) {
                        self.vm.onDeleteClick()
                    }
                    Button("取消", role: .cancel) { }
                } message: {
                    Text("此操作无法撤销")
                }
            }
        }
    }
}
