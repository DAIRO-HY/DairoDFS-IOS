//
//  File.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/22.
//

import SwiftUI
import DairoUI_IOS


class FileViewModel : ObservableObject{
    
    ///显示等待框
    @Published var showWaiting = false
    
    ///显示等待框
    @Published var time = String(Date().timeIntervalSince1970)
    
    init(){
        debugPrint("-->FileViewModel.init.\(time)")
    }
    
    deinit{
        debugPrint("-->FileViewModel.deinit")
    }
}

struct File: View {
    
    @StateObject var vm = FileViewModel()
    
    var body: some View {
        NavigationView{
            RootView{
                VStack{
                    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                    NavigationLink("NEXT", destination: File2())
                }
                .navigationTitle("文件列表")
                .navigationBarTitleDisplayMode(.inline)
            }
            //            .setTag("文件列表1")
        }.onAppear{
            debugPrint("-->File.onAppear")
        }.onDisappear{
            debugPrint("-->File.onDisappear")
        }
    }
}

#Preview {
    File()
}
