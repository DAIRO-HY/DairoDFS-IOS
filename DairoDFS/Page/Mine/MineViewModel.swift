//
//  MineViewModel.swift
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
    @Published var user = SettingStore.user
    
    init() {
        self.logged = SettingStore.accountList.first{$0.isCurrent}!
    }
    
    /// 刷新用户信息,昵称和头像可能在个人资料页或其他设备上修改过
    func loadUser(){
        self.user = SettingStore.user
        MineApi.info().hide().send{
            SettingStore.user = $0
            self.user = $0
        }
    }
}
