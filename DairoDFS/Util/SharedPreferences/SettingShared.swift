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
        MineApi._init().post{
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
    
    /// 是否登录
    static var isLogin: Bool{ !SettingShared.token.isEmpty }
    
    /// 退出登录
    static func logout() {
        var logined = SettingShared.loggedUserList
        for i in 0 ..< logined.count{
            logined[i].isLogining = false
        }
        SettingShared.loggedUserList = logined
        SettingShared.token = ""
    }
    
    /// 登录
    static func login(_ accountInfo: AccountInfo, success: @escaping () -> Void) {
        
        //先记录登录之前的服务器，如果登录失败，则还原之前的服务器
        let oldDomain = SettingShared.domain
        SettingShared.domain = accountInfo.domain;
        LoginApi.doLogin(name: accountInfo.name, pwd: accountInfo.pwd, deviceId: Const.deviceId).fail{
            
            //登录失败，将服务器还原
            SettingShared.domain = oldDomain
            Toast.show($0.msg!)
        }.post{ loginInfo in//登录成功
            var loggedUserList = SettingShared.loggedUserList
            
            //标记是否是已经登录过的账户
            var isLogined = false
            for i in 0 ..< loggedUserList.count{
                let item = loggedUserList[i]
                if item.domain == accountInfo.domain && item.name == accountInfo.name{
                    isLogined = true
                    loggedUserList[i].isLogining = true
                }else{
                    loggedUserList[i].isLogining = false
                }
            }
            
            var accountInfo = accountInfo
            if !isLogined{//这是一个新登录用户
                accountInfo.isLogining = true
                loggedUserList.append(accountInfo)
            }
            SettingShared.loggedUserList = loggedUserList
            SettingShared.token = loginInfo.token
            
            //后台加载用户信息
            SettingShared.loadInBackground()
            
            //清空缓存的文件列表
            DfsFileShared.clear()
            
            //通知登录账户更新
            //            EventUtil.post(EventCode.ACCOUNT_CHANGE)
            success()
        }
    }
    
    /*----------------------------------------------------------------------------------*/
    
    /// 同时下载文件数
    static var downloadSyncCount: Int{
        get{
            let value = UserDefaults.standard.integer(forKey: "DOWNLOAD_SYNC_COUNT")
            if value == 0{
                SettingShared.downloadSyncCount = 1
                return 1
            }
            return value
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "DOWNLOAD_SYNC_COUNT");
        }
    }
    
    /*----------------------------------------------------------------------------------*/
    
    /// 同时上传文件数
    static var uploadSyncCount: Int{
        get {
            let value = UserDefaults.standard.integer(forKey: "UPLOAD_SYNC_COUNT")
            if value == 0{
                SettingShared.uploadSyncCount = 1
                return 1
            }
            return value
        }
        
        set{
            UserDefaults.standard.set(newValue, forKey: "UPLOAD_SYNC_COUNT");
        }
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
