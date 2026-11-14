//
//  AccountListViewModel.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/22.
//

import SwiftUI
import DairoUI_IOS

class AccountListViewModel: ObservableObject {
    
    /// 记录当前要操作的索引
    var actionIndex = -1
    
    /// 当前已登录的账号列表
    @Published var accountList = [AccountInfo]()
    
    /// 获取当前操作的账号
    var actionItem: AccountInfo{
        return self.accountList[self.actionIndex]
    }
    
    init() {
        self.loadData()
    }
    
    /// 加载数据
    func loadData(){
        self.accountList = SettingStore.accountList
    }
    
    /// 删除账号点击事件
    func onDeleteClick(){
        let actionItem = self.actionItem
        for i in self.accountList.indices {
            let it = self.accountList[i]
            if it.domain == actionItem.domain && it.name == actionItem.name {
                self.accountList.remove(at: i)
                break
            }
        }
        SettingStore.accountList = self.accountList
    }
}
