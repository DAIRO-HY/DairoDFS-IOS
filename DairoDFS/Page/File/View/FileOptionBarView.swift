//
//  FileOptionBarView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI

struct FileOptionBarView: View {
    @EnvironmentObject var vm: FileViewModel
    var body: some View {
        HStack{
            Spacer().frame(width: 10)
            self.optionBtn("arrow.left", action: self.onBackClick)
            self.optionBtn("house.fill"){//加载首页数据
                self.vm.loadSubFile("")
            }
            if !self.vm.currentFolder.isEmpty{//页面刚打开还没有路径
                Text(self.vm.currentFolder)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.head)//路径太长时优先显示当前文件夹
                    .padding(.horizontal, 14)
                    .frame(height: 36)
                    .liquidGlassBackground(in: Capsule())
            }
            Spacer()
//            self.optionBtn("arrow.trianglehead.2.counterclockwise"){
//                self.vm.isShowAddView = false
//                self.vm.isSelectMode.toggle()
//                self.vm.clearSelected()
//            }
            self.optionBtn(self.vm.isSelectMode ? "xmark" : "ellipsis"){
                self.vm.isShowAddView = false
                self.vm.isSelectMode.toggle()
                self.vm.clearSelected()
            }
            Spacer().frame(width: 10)
        }
        .padding(.bottom, 5)
    }
    
    /// 功能按钮
    private func optionBtn(_ icon: String, action: @escaping () -> Void) -> some View{
        return HStack{
            Button(action: action){
                Image(systemName: icon)
                    .foregroundColor(.primary)
                    .frame(width: 36,height: 36)
                    .animation(nil, value: self.vm.isSelectMode)//禁止过渡动画
                    .liquidGlassBackground(in: Circle(), interactive: true)
            }
            .buttonStyle(.plain)
        }
    }
    
    /// 返回上一级按钮点击事件
    private func onBackClick(){
        
        //得到最后打开的文件夹
        let lastOpenFolder = SettingShared.lastOpenFolder
        if lastOpenFolder.isEmpty{
            return
        }
        var folders = lastOpenFolder.split(separator: "/")
        folders.removeLast()
        let parentFolder = "/" + folders.joined(separator: "/")
        self.vm.loadSubFile(parentFolder)
    }
}

#Preview {
    FileOptionBarTestView()
}

struct FileOptionBarTestView: View {
    
    @StateObject
    private var vm = FileViewModel()
    var body: some View {
        NavigationView{
            FileOptionBarView().environmentObject(self.vm)
                .navigationTitle("下载页面")
        }
    }
}
