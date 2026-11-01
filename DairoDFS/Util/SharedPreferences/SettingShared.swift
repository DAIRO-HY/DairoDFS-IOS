//
//  SettingShared.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/24.
//

import Foundation
import DairoUI_IOS

/// 用户设置
enum SettingShared {
    /*----------------------------------------------------------------------------------*/
    
    /// 会员信息
    private static let _KEY_USER = "USER"
    
    /// <summary>
    /// 会员信息
    /// </summary>
    static var user: MineModel?{
        get{
            return LocalObjectUtil.read(MineModel.self, SettingShared._KEY_USER)
        }
        
        set{
            _ = LocalObjectUtil.write(newValue, SettingShared._KEY_USER)
        }
    }
    
    /// 后台加载会员信息,不弹出加载等待框
    /// [force] 是否强制刷新数据
    static func loadInBackground() {
        // if (!force && SettingShared.user != null){//非强制刷新的情况下,如果已经加载过,就不需要再加载数据
        //     return;
        // }
        MineApi.info().send{
            SettingShared.user = $0;
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
            if SettingShared.mToken == nil{
                SettingShared.mToken = UserDefaults.standard.string(forKey: KEY_TOKEN)
            }
            return SettingShared.mToken ?? ""
        }
        set{
            SettingShared.mToken = newValue;
            if newValue.isEmpty {
                UserDefaults.standard.removeObject(forKey: KEY_TOKEN)
                return;
            }
            UserDefaults.standard.set(newValue, forKey: KEY_TOKEN)
        }
    }
    
    /*----------------------------------------------------------------------------------*/
    
    /// 主题模式
    //    private static let _THEME = "THEME";
    //
    //    static var theme: Int {
    //        get{
    //            return UserDefaults.standard.integer(forKey: SettingShared._THEME)
    //        }
    //        set{
    //            UserDefaults.standard.set(newValue, forKey: SettingShared._THEME)
    //        }
    //
    //    }
    
    /*----------------------------------------------------------------------------------*/
    
    /*----------------------------------------------------------------------------------*/
    
    /// 功能模式
    private static let _FUNCTION_MODEL = "FUNCTION_MODEL";
    
    static var functionModel: Int{
        get {
            return UserDefaults.standard.integer(forKey: SettingShared._FUNCTION_MODEL)
        }
        
        set{
            UserDefaults.standard.set(newValue, forKey: SettingShared._FUNCTION_MODEL)
        }
        
        ///获取功能试图
        //      static Widget get functionView {
        //        switch (SettingShared.functionModel) {
        //          case FunctionModel.FILE:
        //            return HomePage();
        //          case FunctionModel.ALBUM:
        //            return AlbumPage();
        //          default:
        //            return SizedBox();
        //        }
        //      }
        
    }
    /*----------------------------------------------------------------------------------*/
    
    /// 当前服务器域名
    private static let _DOMAIN = "DOMAIN";
    static var _domain: String?
    
    static var domainNotNull: String{
        return SettingShared.domain ?? ""
    }
    
    static var domain: String?{
        get {
            if SettingShared._domain == nil{
                SettingShared._domain = UserDefaults.standard.string(forKey: SettingShared._DOMAIN)
            }
            return SettingShared._domain;
        }
        
        set{
            SettingShared._domain = newValue;
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: SettingShared._DOMAIN)
                return;
            }
            UserDefaults.standard.set(newValue, forKey: SettingShared._DOMAIN)
        }
        
    }
    /*----------------------------------------------------------------------------------*/
    
    /// 登录过的用户列表
    static var loggedUserList: [AccountInfo]{
        get{
            return LocalObjectUtil.read([AccountInfo].self, "loggedUserList") ??  [AccountInfo]()
        }
        
        set{
            _ = LocalObjectUtil.write(newValue, "loggedUserList")
            SettingShared.mToken = nil
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
    static var isLogin: Bool{ !SettingShared.token.isEmpty && !SettingShared.clusterId.isEmpty }
    
    /// 退出登录
    static func logout() {
        var logined = SettingShared.loggedUserList
        for i in 0 ..< logined.count{
            if logined[i].isLogining{
                logined[i].token = ""
            }
            logined[i].isLogining = false
        }
        SettingShared.loggedUserList = logined
        SettingShared.token = ""
        FileSdkUtil.syncDfsAccount()
    }
    
    /// 退出登录,并跳转到登录页面,自动填写当前账号的信息
    static func toLoginPage() {
        let account = SettingShared.loggedUserList.first{$0.isLogining}
        SettingShared.logout()
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
        let oldDomain = SettingShared.domain
        let onFail = { (msg: String) in
            SettingShared.domain = oldDomain
            Toast.show(msg)
        }
        SettingShared.domain = domain
        CommonApi.global().error(block: onFail).fail{
            onFail($0.msg ?? "获取服务器信息失败")
        }.send{ global in
            LoginApi.doLogin(name: name, pwd: pwd, deviceId: Const.deviceId).error(block: onFail).fail{
                onFail($0.msg ?? "登录失败")
            }.send{ loginInfo in//登录成功
                let account = AccountInfo(domain: domain, name: name, token: loginInfo.token, clusterId: global.clusterId, isLogining: true)
                SettingShared.loggedUserList = SettingShared.addLoggedUser(account, editIndex: editIndex)
                SettingShared.clusterId = global.clusterId
                SettingShared.token = loginInfo.token
                
                //加载用户信息,上传任务按用户区分,所以要等用户信息加载完成
                let onUserFail = { (msg: String) in
                    SettingShared.logout()
                    Toast.show(msg)
                }
                MineApi.info().error(block: onUserFail).fail{
                    onUserFail($0.msg ?? "获取用户信息失败")
                }.send{
                    SettingShared.user = $0
                    FileSdkUtil.syncDfsAccount()
                    FileSdkUtil.resumeFailedUploads()
                    
                    //清空缓存的文件列表
                    DfsFileShared.clear()
                    success()
                }
            }
        }
    }
    
    /// 将登录成功的账号保存到已登录列表,同一个服务器的同一个用户只保留一条,编辑时保持账号原来的位置
    private static func addLoggedUser(_ account: AccountInfo, editIndex: Int?) -> [AccountInfo] {
        var list = SettingShared.loggedUserList
        list.indices.forEach{ list[$0].isLogining = false }
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
        let oldDomain = SettingShared.domain
        let oldToken = SettingShared.token
        let oldClusterId = SettingShared.clusterId
        let oldLoggedUserList = SettingShared.loggedUserList
        let onFail = { (msg: String) in
            SettingShared.domain = oldDomain
            SettingShared.loggedUserList = oldLoggedUserList
            SettingShared.clusterId = oldClusterId
            SettingShared.token = oldToken
            Toast.show(msg)
        }
        var loggedUserList = oldLoggedUserList
        loggedUserList.indices.forEach{
            loggedUserList[$0].isLogining = loggedUserList[$0].domain == account.domain && loggedUserList[$0].name == account.name
        }
        SettingShared.domain = account.domain
        SettingShared.loggedUserList = loggedUserList
        SettingShared.clusterId = account.clusterId
        SettingShared.token = account.token
        MineApi.info().error(block: onFail).fail{
            onFail($0.msg ?? "切换账号失败")
        }.send{
            SettingShared.user = $0
            FileSdkUtil.syncDfsAccount()
            DfsFileShared.clear()
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
            return UserDefaults.standard.string(forKey: "CURRENT_PATH") ?? "";
        }
        
        set{
            UserDefaults.standard.set(newValue, forKey: "CURRENT_PATH");
        }
    }
    /*----------------------------------------------------------------------------------*/
    
    /// 排列方式
    static var sortType: Int{
        get{
            return UserDefaults.standard.integer(forKey: "SORT_TYPE")
        }
        
        set{
            UserDefaults.standard.set(newValue, forKey: "SORT_TYPE")
        }
    }
    
    /*----------------------------------------------------------------------------------*/
    
    
    /// 排列升降序
    static var sortOrderBy: Int{
        get{
            return UserDefaults.standard.integer(forKey: "SORT_ORDER_BY")
        }
        
        set{
            UserDefaults.standard.set(newValue, forKey: "SORT_ORDER_BY")
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
    
    /// 文件下载目录
    //    static var downloadPath: String{
    //        get {
    //            let downloadPath = UserDefaults.standard.string(forKey: "DOWNLOAD_PATH")
    //            if downloadPath != nil {
    //                return downloadPath;
    //            }
    //        }
    //
    //        set{
    //            UserDefaults.standard.set(newValue, forKey: "DOWNLOAD_PATH");
    //        }
    //    }
    
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
