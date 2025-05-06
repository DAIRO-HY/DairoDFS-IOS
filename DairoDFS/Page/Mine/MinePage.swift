//
//  MinePage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/25.
//

import SwiftUI
import DairoUI_IOS

struct MinePage: View {
    
    ///主题选择数据
    private let themeData = [SettingPickerData("跟随系统",0),SettingPickerData("明亮模式",1),SettingPickerData("黑暗模式",2)]
    
    ///功能模式数据
    private let functionData = [SettingPickerData<Int>("文件模式",0),SettingPickerData<Int>("相册模式",1)]
    
    //主题设置值
    @AppStorage("theme") private var theme = 0
    
    //功能模式
    @AppStorage("functionType") private var functionType = 0
    
    var body: some View {
        NavigationView{
            VStack{
                SettingStack(embedInNavigationStack: false){
                    SettingPage(title:"我的"){
                        SettingGroup{
                            SettingNavigationLink("用户名",tip: "这里是提示内容") {
                                LoggedPage().anyView
                            }
                            .iconSize(60)
                            .iconRadius(30)
                            .icon("sparkles", backgroundColor: Color.pink)
                            .isVertical(true)
                        }
                        SettingGroup{
                            SettingButton("我的分享", tip:"点击查看"){
                            }
                            .icon("paperplane.fill", backgroundColor: Color.blue)
                            
                            SettingButton("回收站"){
                            }
                            .icon("trash.fill", backgroundColor: Color.green)
                            SettingButton("传输列表"){
                                
                            }
                            .icon("arrow.trianglehead.2.clockwise.rotate.90.circle.fill", backgroundColor: Color.pink)
                        }
                        SettingGroup{
                            SettingButton("缓存管理"){
                                
                            }.icon("opticaldiscdrive.fill", backgroundColor: Color.cyan)
                            
                            SettingButton("修改密码"){
                                
                            }.icon("lock.open.rotation", backgroundColor: Color.orange)
                        }
                        SettingGroup{
                            SettingPicker("切换主题",data: self.themeData, value: self.$theme)
                                .icon("paintbrush.fill", backgroundColor: Color.red)
                            
                            SettingPicker("功能模式",data: self.functionData, value: self.$functionType)
                                .icon("die.face.4.fill", backgroundColor: Color.purple)
                        }
                        SettingGroup{
                            SettingButtonSingle("退出登录"){
                                SettingShared.logout()
                                LoginPage().relaunch()
                            }
                        }
                    }
                }
                HomeTabView(.MINE_PAGE)
            }
        }
    }
}

#Preview {
    MinePage()
}
