//
//  DairoDFSApp.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/09.
//

import SwiftUI
import DairoUI_IOS

import AVFoundation
import AVKit


@main
struct DairoDFSApp: App {
    
    //功能模式
    @AppStorage("functionType") private var functionType = 0
    
    /**
     一些初始化操作,比如:创建文件夹等
     */
    init(){
        
        //创建文件列表缓存目录
        DfsFileShared.makeDir()
        
        //测试用
//        let ids = DownloadDBUtil.selectIdByUsedDate(Int(Date().timeIntervalSince1970))
//        DownloadManager.delete(ids)
    }
    var body: some Scene {
        WindowGroup {
            
//            NavigationView{
//                VStack{
//                    NavigationLink(destination: DownloadPage()){
//                        Text("页面跳转")
//                    }
//                    Button(action:{
//                        for i in 1 ... 100{
//                            let id = "id:\(i)"
//                            DownloadManager.delete([id])
//                        }
//                    }){
//                        Text("删除数据")
//                    }.padding()
//                    
//                    Button(action:{
//                        var list = [(String,String)]()
//                        for i in 1 ... 100{
//                            let id = "id:\(i)"
//                            DownloadManager.delete([id])
//                            list.append((id, "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=100"))
//                        }
//                        try? DownloadManager.save(list)
//                    }){
//                        Text("添加数据")
//                    }.padding()
//                    
//                    
//                    ScrollView {
//                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 2), spacing: 5) {
//                            ForEach(1...1, id: \.self){i in
//                                CacheImage("http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=20&i=\(i)")
//                                    .frame(width: 150, height: 150)
//                            }
//                        }
//                    }
//                }
//            }
            
            
            
            
                                    RootView{
                                        if SettingShared.isLogin{
//                                            FilePage()
                                            if functionType == FunctionModel.FILE{
                                                FilePage()
                                            } else if functionType == FunctionModel.ALBUM{
                                                AlbumPage()
                                            } else {
            
                                            }
                                        }else{
                                            LoginPage()
                                        }
                                    }
        }
    }
    
    
    private func getDownloadDto() -> DownloadDto{
        let dfb = DownloadDto(
            id:"ID12345678",
            url: "",
            name:"文件名",
            size:12334,
            state: 0,
            saveType: 1,
            date: 1234567,
            useDate: 1234556,
            error: nil
        )
        return dfb
    }
    
    
}

