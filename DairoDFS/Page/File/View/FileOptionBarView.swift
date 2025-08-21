//
//  FileOptionBarView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI

struct FileOptionBarView: View {
    @EnvironmentObject var fileVm: FileViewModel
    var body: some View {
        HStack{
            Spacer().frame(width: 10)
            self.optionBtn("arrow.left"){
                
            }
            self.optionBtn("house.fill"){//加载首页数据
                self.fileVm.loadSubFile("")
            }
            Text("sdfs").frame(maxWidth: .infinity)
            self.optionBtn(self.fileVm.isSelectMode ? "xmark" : "ellipsis"){
                self.fileVm.isShowAddView = false
                self.fileVm.isSelectMode = !self.fileVm.isSelectMode
                self.fileVm.clearSelected()
            }
            Spacer().frame(width: 10)
        }
        .padding(.bottom, 5)
        .background(Color.gl.bgPrimary)
    }
    
    private func optionBtn(_ icon: String, action: @escaping () -> Void) -> some View{
        return HStack{
            Button(action: action){
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .frame(width: 36,height: 36)
                    .animation(nil, value: self.fileVm.isSelectMode)//禁止过渡动画
            }
            .background(Color.black.opacity(0.5))
            .clipShape(.circle)
            .buttonStyle(.row)
        }
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
