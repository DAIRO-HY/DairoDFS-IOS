//
//  DfsFileVM.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//
class DfsFileEntity{
    
    let fm: FileModel

    /// 是否选中
    var isSelected = false

    init(_ fm: FileModel) {
        self.fm = fm
    }
}
