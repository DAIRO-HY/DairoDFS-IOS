//
//  SwiftUIView.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/12.
//

import SwiftUI

public struct FileUploadPage: View {
    
    @StateObject
    private var vm = FileUploadViewModel()
    
    public init(){
    }
    public var body: some View {
        VStack(spacing: 0){
            ScrollView{
                LazyVStack{
                    ForEach(self.vm.ids, id: \.self) { item in
                        FileUploadItemView(self.vm, item, self.vm.checked.contains(item))
                    }
                }
            }
            FileUploadOptionView().environmentObject(self.vm)
        }.navigationTitle("上传")
    }
}


//struct DownloadTestage: View {
//    var body: some View {
//        NavigationView{
//            VStack{
//                Image(systemName: "document.fill")
//                    .resizable()
//                    .frame(width: 50, height: 50)
//                    .foregroundColor(.white)
//                NavigationLink(destination: DownloadPage()){
//                    Text("页面跳转")
//                }.padding()
//                Button(action:{
//                    var list = [(String,String)]()
//                    var ids = [String]()
//                    for i in 1 ... 100{
//                        let id = "id:\(i)"
//                        ids.append(id)
//                        list.append((id, "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=100"))
//                    }
//                    DownloadManager.delete(ids)
//                    try? DownloadManager.save(list)
//                }){
//                    Text("添加数据")
//                }.padding()
//                
//                Button(action:{
//                    let ids = (1...100).map{
//                        "cache:\($0)"
//                    }
//                    DownloadManager.delete(ids)
//                    for i in 1 ... 100{
//                        let id = "cache:\(i)"
//                        DownloadManager.cache(id, "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=100")
//                    }
//                }){
//                    Text("添加缓存")
//                }.padding()
//            }
//        }
//    }
//}
//
//#Preview {
//    DownloadTestage()
//}
