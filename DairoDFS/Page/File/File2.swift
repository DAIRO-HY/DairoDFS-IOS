//
//  File.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/22.
//

import SwiftUI
import DairoUI_IOS

class FileViewModel2 : ObservableObject{
    
    ///显示等待框
    @Published var showWaiting = false
    
    ///显示等待框
    @Published var time = String(Date().timeIntervalSince1970)
    
    init(){
        debugPrint("-->FileViewModel2.init.\(time)")
    }
    
    deinit{
        debugPrint("-->FileViewModel2.deinit")
    }
}

struct File2: View {
    @StateObject var vm = FileViewModel2()
    var body: some View {
        RootView{
            VStack{
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                NavigationLink("NEXT", destination: File3())
            }
            .navigationTitle("文件列表2")
            .navigationBarTitleDisplayMode(.inline)
        }.onAppear{
            debugPrint("-->File2.onAppear")
        }.onDisappear{
            debugPrint("-->File2.onDisappear")
        }
    }
}

#Preview {
    File2()
}
