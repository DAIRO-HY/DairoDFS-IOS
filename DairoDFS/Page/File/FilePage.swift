//
//  File.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/22.
//

import SwiftUI
import DairoUI_IOS

struct FilePage: View {
    
    @StateObject var fileVm = FileViewModel()
    
    var body: some View {
        NavigationView{
            VStack{
                FileOptionBarView().environmentObject(self.fileVm)
                FilesView().environmentObject(self.fileVm)
                FileOptionView().environmentObject(self.fileVm)
                HomeTabView(.FILE_PAGE)
            }
            .navigationTitle("文件列表")
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    FilePage()
}
