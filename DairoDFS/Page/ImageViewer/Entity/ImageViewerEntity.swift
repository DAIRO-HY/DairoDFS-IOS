//
//  ImageViewerEntity.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/05.
//
struct ImageViewerEntity{
    
    /// 文件id
    let id: Int64

    /// 名称
    let name: String

    /// 文件缩略图
    let thumb: String
    
    /// 是否有缩略图
    var hasThumb: Bool{
        return !self.thumb.isEmpty
    }
    
    ///得到缩略图URL
    var Thumb: String{
        return SettingShared.domainNotNull + self.thumb + "?extra=thumb&_token=" + SettingShared.token
    }
}
