//
//  LoginPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/22.
//

import SwiftUI
import DairoUI_IOS

struct ModifyPwdPage: View {
    
    //密码信息
    @StateObject private var vm = ModifyPwdViewModel()
    
    var body: some View {
        SettingStack(embedInNavigationStack: false) {
            SettingPage(title:"密码修改") {
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
                    SettingTextField(title: "旧密码", text: self.$vm.oldPwd, placeholder: "请输入当前密码", type: .password)
                    SettingTextField(title: "新密码", text: self.$vm.pwd, placeholder: "请输入新密码", type: .password)
                    SettingTextField(title: "确认密码", text: self.$vm.repwd, placeholder: "请确认新密码", type: .password)
                }
                SettingGroup{
                    SettingButtonSingle("修改",action: self.vm.onModifyClick)
                }
            }
        }
    }
}
