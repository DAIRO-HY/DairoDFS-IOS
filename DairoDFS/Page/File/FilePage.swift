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
                FileOptionBarView()
                FilesView().environmentObject(self.fileVm)
                FileOptionView().environmentObject(self.fileVm)
                TabView(.FILE_PAGE)
            }
            .navigationTitle("文件列表")
            .navigationBarHidden(true)
        }.onAppear{
            debugPrint("-->File.onAppear")
        }.onDisappear{
            debugPrint("-->File.onDisappear")
        }
    }
}

#Preview {
    FilePage()
}
