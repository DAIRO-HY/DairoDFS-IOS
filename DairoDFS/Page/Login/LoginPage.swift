//
//  LoginPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/22.
//

import SwiftUI
import DairoUI_IOS

struct LoginPage: View {
    
    //登录信息,系统弹窗等导致App状态变化时,页面会重新创建,必须用StateObject才能保留已输入的内容
    @StateObject private var loginInfo : LoginViewModel
    
    init(_ loginInfo: LoginViewModel = LoginViewModel(domain: "", name: "", pwd: "")) {
        self._loginInfo = StateObject(wrappedValue: loginInfo)
    }
    
    var body: some View {
        SettingStack(embedInNavigationStack: true) {
            SettingPage(title: self.loginInfo.editLoggedIndex == nil ? "添加账号" : "编辑账号") {
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
                    SettingButtonSingle(self.loginInfo.editLoggedIndex == nil ? "登录" : "保存",action: self.onLoginClick)
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

        //小屏手机上键盘会挡住登录按钮,信息都填好时按键盘上的回车直接登录
        .onSubmit {
            if !self.loginInfo.domain.isEmpty && !self.loginInfo.name.isEmpty && !self.loginInfo.pwd.isEmpty{
                self.onLoginClick()
            }
        }
    }
    
    /**
     登录/保存按钮点击事件
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
        SettingShared.login(domain: domain, name: self.loginInfo.name, pwd: pwd, editIndex: self.loginInfo.editLoggedIndex, success:{
            MinePage().relaunch()
        })
    }
}

#Preview {
    LoginPage()
}
