//
//  LoginPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/22.
//

import SwiftUI
import DairoUI_IOS

class MineViewModel: ObservableObject {
    
    /// 当前登录的账号信息
    @Published var logged: AccountInfo
    
    /// 当前登录的用户信息
    @Published var user = SettingShared.user
    
    init() {
        self.logged = SettingShared.loggedUserList.first{$0.isLogining}!
    }
    
    /// 刷新用户信息,昵称和头像可能在个人资料页或其他设备上修改过
    func loadUser(){
        self.user = SettingShared.user
        MineApi.info().hide().send{
            SettingShared.user = $0
            self.user = $0
        }
    }
}
