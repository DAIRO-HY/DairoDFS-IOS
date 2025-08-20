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
                    BottomOptionButton("共有", icon: "square.and.arrow.up"){
                        
                    }
                    BottomOptionButton("删除", icon: "trash"){
                        self.showDeleteAlert = true
                    }
                    .alert("确认删除吗？", isPresented: $showDeleteAlert) {
                        Button("删除", role: .destructive) {
                            //                        self.vm.onDeleteClick()
                        }
                        Button("取消", role: .cancel) { }
                    } message: {
                        Text("此操作无法撤销")
                    }
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
