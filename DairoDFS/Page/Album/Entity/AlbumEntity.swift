//
//  AlbumEntity.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//
class AlbumEntity{
    
    /// 当前序号
    let index: Int

    
    let fm: FileModel
    
    /// 是否选中
    var isSelected = false
    init(_ index: Int, _ fm: FileModel) {
        self.fm = fm
        self.index = index
    }
}
