//
//  SettingStore.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/24.
//

import Foundation
import DairoUI_IOS

/// 用户设置
enum SettingStore {
    /*----------------------------------------------------------------------------------*/
    
    /// 会员信息
    private static let KEY_USER = "user"
    
    /// <summary>
    /// 会员信息
    /// </summary>
    static var user: MineModel?{
        get{
            return LocalObjectUtil.read(MineModel.self, SettingStore.KEY_USER)
        }
        
        set{
            _ = LocalObjectUtil.write(newValue, SettingStore.KEY_USER)
        }
    }
    
    /// 后台加载会员信息,不弹出加载等待框
    /// [force] 是否强制刷新数据
    static func loadInBackground() {
        // if (!force && SettingStore.user != null){//非强制刷新的情况下,如果已经加载过,就不需要再加载数据
        //     return;
        // }
        MineApi.info().send{
            SettingStore.user = $0;
        }
    }
    
    /*----------------------------------------------------------------------------------*/
    
    /// 登录Token
    private static let KEY_TOKEN = "TOKEN"
    private static var mToken: String? = nil
    
    /// <summary>
    /// 登录Token
    /// </summary>
    static var token: String {
        get{
            if SettingStore.mToken == nil{
                SettingStore.mToken = UserDefaults.standard.string(forKey: KEY_TOKEN)
            }
            return SettingStore.mToken ?? ""
        }
        set{
            SettingStore.mToken = newValue;
            if newValue.isEmpty {
                UserDefaults.standard.removeObject(forKey: KEY_TOKEN)
                return;
            }
            UserDefaults.standard.set(newValue, forKey: KEY_TOKEN)
        }
    }
    
    /*----------------------------------------------------------------------------------*/
    
    /// 当前服务器域名
    private static let KEY_DOMAIN = "DOMAIN"
    private static var mDomain: String?
    
    static var domainNotNull: String{
        return SettingStore.domain ?? ""
    }
    
    /// 当前服务器是否局域网
    static var isLanServer: Bool{
        return SettingStore.isLanDomain(SettingStore.domainNotNull)
    }
    
    /// 判断服务器地址是否局域网,只看主机名,不区分http和https
    /// - Parameter domain 服务器地址,例如:http://192.168.1.100:8031
    static func isLanDomain(_ domain: String) -> Bool{
        guard let host = URL(string: domain)?.host?.lowercased() else{
            return false
        }
        if host == "localhost" || host.hasSuffix(".local"){
            return true
        }
        if host.contains(":"){//IPv6:本机、唯一本地地址(fc00::/7)、链路本地地址(fe80::/10)
            let ipv6 = host.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
            return ipv6 == "::1"
                || ipv6.hasPrefix("fc") || ipv6.hasPrefix("fd")
                || ipv6.hasPrefix("fe8") || ipv6.hasPrefix("fe9") || ipv6.hasPrefix("fea") || ipv6.hasPrefix("feb")
        }
        
        //IPv4,要完整解析,否则192.168.example.com这样的域名也会被当成局域网
        let parts = host.split(separator: ".", omittingEmptySubsequences: false).map{ UInt8($0) }
        guard parts.count == 4, let a = parts[0], let b = parts[1], parts[2] != nil, parts[3] != nil else{
            return false
        }
        return a == 10
            || a == 127
            || (a == 172 && (16...31).contains(b))
            || (a == 192 && b == 168)
            || (a == 169 && b == 254)
    }
    
    static var domain: String?{
        get {
            if SettingStore.mDomain == nil{
                SettingStore.mDomain = UserDefaults.standard.string(forKey: SettingStore.KEY_DOMAIN)
            }
            return SettingStore.mDomain;
        }
        
        set{
            SettingStore.mDomain = newValue;
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: SettingStore.KEY_DOMAIN)
                return;
            }
            UserDefaults.standard.set(newValue, forKey: SettingStore.KEY_DOMAIN)
        }
        
    }
    /*----------------------------------------------------------------------------------*/
    
    /// 登录过的账号列表,保存的文件名
    private static let KEY_ACCOUNT_LIST = "account_list"
    
    /// 登录过的账号列表
    static var accountList: [AccountInfo]{
        get{
            return LocalObjectUtil.read([AccountInfo].self, SettingStore.KEY_ACCOUNT_LIST) ??  [AccountInfo]()
        }
        
        set{
            _ = LocalObjectUtil.write(newValue, SettingStore.KEY_ACCOUNT_LIST)
            SettingStore.mToken = nil
        }
    }
    
    /// 集群ID
    private static let KEY_CLUSTER_ID = "CLUSTER_ID"
    
    /// 集群ID,同一个集群的服务器共用文件缓存
    static var clusterId: String {
        get{
            return UserDefaults.standard.string(forKey: KEY_CLUSTER_ID) ?? ""
        }
        set{
            UserDefaults.standard.set(newValue, forKey: KEY_CLUSTER_ID)
        }
    }
    
    /*----------------------------------------------------------------------------------*/
    
    /// 是否登录
    static var isLogin: Bool{ !SettingStore.token.isEmpty && !SettingStore.clusterId.isEmpty }
    
    /// 退出登录
    static func logout() {
        var accounts = SettingStore.accountList
        for i in 0 ..< accounts.count{
            if accounts[i].isCurrent{
                accounts[i].token = ""
            }
            accounts[i].isCurrent = false
        }
        SettingStore.accountList = accounts
        SettingStore.token = ""
        FileSdkUtil.syncDfsAccount()
    }
    
    /// 获取当前账号的本地对象缓存名,不同账号的缓存互相隔离,没有账号信息时返回nil,此时不使用缓存
    static func accountObjectName(_ name: String) -> String? {
        guard let account = FileSdkUtil.dfsAccount else{
            return nil
        }
        let folder = "account_cache/" + account.replacingOccurrences(of: ":", with: "_")
        FileUtil.createDirectory(LocalObjectUtil.resolvedFolder + "/" + folder)
        return folder + "/" + name
    }
    
    /// 退出登录,并跳转到登录页面,自动填写当前账号的信息
    static func toLoginPage() {
        let account = SettingStore.accountList.first{$0.isCurrent}
        SettingStore.logout()
        if let account{
            LoginPage(LoginViewModel(domain: account.domain, name: account.name, pwd: "")).relaunch()
        } else {
            LoginPage().relaunch()
        }
    }
    
    /// 登录
    /// - Parameter pwd: 明文密码
    /// - Parameter editIndex: 编辑账号时,账号在已登录列表里的序号,登录成功之后替换这个账号
    static func login(domain: String, name: String, pwd: String, editIndex: Int? = nil, success: @escaping () -> Void) {
        
        //先记录登录之前的服务器，如果登录失败，则还原之前的服务器
        let oldDomain = SettingStore.domain
        let onFail = { (msg: String) in
            SettingStore.domain = oldDomain
            Toast.show(msg)
        }
        SettingStore.domain = domain
        CommonApi.global().error(block: onFail).fail{
            onFail($0.msg ?? "获取服务器信息失败")
        }.send{ global in
            LoginApi.doLogin(name: name, pwd: pwd, deviceId: Const.deviceId).error(block: onFail).fail{
                onFail($0.msg ?? "登录失败")
            }.send{ loginInfo in//登录成功
                let account = AccountInfo(domain: domain, name: name, token: loginInfo.token, clusterId: global.clusterId, isCurrent: true)
                SettingStore.accountList = SettingStore.addAccount(account, editIndex: editIndex)
                SettingStore.clusterId = global.clusterId
                SettingStore.token = loginInfo.token
                
                //加载用户信息,上传任务按用户区分,所以要等用户信息加载完成
                let onUserFail = { (msg: String) in
                    SettingStore.logout()
                    Toast.show(msg)
                }
                MineApi.info().error(block: onUserFail).fail{
                    onUserFail($0.msg ?? "获取用户信息失败")
                }.send{
                    SettingStore.user = $0
                    FileSdkUtil.syncDfsAccount()
                    FileSdkUtil.resumeFailedUploads()
                    success()
                }
            }
        }
    }
    
    /// 将登录成功的账号保存到已登录列表,同一个服务器的同一个用户只保留一条,编辑时保持账号原来的位置
    private static func addAccount(_ account: AccountInfo, editIndex: Int?) -> [AccountInfo] {
        var list = SettingStore.accountList
        list.indices.forEach{ list[$0].isCurrent = false }
        let isSameUser = { (it: AccountInfo) in it.domain == account.domain && it.name == account.name }
        guard let editIndex, list.indices.contains(editIndex) else{
            list.removeAll(where: isSameUser)
            list.append(account)
            return list
        }
        list[editIndex] = account
        return list.enumerated().filter{ $0.offset == editIndex || !isSameUser($0.element) }.map{ $0.element }
    }
    
    /// 切换到已经登录过的账号,票据失效时会跳转到登录页面
    static func switchAccount(_ account: AccountInfo, success: @escaping () -> Void) {
        let oldDomain = SettingStore.domain
        let oldToken = SettingStore.token
        let oldClusterId = SettingStore.clusterId
        let oldAccountList = SettingStore.accountList
        let onFail = { (msg: String) in
            SettingStore.domain = oldDomain
            SettingStore.accountList = oldAccountList
            SettingStore.clusterId = oldClusterId
            SettingStore.token = oldToken
            Toast.show(msg)
        }
        var accountList = oldAccountList
        accountList.indices.forEach{
            accountList[$0].isCurrent = accountList[$0].domain == account.domain && accountList[$0].name == account.name
        }
        SettingStore.domain = account.domain
        SettingStore.accountList = accountList
        SettingStore.clusterId = account.clusterId
        SettingStore.token = account.token
        MineApi.info().error(block: onFail).fail{
            onFail($0.msg ?? "切换账号失败")
        }.send{
            SettingStore.user = $0
            FileSdkUtil.syncDfsAccount()
            success()
        }
    }
    
    /*----------------------------------------------------------------------------------*/
    
    /// 同时下载文件数,0表示没有设置过
    static var fileSdkMaxSavingCount: Int{
        get{ UserDefaults.standard.integer(forKey: "FILE_SDK_MAX_SAVING_COUNT") }
        set{ UserDefaults.standard.set(newValue, forKey: "FILE_SDK_MAX_SAVING_COUNT") }
    }
    
    /// 同时缓存文件数,0表示没有设置过
    static var fileSdkMaxCachingCount: Int{
        get{ UserDefaults.standard.integer(forKey: "FILE_SDK_MAX_CACHING_COUNT") }
        set{ UserDefaults.standard.set(newValue, forKey: "FILE_SDK_MAX_CACHING_COUNT") }
    }
    
    /// 缓存文件保存天数,nil表示没有设置过,0表示永久
    static var fileSdkCacheExpireDays: Int?{
        get{ UserDefaults.standard.object(forKey: "FILE_SDK_CACHE_EXPIRE_DAYS") as? Int }
        set{ UserDefaults.standard.set(newValue, forKey: "FILE_SDK_CACHE_EXPIRE_DAYS") }
    }
    
    /*----------------------------------------------------------------------------------*/
    
    /// 同时上传文件数,0表示没有设置过
    static var fileSdkMaxUploadingCount: Int{
        get{ UserDefaults.standard.integer(forKey: "FILE_SDK_MAX_UPLOADING_COUNT") }
        set{ UserDefaults.standard.set(newValue, forKey: "FILE_SDK_MAX_UPLOADING_COUNT") }
    }
    
    /*----------------------------------------------------------------------------------*/
    
    ///记录最后打开的文件夹
    static var lastOpenFolder: String{
        get{
            return UserDefaults.standard.string(forKey: "LAST_OPEN_FOLDER") ?? "";
        }
        
        set{
            UserDefaults.standard.set(newValue, forKey: "LAST_OPEN_FOLDER");
        }
    }
    /*----------------------------------------------------------------------------------*/
    
    /// 文件列表或表格显示类型
    static var viewType: Int{
        get {
            return UserDefaults.standard.integer(forKey: "VIEW_TYPE")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "VIEW_TYPE");
        }
    }
    
    /*----------------------------------------------------------------------------------*/
    
    /// 自动
    static let VIDEO_QUALITY_AUTO = 0
    
    /// 原画
    static let VIDEO_QUALITY_ORIGINAL = 1
    
    /// 流畅
    static let VIDEO_QUALITY_SMOOTH = 2
    
    /// 视频清晰度选择
    static var videoQuality: Int{
        get{
            return UserDefaults.standard.integer(forKey: "VIDEO_QUALITY")
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "VIDEO_QUALITY")
        }
    }
    
    /// 当前视频清晰都显示标题
    static var videoQualityLabel: String{
        switch self.videoQuality{
        case self.VIDEO_QUALITY_ORIGINAL:
            return "原画"
        case self.VIDEO_QUALITY_SMOOTH:
            return "流畅"
        default:
            return "自动"
        }
    }
    /*----------------------------------------------------------------------------------*/
}
