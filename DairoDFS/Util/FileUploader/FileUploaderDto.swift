//
//  FileUploaderDto.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/08/23.
//

import Foundation
import DairoUI_IOS


struct FileUploaderDto : Hashable{
    
    /// 该上传任务的唯一id
    let id: Int64
    
    /// 文件bookmarkData数据
    let bookmarkData: Data
    
    /// 文件名
    let name: String
    
    /// 文件大小
    let size: Int64
    
    /// 文件大小
    let uploadedSize: Int64
    
    /// 文件MD5
    let md5: String?
    
    /// 服务端DFS文件保存路径
    let dfsPath: String
    
    /// 文件状态 0:等待上传 1:上传中 2:暂停中 3:上传失败  10:上传完成
    let state: Int8
    
    /// 创建时间戳(秒)
    let date: Int
    
    /// 上传失败的错误消息
    let error: String?
    
    init(id: Int64, bookmarkData: Data, name: String, size: Int64, uploadedSize: Int64, md5: String?, dfsPath: String, state: Int8, date: Int, error: String?) {
        self.id = id
        self.bookmarkData = bookmarkData
        self.name = name
        self.size = size
        self.uploadedSize = uploadedSize
        self.md5 = md5
        self.dfsPath = dfsPath
        self.state = state
        self.date = date
        self.error = error
    }
}
