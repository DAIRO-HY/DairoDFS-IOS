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
    
    var body: some View {
        SettingStack(embedInNavigationStack: true) {
            SettingPage(title:"选择账号") {
                SettingCustomView {
                    Image("logo")
                        .frame(maxWidth: .infinity)
                        .padding(32)
                }
                if isEdit{
                    editView
                } else {
                    listView
                }
                SettingGroup{
                    SettingButtonSingle(title: "添加账号"){
                        LoginPage().relaunch()
                    }
                }
            }
        }
    }
    
    /// 列表模式
    private var listView: SettingGroup{
        return SettingGroup(header: "编辑", headerAction:{ self.isEdit = true }){
            let logged = SettingShared.loggedUserList
            for i in 0..<logged.count{
                let item = logged[i]
                SettingButton(id: i, title: item.name, tip: item.domain, isVertical: true){
                    
                    //点击登录
                    SettingShared.login(item, success:{
                        Toast.show("登录成功")
                        File().relaunch()
                    })
                }
            }
        }
    }
    
    /// 列表模式
    private var editView: SettingGroup{
        return SettingGroup(header: "取消", headerAction:{ self.isEdit = false }){
            let logged = SettingShared.loggedUserList
            for i in 0..<logged.count{
                let item = logged[i]
                SettingButton(
                    id: i,
                    icon: .system(icon: "trash.fill", foregroundColor: Color.white, backgroundColor: Color.red),
                    iconRadius: 14,
                    title: item.name, indicator: "pencil.line", tip: item.domain, isVertical: true){
                        
                        //跳转到登录页面
                        let loginVm = LoginViewModel(domain: item.domain, name: item.name, pwd: item.pwd, editLoggedIndex: i)
                        LoginPage(loginVm).relaunch()
                    }
            }
        }
    }
}

#Preview {
    LoggedPage()
}
