//
//  File.swift
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
            VStack{
                FileOptionBarView().environmentObject(self.vm)
                FileView().environmentObject(self.vm)
                FileOptionView().environmentObject(self.vm)
                FileAddView().environmentObject(self.vm)
                HomeTabView(.FILE_PAGE)
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name(FileAddView.FILE_ADD_VIEW_SHOW_FLAG))){_ in
                self.vm.isSelectMode = false
                self.vm.isShowAddView.toggle()
            }
            .navigationTitle("文件列表")
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    FilePage()
}
