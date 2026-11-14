//
//  FilePage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/22.
//

import SwiftUI
import DairoUI_IOS

struct FilePage: View {
    
    @StateObject var vm = FileViewModel()
    
    var body: some View {
        NavigationView{
            VStack(spacing: 0){
                
                //顶部和底部的按钮都浮在列表上面
                FileView().environmentObject(self.vm)
                    .scrollTopBar{
                        FileOptionBarView().environmentObject(self.vm)
                    }
                    .safeAreaInset(edge: .bottom, spacing: 0){
                        VStack(spacing: 0){
                            FileOptionView().environmentObject(self.vm)
                            FileAddView().environmentObject(self.vm)
                            HomeTabView(.FILE_PAGE)
                        }
                    }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name(FileAddView.FILE_ADD_VIEW_SHOW_FLAG))){_ in
                self.vm.isSelectMode = false
                self.vm.isShowAddView.toggle()
            }
            .navigationTitle("文件列表")
            .navigationBarHidden(true)
        }
        //iPad上默认是左右分栏,这里要全屏显示
        .navigationViewStyle(.stack)
    }
}

#Preview {
    FilePage()
}
