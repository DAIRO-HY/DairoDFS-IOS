//
//  UploaderConfig.swift
//  Dairo
//
//  Created by zhoulq on 2025/08/13.
//

import Foundation

/// 文件下载的常量配置
enum FileUploaderConfig{
    
    /// 数据库文件保存目录
    static let dbFile = FileUploaderConfig.getDBFile()
    
    /// 获取数据库文件目录
    private static func getDBFile() -> String{
//        var dbURL = URL(string: "file:///Users/zhoulq/dev/java/idea/DairoDFS/data/upload3.sqlite")!
        var dbURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("upload7.sqlite")
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
                    self._maxUploadingCount = 1
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
}
