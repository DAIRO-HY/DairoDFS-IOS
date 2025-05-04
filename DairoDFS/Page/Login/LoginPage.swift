//
//  LoginPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/22.
//

import SwiftUI
import DairoUI_IOS

struct LoginPage: View {
    
    //登录信息
    @ObservedObject private var loginInfo : LoginViewModel
    
    init(_ loginInfo: LoginViewModel = LoginViewModel(domain: "http://192.168.1.60:8031/", name: "admin", pwd: "111111")) {
        self.loginInfo = loginInfo
    }
    
    var body: some View {
        SettingStack(embedInNavigationStack: true) {
            SettingPage(title:"添加账号") {
                SettingCustomView {
                    Image("logo")
                        .frame(maxWidth: .infinity)
                        .padding(32)
                }
                SettingGroup{
                    SettingTextField(title: "服务器", text: $loginInfo.domain, placeholder: "例 192.168.1.100:8031")
                    SettingTextField(title: "用户名", text: $loginInfo.name, placeholder: "请输入用户名")
                    SettingTextField(title: "密码", text: $loginInfo.pwd, placeholder: "请输入密码")
                }
                SettingGroup{
                    if self.loginInfo.editLoggedIndex == nil{
                        SettingButtonSingle("登录",action: self.onLoginClick)
                    }else{
                        SettingButtonSingle("保存",action: self.onSaveClick)
                    }
                }
                SettingCustomView {
                    HStack{
                        Button(action: {
                            LoggedPage().relaunch()
                        }){
                            Text("选择账号").font(.subheadline).foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: {
                            //TODO:
                        }){
                            Text("忘记密码").font(.subheadline).foregroundColor(.secondary)
                        }
                    }.padding(.horizontal)
                }
            }
        }
    }
    
    /**
     登录按钮点击事件
     */
    private func onLoginClick(){
        var domain = self.loginInfo.domain.trim()
        if domain.isEmpty {
            Toast.show("服务器必填")
            return
        }
        if !domain.hasPrefix("http://") && !domain.hasPrefix("https://") {
            
            //补全url
            domain = "http://" + domain;
        }
        
        if domain.hasSuffix("/") {
            
            //去掉最后一个/
            domain.removeLast()
        }
        
        //用户名
        if self.loginInfo.name.isEmpty {
            Toast.show("用户名必填")
            return
        }
        
        //登录密码
        var pwd = self.loginInfo.pwd
        if pwd.isEmpty {
            Toast.show("密码必填")
            return
        }
        //        if (pwd.length != 32) {
        //          pwd = pwd.md5;
        //        }
        pwd = pwd.md5
        
        //
        var loggedUserList = SettingShared.loggedUserList;
        
        //登录信息
        let loginInfo = AccountInfo(domain: domain, name: self.loginInfo.name, pwd: pwd)
        SettingShared.login(loginInfo, success:{
            //          if (this.widget.type == LoginType.EDIT) {
            //            //如果当前时编辑操作
            //            for (var it in loggedUserList) {
            //              //先取消内部所有登录状态
            //              it.isLogining = false;
            //            }
            //
            //            //取出当前要编辑的用户
            //            var editUser = loggedUserList.firstWhere((it) {
            //              return it.name == this.widget.account.name && it.domain == this.widget.account.domain;
            //            });
            //            editUser.domain = loginInfo.domain;
            //            editUser.name = loginInfo.name;
            //            editUser.pwd = loginInfo.pwd;
            //            editUser.isLogining = true;
            //
            //            //重新保存列表，替换当前编辑的那一条数据
            //            SettingShared.loggedUserList = loggedUserList;
            //          }
            MinePage().relaunch()
        })
    }
    
    /**
     保存点击事件
     */
    private func onSaveClick(){
        
    }
}

#Preview {
    LoginPage()
}
