//
//  FileUploadNotify.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/08/22.
//


/// 上传通知状态
enum FileUploadNotify: Sendable{
    
    /// 下载暂停
    case pause
    
    /// 下载完成
    case finish
    
    /// 下载进度
    case progress
}
