//
//  LoginPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/22.
//

import SwiftUI
import DairoUI_IOS

class ModifyPwdViewModel: ObservableObject {
    
    /// 旧密码
    @Published var oldPwd = ""
    
    /// 新密码
    @Published var pwd = ""
    
    /// 确认新密码
    @Published var repwd = ""
    
    /// 修改按钮点击事件
    func onModifyClick(){
        if self.oldPwd.isEmpty{
            Toast.show("请输入旧密码")
            return
        }
        if self.pwd.isEmpty{
            Toast.show("请输入新密码")
            return
        }
        if self.pwd != self.repwd{
            Toast.show("确认密码和新密码不一致")
            return
        }
        ModifyApi.modify(oldPwd: self.oldPwd, pwd: self.pwd).post {
            Toast.show("修改成功,请重新登录")
            
            //得到当前登录的账号信息
            let loginAccount = SettingShared.loggedUserList.first{$0.isLogining}!
            SettingShared.logout()
            LoginPage(LoginViewModel(domain: loginAccount.domain, name: loginAccount.name, pwd: "")).relaunch()
        }
    }
}
