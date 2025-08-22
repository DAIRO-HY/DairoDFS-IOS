//
//  DownloadDBUtil.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/05.
//

import SQLite3
import Foundation

public enum UploaderDBUtilError: Error {
    case dbError(_ msg: String)
}

public enum UploaderDBUtil{
    
    //数据操作锁,防止并发操作
    private static let lock = NSLock()
    
    ///数据库操作静态实例
    nonisolated(unsafe) private static var mDB: OpaquePointer?
    
    static var db: OpaquePointer{
        if self.mDB != nil{
            return self.mDB!
        }
        sqlite3_open(UploaderConfig.dbFile, &mDB)
        self.initDb()
        return self.mDB!
    }
    
    /// 初始化数据库
    private static func initDb(){
        self.exec(self.CREATE_SQL)
        self.updateStateToPauseByUploading()
    }
    
    private static func exec(_ sql: String){
        if sqlite3_exec(self.db, sql, nil, nil, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(self.db))
            print("SQL 执行出错: \(errmsg)")
        }
    }
    
    /// 将正在上传中的任务标记为暂停状态
    /// 该操作仅仅在APP第一次打开时执行,内部无需锁操作
    private static func updateStateToPauseByUploading(){
        let updateSQL = "UPDATE upload set state = 2 where state = 1;"
        var statement: OpaquePointer?
        let err: String?
        if sqlite3_prepare_v2(self.db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                err = nil
            } else {
                err = String(cString: sqlite3_errmsg(self.db))
            }
            sqlite3_finalize(statement)
        } else {
            err = String(cString: sqlite3_errmsg(self.db))
        }
        if let err{
            fatalError(err)
        }
    }
    
    /// 添加一条永久保存数据
    ///
    /// - Parameter id: 文件唯一id
    /// - Parameter path: 文件存储路径
    /// - Throws 错误消息
    static func add(_ list: [FileUploaderDto]) throws{
        
        //当前时间戳
        let now = Int(Date().timeIntervalSince1970)
        let insertSQL = "INSERT INTO upload(id, path, name, size, date) VALUES (?, ?, ?, ?, \(now));"
        var statement: OpaquePointer?
        var err: String?
        self.lock.lock()
        
        // 开启事务
        sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil)
        if sqlite3_prepare_v2(self.db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            for it in list{
                sqlite3_bind_text(statement, 1, (it.id as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 2, (it.path as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 3, (it.name as NSString).utf8String, -1, nil)
                sqlite3_bind_int64(statement, 4, it.size)
                if sqlite3_step(statement) == SQLITE_DONE {
                    err = nil
                } else {
                    err = String(cString: sqlite3_errmsg(self.db))
                }
                sqlite3_reset(statement) // 重置以便下一次绑定
                sqlite3_clear_bindings(statement) // 清除绑定数据
            }
            sqlite3_finalize(statement)
        } else {
            err = String(cString: sqlite3_errmsg(self.db))
        }
        
        // 提交事务
        if err == nil{
            sqlite3_exec(db, "COMMIT", nil, nil, nil)
        } else {
            sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
        }
        self.lock.unlock()
        if let err{
            throw UploaderDBUtilError.dbError(err)
        }
    }
    
    /// 获取一条需要上传的数据
    /// - Returns 需要上传的文件id和文件路径
    static func selectOneForNeedUpload() -> FileUploaderDto?{
        let querySQL = "SELECT id, path, name, size FROM upload WHERE state = 0 ORDER BY date LIMIT 1;"
        var statement: OpaquePointer?
        var result: FileUploaderDto? = nil
        self.lock.lock()
        
        // 准备 SQL 语句
        if sqlite3_prepare_v2(self.db, querySQL, -1, &statement, nil) == SQLITE_OK {
            
            // 遍历查询结果
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let url = String(cString: sqlite3_column_text(statement, 1))
                result = FileUploaderDto(
                    id: id,
                    path: statement!.text(0),
                    name: statement!.text(1),
                    size: statement!.int64(2),
                    state: -1,
                    date: -1,
                    error: nil
                )
            }
            
            // 释放语句
            sqlite3_finalize(statement)
        } else {
            fatalError(String(cString: sqlite3_errmsg(self.db)))
        }
        self.lock.unlock()
        return result
    }
    
    /// 更新文件上传状态
    ///
    /// - Parameter id: 文件唯一id
    /// - Parameter state: 状态
    /// - Parameter error: 上传失败时的错误消息
    static func updateState(_ id: String, _ state: Int, _ error: String? = nil){
        let updateSQL = "UPDATE upload set state = \(state), error = ? where id = '\(id)' and state <> \(state);"
        var statement: OpaquePointer?
        let err: String?
        self.lock.lock()
        if sqlite3_prepare_v2(self.db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            if let error{
                sqlite3_bind_text(statement, 1, (error as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_null(statement, 1)
            }
            if sqlite3_step(statement) == SQLITE_DONE {
                err = nil
            } else {
                err = String(cString: sqlite3_errmsg(self.db))
            }
            sqlite3_finalize(statement)
        } else {
            err = String(cString: sqlite3_errmsg(self.db))
        }
        self.lock.unlock()
        if let err{
            fatalError(err)
        }
    }
    
    /// 暂停所有上传
    static func pauseAll(){
        let updateSQL = "UPDATE upload set state = 2 where state in (0,1);"
        var statement: OpaquePointer?
        let err: String?
        self.lock.lock()
        if sqlite3_prepare_v2(self.db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                err = nil
            } else {
                err = String(cString: sqlite3_errmsg(self.db))
            }
            sqlite3_finalize(statement)
        } else {
            err = String(cString: sqlite3_errmsg(self.db))
        }
        self.lock.unlock()
        if let err{
            fatalError(err)
        }
    }
    
    /// 开始所有上传
    static func startAll(){
        let updateSQL = "UPDATE upload set state = 0,error = null where state in (2,3);"
        var statement: OpaquePointer?
        let err: String?
        self.lock.lock()
        if sqlite3_prepare_v2(self.db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                err = nil
            } else {
                err = String(cString: sqlite3_errmsg(self.db))
            }
            sqlite3_finalize(statement)
        } else {
            err = String(cString: sqlite3_errmsg(self.db))
        }
        self.lock.unlock()
        if let err{
            fatalError(err)
        }
    }
    
    /// 删除记录
    ///
    /// - Parameter id: 文件唯一id
    static func delete(_ ids: [String]){
        let deleteSQL = "DELETE FROM upload where id in ('\(ids.joined(separator: "','"))');"
        var statement: OpaquePointer?
        let err: String?
        self.lock.lock()
        if sqlite3_prepare_v2(self.db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                err = nil
            } else {
                err = String(cString: sqlite3_errmsg(self.db))
            }
            sqlite3_finalize(statement)
        } else {
            err = "Prepare failed."
        }
        self.lock.unlock()
        if let err{
            fatalError(err)
        }
    }
    
    /// 查询一条数据
    /// - Parameter saveType: 文件保存方式
    /// - Returns 文件路径
    static func selectOne(_ id: String) -> FileUploaderDto?{
        let querySQL = "SELECT path,name,size,state,date,error FROM upload WHERE id = '\(id)';"
        var statement: OpaquePointer?
        
        var dto: FileUploaderDto? = nil
        self.lock.lock()
        
        // 准备 SQL 语句
        if sqlite3_prepare_v2(self.db, querySQL, -1, &statement, nil) == SQLITE_OK {
            
            // 遍历查询结果
            if sqlite3_step(statement) == SQLITE_ROW {
                dto = FileUploaderDto(
                    id: id,
                    path: statement!.text(0),
                    name: statement!.text(1),
                    size: statement!.int64(2),
                    state: statement!.int8(3),
                    date: statement!.int(4),
                    error: statement!.textOrNil(5)
                )
            }
        } else {
            fatalError(String(cString: sqlite3_errmsg(self.db)))
        }
        
        // 释放语句
        sqlite3_finalize(statement)
        self.lock.unlock()
        return dto
    }
    
    /// 获取下载列表
    /// - Parameter saveType: 文件保存方式
    /// - Returns 文件路径
//    static func selectListBySaveType(_ saveType: Int8) -> [DownloadDto]{
//        let querySQL = "SELECT id,name,size,state,date,useDate,error FROM download WHERE saveType = \(saveType);"
//        var statement: OpaquePointer?
//        
//        var list = [DownloadDto]()
//        self.lock.lock()
//        
//        // 准备 SQL 语句
//        if sqlite3_prepare_v2(self.db, querySQL, -1, &statement, nil) == SQLITE_OK {
//            
//            // 遍历查询结果
//            while sqlite3_step(statement) == SQLITE_ROW {
//                let dto = DownloadDto(
//                    id: statement!.text(0),
//                    url: "",
//                    name: statement!.text(1),
//                    size: statement!.int64(2),
//                    state: statement!.int8(3),
//                    saveType: saveType,
//                    date: statement!.int(4),
//                    useDate: statement!.int(5),
//                    error: statement!.textOrNil(4)
//                )
//                list.append(dto)
//            }
//        } else {
//            fatalError(String(cString: sqlite3_errmsg(self.db)))
//        }
//        
//        // 释放语句
//        sqlite3_finalize(statement)
//        self.lock.unlock()
//        return list
//    }
    
    /// 通过保存方式获取下载数据
    /// - Parameter saveType: 文件保存方式
    /// - Returns 文件路径
    static func selectAllId() -> [String]{
        let querySQL = "SELECT id FROM upload ORDER BY date desc;"
        var statement: OpaquePointer?
        
        var list = [String]()
        self.lock.lock()
        
        // 准备 SQL 语句
        if sqlite3_prepare_v2(self.db, querySQL, -1, &statement, nil) == SQLITE_OK {
            
            // 遍历查询结果
            while sqlite3_step(statement) == SQLITE_ROW {
                list.append(String(cString: sqlite3_column_text(statement, 0)))
            }
        } else {
            fatalError(String(cString: sqlite3_errmsg(self.db)))
        }
        
        // 释放语句
        sqlite3_finalize(statement)
        self.lock.unlock()
        return list
    }
    
    
    ///建表语句
    private static let CREATE_SQL =
        """
        -- 文件上传表
        CREATE TABLE upload
        (
            id       VARCHAR(32) PRIMARY KEY NOT NULL,
            path     VARCHAR(1024)           NOT NULL,           -- 文件路径
            name     VARCHAR(128)            NOT NULL,           -- 文件名
            size     INTEGER                 NOT NULL DEFAULT 0, -- 文件大小
            state    INTEGER                 NOT NULL DEFAULT 0,-- 文件状态 0:等待上传 1:上传中 2:暂停中 3:上传失败  10:上传完成
            date     INTEGER                 NOT NULL,           -- 文件创建时间戳(秒)
            error    TEXT                    NULL                -- 文件上传失败的错误消息
        );
        CREATE INDEX index_state ON upload (state);
        """
}
