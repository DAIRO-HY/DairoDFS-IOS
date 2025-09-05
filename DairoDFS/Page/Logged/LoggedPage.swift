//
//  LoginPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/22.
//

import SwiftUI
import DairoUI_IOS

struct LoggedPage: View {
    
    ///标记是否编辑模式
    @State private var isEdit = false
    
    ///操作按钮菜单显示
    @State private var showActionMenu = false
    
    /// 显示确认删除框
    @State private var showDeleteAlert = false
    
    @StateObject private var vm = LoggedViewModel()
    private let embedInNavigationStack: Bool
    init(embedInNavigationStack: Bool = false){
        self.embedInNavigationStack = embedInNavigationStack
    }
    
    var body: some View {
        SettingStack(embedInNavigationStack: self.embedInNavigationStack) {
            SettingPage(title:"选择账号") {
                SettingCustomView {
                    ZStack{
                        Image("logo")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .cornerRadius(14)   // 设置圆角半径
                            .padding(32)
                    }.frame(maxWidth: .infinity)
                }
                SettingGroup{
                    SettingCustomView {
                        ForEach(self.vm.loggedUserList.indices, id: \.self){ i in
                            let item = self.vm.loggedUserList[i]
                            Button(action:{
                                self.vm.actionIndex = i
                                self.showActionMenu = true
                            }){
                                HStack{
                                    VStack{
                                        Text(item.name).foregroundColor(Color.gl.black).frame(maxWidth: .infinity, alignment: .leading)
                                        Text(item.domain).font(.subheadline).foregroundColor(.secondary).frame(maxWidth: .infinity, alignment: .leading)
                                    }.frame(maxWidth: .infinity)
                                    Image(systemName: "checkmark").foregroundColor(Color.gl.black).opacity(item.isLogining ? 1 : 0.3)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                        }
                    }
                }
                SettingGroup{
                    SettingButtonSingle("添加账号"){
                        LoginPage().relaunch()
                    }
                }
            }
        }
        .alert("确认删除吗？", isPresented: self.$showDeleteAlert) {
            Button("删除", role: .destructive) {
                self.vm.onDeleteClick()
                
                //退出登录
                SettingShared.logout()
                
                //删除之后重新打开该页面
                LoggedPage().relaunch()
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("该账户处于登录状态，删除后将会退出登录。")
        }
        .confirmationDialog("请选择操作", isPresented: self.$showActionMenu, titleVisibility: .visible) {
                Button("登录") {
                    //点击登录
                    SettingShared.login(self.vm.actionItem, success:{
                        Toast.show("登录成功")
                        FilePage().relaunch()
                    })
                }
                Button("编辑") {
                    let actionItem = self.vm.actionItem
                    LoginPage(LoginViewModel(domain: actionItem.domain, name: actionItem.name, pwd: actionItem.pwd)).relaunch()
                }
                Button("移除") {
                    let actionItem = self.vm.actionItem
                    if actionItem.isLogining{
                        self.showDeleteAlert = true
                    } else {
                        self.vm.onDeleteClick()
                        
                        //重新加载数据
                        self.vm.loadData()
                    }
                }
                Button("取消", role: .cancel) { }
        }
    }
    
    /// 列表模式
    private var listView: SettingGroup{
        return SettingGroup(header: "编辑", headerAction:{ self.isEdit = true }){
            let logged = SettingShared.loggedUserList
            for i in 0..<logged.count{
                let item = logged[i]
                SettingButton(id: i, item.name, tip: item.domain){
                    
                    //点击登录
                    SettingShared.login(item, success:{
                        Toast.show("登录成功")
                        FilePage().relaunch()
                    })
                }.isVertical(true)
            }
        }
    }
    
    /// 列表模式
    private var editView: SettingGroup{
        return SettingGroup(header: "取消", headerAction:{ self.isEdit = false }){
            let logged = SettingShared.loggedUserList
            for i in 0..<logged.count{
                let item = logged[i]
                SettingButton(id: i, item.name, tip: item.domain){
                    
                    //跳转到登录页面
                    let loginVm = LoginViewModel(domain: item.domain, name: item.name, pwd: item.pwd, editLoggedIndex: i)
                    LoginPage(loginVm).relaunch()
                }
                .icon("trash.fill",  backgroundColor: Color.red)
                .iconRadius(14)
                .indicator("pencil.line")
                .isVertical(true)
            }
        }
    }
}

#Preview {
    LoggedPage()
}
