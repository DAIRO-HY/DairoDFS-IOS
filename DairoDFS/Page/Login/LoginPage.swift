//
//  LoginPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/22.
//

import SwiftUI
import DairoUI_IOS

struct LoginPage: View {
    
    @State private var domain = ""
    
    @State private var name = ""
    
    @State private var pwd = ""
    
    ///当前选择的视图标记1:添加账号  2:选择现有账号
    @AppStorage("viewTag") private var viewTag = 1
    
    init(){
        Task{
            while true{
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run{
                    RootViewManager.top.time = String(Int(Date().timeIntervalSince1970))
                }
            }
        }
    }
    
    var body: some View {
        SettingStack(embedInNavigationStack:true) {
            if self.viewTag == 1{
                self.addAccounView
            }else{
                self.chooseAccounView
            }
        }
    }
    
    ///添加账号视图
    private var addAccounView: SettingPage {
        return SettingPage(title:"添加账号") {
            SettingCustomView {
                Image("logo")
                    .frame(maxWidth: .infinity)
                    .padding(32)
            }
            SettingGroup{
                SettingTextField(title: "服务器", text: $domain, placeholder: "例 192.168.1.100:8031")
                SettingTextField(title: "用户名", text: $name, placeholder: "请输入用户名")
                SettingTextField(title: "密码", text: $pwd, placeholder: "请输入密码")
            }
            SettingGroup{
                SettingButtonSingle(title: "登录",action: self.onLoginClick)
            }
            SettingCustomView {
                HStack{
                    Button(action: {
                        self.viewTag = 2
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
    
    ///选择账号
    private var chooseAccounView: SettingPage {
        return SettingPage(title:"选择账号") {
            SettingCustomView {
                Image("logo")
                    .frame(maxWidth: .infinity)
                    .padding(32)
            }
            SettingGroup{
                for i in 1...5{
                    SettingButton(title: "服务器\(i)", tip: "服务器http://192.168.1.1\(i):8031",isVertical: true){
                        File().relaunch()
                    }
                }
            }
            SettingGroup{
                SettingButtonSingle(title: "添加账号"){
                    self.viewTag = 1
                }
            }
        }
    }
    
    private func onLoginClick(){
        var domain = self.domain
        if self.domain.isEmpty {
            Toast.show("服务器必填")
            return
        }
        if !domain.hasPrefix("http://") && !domain.hasPrefix("https://") {
            
          //补全url
          domain = "http://" + domain;
        }
        
//        if (domain.hasSuffix("/")) {
//          //去掉最后一个/
//          domain = domain.substring(0, domain.length - 1);
//        }

        //登录名
//        final name = nameController.text;

        //登录密码
        var pwd = self.pwd
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
        let loginInfo = AccountInfo(domain: domain, name: self.name, pwd: pwd)
        SettingShared.login(loginInfo, success:{
            Toast.show("登录成功")
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
//          this.context.relaunch(SettingShared.functionView);
        })
    }
}

#Preview {
    LoginPage()
}
