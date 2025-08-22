//
//  DownloadConst.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/13.
//

import Foundation

/// 文件下载的常量配置
enum UploaderConfig{
    
    /// 下载文件保存的文件夹
    static let saveFolder = UploaderConfig.getSaveFolder()
    
    /// 数据库文件保存目录
    static let dbFile = UploaderConfig.getDBFile()
    
    /// 获取下载保存文件夹
    private static func getSaveFolder() -> String{
        
//        var downloadURL = URL(string: "file:///Users/zhoulq/dev/java/idea/DairoDFS/data/temp")!
        var downloadURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("download")
        if !FileManager.default.fileExists(atPath: downloadURL.path){//如果文件夹不存在,则创建文件夹
            try? FileManager.default.createDirectory(at: downloadURL, withIntermediateDirectories: true)
            
            //设置文件夹不允许备份到iCloud
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            try? downloadURL.setResourceValues(values)
        }
        return downloadURL.path
    }
    
    /// 获取数据库文件目录
    private static func getDBFile() -> String{
//        var dbURL = URL(string: "file:///Users/zhoulq/dev/java/idea/DairoDFS/data/upload1.sqlite")!
        var dbURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("upload1.sqlite")
        if !FileManager.default.fileExists(atPath: dbURL.path){//如果文件不存在,则创建文件
            
            //先创建一个空文件
            FileManager.default.createFile(atPath: dbURL.path, contents: nil)
            
            //设置文件不允许备份到iCloud
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            try? dbURL.setResourceValues(values)
        }
        return dbURL.path
    }
    
    
    
    /*----------------------------------------------------------------------------------*/
    
    /// 同时上传文件数
    nonisolated(unsafe) private static var _maxUploadingCount: Int?
    static var maxUploadingCount: Int{
        get {
            if self._maxUploadingCount == nil{
                self._maxUploadingCount = UserDefaults.standard.integer(forKey: "MAX_UPLOADING_COUNT")
                if self._maxUploadingCount == 0{//默认值
                    self._maxUploadingCount = 4
                }
            }
            return self._maxUploadingCount!
        }
        set{
            self._maxUploadingCount = newValue;
            UserDefaults.standard.set(newValue, forKey: "MAX_UPLOADING_COUNT")
        }
        
    }
    /*----------------------------------------------------------------------------------*/
    
    /// 同时缓存文件数
    /// 同时缓存文件数一定要大于同时下载文件数,否则,当保存下载达到上限之后,缓存下载无法工作
    nonisolated(unsafe) private static var _maxCachingCount: Int?
    static var maxCachingCount: Int{
        get {
            if self._maxCachingCount == nil{
                self._maxCachingCount = UserDefaults.standard.integer(forKey: "MAX_CACHING_COUNT")
                if self._maxCachingCount == 0{//默认值
                    self._maxCachingCount = 5
                }
            }
            return self._maxCachingCount!
        }
        set{
            self._maxCachingCount = newValue;
            UserDefaults.standard.set(newValue, forKey: "MAX_CACHING_COUNT")
        }
    }
    /*----------------------------------------------------------------------------------*/
    
    /// 缓存文件保存期限(天)
//    nonisolated(unsafe) private static var _cacheSaveDay: Int?
    static var cacheSaveDay: Int{
        get {
            let _cacheSaveDay = UserDefaults.standard.integer(forKey: "CACHE_SAVE_DAY")
            if _cacheSaveDay == 0{
                return 90
            }
            return _cacheSaveDay
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "CACHE_SAVE_DAY")
        }
    }
    
    /*----------------------------------------------------------------------------------*/
    
//    /// 记录最后一次清理缓存的时间
//    nonisolated(unsafe) private static var _lastClearCacheTime: Int?
//    static var lastClearCacheTime: Int{
//        get {
//            if self._lastClearCacheTime == nil{
//                self._lastClearCacheTime = UserDefaults.standard.integer(forKey: "LAST_CLEAR_CACHE_TIME")
//            }
//            return self._lastClearCacheTime!
//        }
//        set{
//            self._lastClearCacheTime = newValue;
//            UserDefaults.standard.set(newValue, forKey: "LAST_CLEAR_CACHE_TIME")
//        }
//    }
}
