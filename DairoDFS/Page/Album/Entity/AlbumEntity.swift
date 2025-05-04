//
//  AlbumEntity.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//
class AlbumEntity{
    
    let model: AlbumModel

    /// 是否选中
    var isSelected = false

    init(_ model: AlbumModel) {
        self.model = model
    }

    ///得到文件预览url
//    String get preview => "/app/files/preview/${this.id}/${this.name}";
    
    /// 是否有缩略图
    var hasThumb: Bool{
        return !self.model.thumb.isEmpty
    }
    
    ///得到缩略图URL
    var thumb: String{
        return SettingShared.domainNotNull + self.model.thumb + "?extra=thumb&_token=" + SettingShared.token
    }
}
