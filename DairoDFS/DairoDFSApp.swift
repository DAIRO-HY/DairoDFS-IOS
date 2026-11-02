//
//  DairoDFSApp.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/09.
//

import SwiftUI
import DairoUI_IOS

import AVFoundation


@main
struct DairoDFSApp: App {
    
    //功能模式
    @AppStorage("functionType") private var functionType = 0
    
    //App前后台状态
    @Environment(\.scenePhase) private var scenePhase
    
    /**
     一些初始化操作,比如:创建文件夹等
     */
    init(){
        
        //提前创建SDK实例,App重启后未完成的下载和上传会自动继续
        _ = try? FileSdkUtil.get()
        
        //设置后台播放,否则在静音模式下,导致播放视频时没有声音
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(AVAudioSession.Category.playback)
        try? audioSession.setActive(true)
    }
    var body: some Scene {
        WindowGroup {
                                    RootView{
                                        if SettingShared.isLogin{
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
        .onChange(of: self.scenePhase) { phase in
            switch phase {
            case .active:
                FileSdkUtil.checkServer()
            case .background:
                FileSdkUtil.flush()
            default:
                break
            }
        }
    }
}
