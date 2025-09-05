//
//  DfsFileVM.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//
class TrashEntity{
    
    let fm: TrashModel

    /// 是否选中
    var isSelected = false

    init(_ fm: TrashModel) {
        self.fm = fm
    }
}
