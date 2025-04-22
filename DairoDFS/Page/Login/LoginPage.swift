//
//  LoginPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/22.
//

import SwiftUI
import DairoUI_IOS

struct LoginPage: View {
    
    
    @State private var userName = ""
    
    ///当前选择的视图标记1:添加账号  2:选择现有账号
    @AppStorage("viewTag") private var viewTag = 1
    
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
                SettingTextField(title: "服务器", text: $userName, placeholder: "例 192.168.1.100:8031")
                SettingTextField(title: "用户名", text: $userName, placeholder: "请输入用户名")
                SettingTextField(title: "密码", text: $userName, placeholder: "请输入密码")
            }
            SettingGroup{
                SettingButtonSingle(title: "登录"){
                    
                }
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
}

#Preview {
    LoginPage()
}
