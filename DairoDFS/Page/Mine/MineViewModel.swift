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
    init() {
        self.logged = SettingShared.loggedUserList.first{$0.isLogining}!
    }
}
