//
//  LoginPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/22.
//

import SwiftUI
import DairoUI_IOS

class LoginViewModel: ObservableObject {
    
    @Published var domain: String
    
    @Published var name: String
    
    @Published var pwd: String
    
    //编辑模式时,当前账号所在的索引
    var editLoggedIndex: Int?
    
    init(domain: String, name: String, pwd: String, editLoggedIndex: Int? = nil) {
        self.domain = domain
        self.name = name
        self.pwd = pwd
        self.editLoggedIndex = editLoggedIndex
    }
}
