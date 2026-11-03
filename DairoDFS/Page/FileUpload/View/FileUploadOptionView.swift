//
//  FileOptionBarView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI
import DairoUI_IOS

struct FileUploadOptionView: View {
    
    @EnvironmentObject var vm: FileUploadViewModel
    @State private var showDeleteAlert = false
    
    /// 是否跳转设置页面
    @State var isShowSet = false
    
    var body: some View {
        VStack(spacing: 8){
            NavigationLink(destination: FileUploadSetPage(), isActive: self.$isShowSet){
                EmptyView()
            }
            HStack{
                Text("已选择:\(self.vm.checked.count)")
                    .font(.footnote)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .liquidGlassBackground(in: Capsule())
                Spacer()
            }.padding(.horizontal)
            HStack{
                OptionButton("全选", icon: "checklist.checked", action: self.vm.onCheckAllClick)
                OptionButton("删除", icon: "trash", disabled: self.vm.checked.isEmpty){
                    self.showDeleteAlert = true
                }
                .alert("确认删除吗？", isPresented: self.$showDeleteAlert) {
                    Button("删除", role: .destructive) {
                        self.vm.onDeleteClick()
                    }
                    Button("取消", role: .cancel) { }
                } message: {
                    Text("此操作无法撤销")
                }
                OptionButton("全暂停", icon: "pause.circle", action: self.vm.onPauseAllClick)
                OptionButton("全开始", icon: "play.circle", action: self.vm.onStartAllClick)
                OptionButton("设置", icon: "gearshape"){
                    self.isShowSet = true
                }
            }
        }
        .padding(.vertical, 8)
    }
}

