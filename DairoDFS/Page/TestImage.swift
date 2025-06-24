//
//  TestImage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/08.
//

import SwiftUI
import DairoUI_IOS

struct TestImage1: View {
    var body: some View {
            NavigationLink(destination: TestImage()){
                Text("图片显示")
            }
    }
}

struct TestImageJump: View {
    
    /**
     * 用于操作页面返回
     */
    @Environment(\.presentationMode) var presentation
    
    @State private var showImage = false
    

    var body: some View {
            NavigationLink(destination: TestImage() , isActive: self.$showImage){
                EmptyView()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("BACK"))){ _ in
                    self.presentation.wrappedValue.dismiss()
            }
            .onAppear{
                self.showImage = true
            }
//            NavigationLink(destination: TestImage()){
//                Text("图片显示")
//            }
    }
}

struct TestImage: View {
    var body: some View {
        VStack{
            CacheImage("http://172.20.10.5:8031/d/oq8221/WechatIMG2.jpg?wait=10")
            CacheImage("http://172.20.10.5:8031/d/oq8221/WechatIMG2.jpg?wait=11")
            CacheImage("http://172.20.10.5:8031/d/oq8221/WechatIMG2.jpg?wait=12")
            CacheImage("http://172.20.10.5:8031/d/oq8221/WechatIMG2.jpg?wait=13")
            Button(action:{
                FilePage().relaunch()
            }){
                Text("BUTTON")
            }
            .padding()
            CacheImage("http://172.20.10.5:8031/d/oq8221/WechatIMG2.jpg?wait=14")
            CacheImage("http://172.20.10.5:8031/d/oq8221/WechatIMG2.jpg?wait=15")
            CacheImage("http://172.20.10.5:8031/d/oq8221/WechatIMG2.jpg?wait=16")
            CacheImage("http://172.20.10.5:8031/d/oq8221/WechatIMG2.jpg?wait=17")
            CacheImage("http://172.20.10.5:8031/d/oq8221/WechatIMG2.jpg?wait=18")
        }.onDisappear{
            NotificationCenter.default.post(name: Notification.Name("BACK"), object: nil)
        }
    }
}

#Preview {
    TestImage()
}
