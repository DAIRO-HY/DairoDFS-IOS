//
//  MinePage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/25.
//

import SwiftUI
import DairoUI_IOS

struct MinePage: View {
    var body: some View {
        SettingStack(embedInNavigationStack: true){
            SettingPage(title:"我的"){
                SettingGroup{
                    SettingButton(iconSize:60,iconRadius: 30, title: "用户名",tip: "这里是提示内容",isVertical: true) {
                        LoggedPage().relaunch()
                    }
                    .icon(icon: .system(icon: "sparkles", backgroundColor: Color.pink))
                }
                SettingGroup{
                    SettingButton(
                        icon: .system(icon: "paperplane.fill", foregroundColor: Color.white, backgroundColor: Color.blue),
                        title: "我的分享", tip:"点击查看"){
                    }
                    SettingButton(
                        icon: .system(icon: "trash.fill", foregroundColor: Color.white, backgroundColor: Color.green),
                        title: "回收站"){
                        
                    }
                    SettingButton(
                        icon: .system(icon: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill", foregroundColor: Color.white, backgroundColor: Color.pink),
                        title: "传输列表"){
                        
                    }
                }
                SettingGroup{
                    SettingButton(
                        icon: .system(icon: "opticaldiscdrive.fill", foregroundColor: Color.white, backgroundColor: Color.cyan),
                        title: "缓存管理"){
                        
                    }
                    SettingButton(
                        icon: .system(icon: "lock.open.rotation", foregroundColor: Color.white, backgroundColor: Color.orange),
                        title: "修改密码"){
                        
                    }
                }
                SettingGroup{
                    SettingButton(
                        icon: .system(icon: "paintbrush.fill", foregroundColor: Color.white, backgroundColor: Color.red),
                        title: "切换主题", tip: "跟随系统"){
                        
                    }
                    SettingButton(
                        icon: .system(icon: "die.face.4.fill", foregroundColor: Color.white, backgroundColor: Color.purple),
                        title: "功能模式", tip: "文件模式"){
                        
                    }
                }
                SettingGroup{
                    SettingButtonSingle(title: "退出登录"){
                        SettingShared.logout()
                        LoginPage().relaunch()
                    }
                }
            }
        }
    }
}

#Preview {
    MinePage()
}
