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
    
    init(_ loginInfo: LoginViewModel = LoginViewModel(domain: "http://127.0.0.1:8031", name: "admin", pwd: "111111")) {
        self.loginInfo = loginInfo
    }
    
    var body: some View {
        SettingStack(embedInNavigationStack: true) {
            SettingPage(title:"添加账号") {
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
                    SettingTextField(title: "服务器", text: $loginInfo.domain, placeholder: "例 192.168.1.100:8031")
                    SettingTextField(title: "用户名", text: $loginInfo.name, placeholder: "请输入用户名")
                    SettingTextField(title: "密码", text: $loginInfo.pwd, placeholder: "请输入密码", type: .password)
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
                            LoggedPage(embedInNavigationStack: true).relaunch()
                        }){
                            Text("选择账号").font(.subheadline).foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: {
                            Toast.show("忘记密码请联系管理员")
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
        let pwd = self.loginInfo.pwd
        if pwd.isEmpty {
            Toast.show("密码必填")
            return
        }
        SettingShared.login(domain: domain, name: self.loginInfo.name, pwd: pwd, success:{
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
