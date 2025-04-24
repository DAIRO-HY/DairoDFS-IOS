//
//  File.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/22.
//

import SwiftUI
import DairoUI_IOS

class FileViewModel3 : ObservableObject{
    
    ///显示等待框
    @Published var showWaiting = false
    
    ///显示等待框
    @Published var time = String(Date().timeIntervalSince1970)
    
    init(){
        debugPrint("-->FileViewModel3.init.\(time)")
    }
    
    deinit{
        debugPrint("-->FileViewModel3.deinit")
    }
}

struct File3: View {
    
    @StateObject var vm = FileViewModel3()
    var body: some View {
        RootView{
            VStack{
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                NavigationLink("NEXT", destination: File3())
            }
            .navigationTitle("文件列表3")
            .navigationBarTitleDisplayMode(.inline)
        }.onAppear{
            debugPrint("-->File3.onAppear")
        }.onDisappear{
            debugPrint("-->File3.onDisappear")
        }
    }
}

#Preview {
    File3()
}
