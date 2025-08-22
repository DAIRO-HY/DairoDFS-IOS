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
    let id: String
    
    /// 文件URL
    let path: String
    
    /// 文件名
    let name: String
    
    /// 文件大小
    let size: Int64
    
    /// 文件状态 0:等待上传 1:上传中 2:暂停中 3:上传失败  10:上传完成
    let state: Int8
    
    /// 创建时间戳(秒)
    let date: Int
    
    /// 上传失败的错误消息
    let error: String?
    
    init(id: String, path: String, name: String, size: Int64, state: Int8, date: Int, error: String?) {
        self.id = id
        self.path = path
        self.name = name
        self.size = size
        self.state = state
        self.date = date
        self.error = error
    }
}
