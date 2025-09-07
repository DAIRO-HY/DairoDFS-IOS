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
    
    //视图模型
    @StateObject private var vm = MineViewModel()
    
    //主题设置值
    @AppStorage("theme") private var theme = 0
    
    //功能模式
    @AppStorage("functionType") private var functionType = 0
    
    var body: some View {
        NavigationView{
            VStack(spacing: 0){
                NavigationLink(destination: LoggedPage()){
                    self.topLogoView
                }
                Spacer().frame(height: 10)
                SettingStack(embedInNavigationStack: false){
                    SettingPage{
                        SettingGroup{
//                            SettingButton("我的分享", tip:"点击查看"){
//                            }
//                            .icon("paperplane.fill", backgroundColor: Color.blue)
                            
                            SettingNavigationLink("回收站",tip: "已删除的文件"){
                                AnyView(TrashPage())
                            }.icon("trash.fill", backgroundColor: Color.green)
                            
                            SettingNavigationLink("上传管理",tip: "上传文件列表"){
                                AnyView(FileUploadPage())
                            }.icon("square.and.arrow.up.fill", backgroundColor: Color.cyan)
                            
                            SettingNavigationLink("下载管理",tip: "下载、缓存文件"){
                                AnyView(DownloadPage())
                            }.icon("square.and.arrow.down.fill", backgroundColor: Color.indigo)
                        }
                        SettingGroup{
                            SettingPicker("切换主题",data: self.themeData, value: self.$theme)
                                .icon("paintbrush.fill", backgroundColor: Color.red)
                            
                            SettingPicker("功能模式",data: self.functionData, value: self.$functionType){
                                if $0 == FunctionModel.FILE{
                                    FilePage().relaunch()
                                } else if $0 == FunctionModel.ALBUM{
                                    AlbumPage().relaunch()
                                } else {
                                }
                                return true
                            }
                            .icon("die.face.4.fill", backgroundColor: Color.purple)
                        }
                        SettingGroup{
                            SettingNavigationLink("修改密码"){
                                ModifyPwdPage().anyView
                            }.icon("lock.open.rotation", backgroundColor: Color.orange)
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
            .navigationTitle("我的")
            .navigationBarHidden(true)
        }
    }
    
    /// 顶部头像部分视图
    private var topLogoView: some View {
        HStack {
                Image("logo")
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(1000)
            VStack {
                Text(self.vm.logged.name)
                    .foregroundColor(Color.gl.textPrimaryContent)
                    .font(.title2)
                    .frame(maxWidth: .infinity,alignment: .leading)
                HStack{
                    Text(self.vm.logged.domain).font(.footnote).frame(maxWidth: .infinity,alignment: .leading)
                        .foregroundColor(Color.gl.textPrimarySecondary)
                }
            }.padding(.leading,10)
            Image(systemName: "chevron.right").foregroundColor(.white)
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        .background(Color.gl.bgPrimary)
        
    }
}

#Preview {
    MinePage()
}
