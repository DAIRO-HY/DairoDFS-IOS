//
//  SwiftUIView.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/12.
//

import SwiftUI
import DairoFileSDK

public struct FileUploadPage: View {
    
    @StateObject
    private var vm = FileUploadViewModel()
    
    public init(){
    }
    public var body: some View {
        VStack(spacing: 0){
            ScrollView{
                LazyVStack{
                    ForEach(self.vm.list, id: \.id) { item in
                        FileUploadItemView(self.vm, item)
                    }
                }
            }
            FileUploadOptionView().environmentObject(self.vm)
        }
        .navigationTitle("上传")
        .onReceive(NotificationCenter.default.publisher(for: FileSdkUtil.EVENT)){
            self.vm.onFileSdkEvent($0.object as! Event)
        }
    }
}
