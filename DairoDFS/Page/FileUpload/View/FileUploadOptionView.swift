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
            Divider()
            HStack{
                Text("已选择:\(self.vm.checked.count)").foregroundColor(.secondary)
                Spacer()
            }.padding(.horizontal, 5)
            Divider()
            HStack{
                BottomOptionButton("全选", icon: "checklist.checked", action: self.vm.onCheckAllClick)
                BottomOptionButton("删除", icon: "trash", disabled: self.vm.checked.isEmpty){
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
                BottomOptionButton("全暂停", icon: "pause.circle", disabled: self.vm.saveType == 0, action: self.vm.onPauseAllClick)
                BottomOptionButton("全开始", icon: "play.circle", disabled: self.vm.saveType == 0, action: self.vm.onStartAllClick)
                BottomOptionButton("设置", icon: "gearshape"){
                    self.isShowSet = true
                }
            }
        }
    }
}


//#Preview {
//    DownloadOptionTestView()
//}
//
//struct DownloadOptionTestView: View {
//    
//    @StateObject
//    private var vm = DownloadViewModel()
//    var body: some View {
//        NavigationView{
//            DownloadOptionView().environmentObject(self.vm)
//                .navigationTitle("下载页面")
//        }
//    }
//}
