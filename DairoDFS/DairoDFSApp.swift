//
//  DairoDFSApp.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/09.
//

import SwiftUI
import DairoUI_IOS

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
    }
    var body: some Scene {
        WindowGroup {
            RootView{
                if SettingShared.isLogin{
//                    FilePage()
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
}
