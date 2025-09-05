//
//  LoginPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/22.
//

import SwiftUI
import DairoUI_IOS

class LoggedViewModel: ObservableObject {
    
    /// 记录当前要操作的索引
    var actionIndex = -1
    
    /// 当前已登录的账号列表
    @Published var loggedUserList = [AccountInfo]()
    
    /// 获取当前操作的账号
    var actionItem: AccountInfo{
        return self.loggedUserList[self.actionIndex]
    }
    
    init() {
        self.loadData()
    }
    
    /// 加载数据
    func loadData(){
        self.loggedUserList = SettingShared.loggedUserList
    }
    
    /// 删除账号点击事件
    func onDeleteClick(){
        let actionItem = self.actionItem
        for i in self.loggedUserList.indices {
            let it = self.loggedUserList[i]
            if it.domain == actionItem.domain && it.name == actionItem.name {
                self.loggedUserList.remove(at: i)
                break
            }
        }
        SettingShared.loggedUserList = self.loggedUserList
    }
}
