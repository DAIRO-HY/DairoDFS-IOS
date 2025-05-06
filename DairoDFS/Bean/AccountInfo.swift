//
//  AccountInfo.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/24.
//


///登录信息
struct AccountInfo : Codable,Hashable{
    
    /// 服务器名
    var domain: String
    
    /// 用户名
    var name: String
    
    /// 密码
    var pwd: String
    
    /// 是否当前登录的账号
    var isLogining: Bool  = false
}
