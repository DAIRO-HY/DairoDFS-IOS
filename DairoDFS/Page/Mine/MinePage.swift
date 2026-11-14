//
//  MinePage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/25.
//

import SwiftUI
import DairoUI_IOS
import DairoFileSDK

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
    @AppStorage("FUNCTION_MODE") private var functionMode = 0
    
    var body: some View {
        NavigationView{
            VStack(spacing: 0){
                SettingStack(embedInNavigationStack: false){
                    SettingPage(verticalPadding: 16){
                        SettingGroup{
                            SettingCustomView{
                                NavigationLink(destination: AccountListPage()){
                                    self.topLogoView
                                }
                                .buttonStyle(.row)
                            }
                        }
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
                                AnyView(FileDownloadPage())
                            }.icon("square.and.arrow.down.fill", backgroundColor: Color.indigo)
                        }
                        SettingGroup{
                            SettingPicker("切换主题",data: self.themeData, value: self.$theme)
                                .icon("paintbrush.fill", backgroundColor: Color.red)
                            
                            SettingPicker("功能模式",data: self.functionData, value: self.$functionMode){
                                if $0 == FunctionMode.FILE{
                                    FilePage().relaunch()
                                } else if $0 == FunctionMode.ALBUM{
                                    AlbumPage().relaunch()
                                } else {
                                }
                                return true
                            }
                            .icon("die.face.4.fill", backgroundColor: Color.purple)
                        }
                        SettingGroup{
                            SettingNavigationLink("个人资料",tip: "昵称、头像"){
                                AnyView(ProfilePage())
                            }.icon("person.crop.circle.fill", backgroundColor: Color.blue)
                            
                            SettingNavigationLink("修改密码"){
                                ChangePasswordPage().anyView
                            }.icon("lock.rotation.open", backgroundColor: Color.orange)
                            
                            //临时调试入口,用来查App在后台放久之后图片加载失败的原因,找到原因后删掉
                            SettingNavigationLink("SDK调试"){
                                guard let sdk = try? FileSdkUtil.get() else{
                                    return AnyView(Text("SDK初始化失败"))
                                }
                                return AnyView(FileSdkDebugView(sdk: sdk))
                            }.icon("ladybug.fill", backgroundColor: Color.gray)
                        }
                        SettingGroup{
                            SettingButtonSingle("退出登录"){
                                //让服务端删除这个票据
                                LoginApi.logout().hide().send{}
                                SettingStore.logout()
                                LoginPage().relaunch()
                            }
                        }
                    }
                }
                .safeAreaInset(edge: .bottom, spacing: 0){
                    HomeTabView(.MINE_PAGE)
                }
            }
            .navigationTitle("我的")
            .navigationBarHidden(true)
            .onAppear(perform: self.vm.loadUser)
        }
        //iPad上默认是左右分栏,这里要全屏显示
        .navigationViewStyle(.stack)
    }
    
    /// 顶部头像部分视图
    private var topLogoView: some View {
        HStack {
            UserAvatar(self.vm.user, size: 50)
            VStack(alignment: .leading, spacing: 2){
                Text(self.vm.user?.displayName ?? self.vm.logged.name)
                    .foregroundColor(.primary)
                    .font(.title3)
                Text(self.vm.logged.domain)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 6)
            Image(systemName: "chevron.forward").foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

#Preview {
    MinePage()
}
