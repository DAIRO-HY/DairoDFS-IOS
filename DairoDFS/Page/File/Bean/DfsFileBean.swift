//
//  DfsFileVM.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//
struct DfsFileBean{
    
//    /// 文件id
//    let id: Int
//
//    /// 名称
//    let name: String
//
//    /// 大小
//    let int size: Int
//
//    /// 是否文件
//    let bool fileFlag: Bool
//
//    /// 创建日期
//    let String date: String
//
//    /// 文件路径
//    let String path: String
//
//    /// 文件缩略图
//    let String thumb: String
    
    let dfsModel: FileModel

    /// 是否选中
    var isSelected = false

    init(_ fileModel: FileModel) {
//      this.path = "$parent/${fileModel.name}";
        self.dfsModel = fileModel
    }

    ///得到文件预览url
//    String get preview => "/app/files/preview/${this.id}/${this.name}";
    
    /// 是否有缩略图
    var hasThumb: Bool{
        return !self.dfsModel.thumb.isEmpty
    }
    
    ///得到缩略图URL
    var thumb: String{
        return SettingShared.domainNotNull + self.dfsModel.thumb + "?extra=thumb&_token=" + SettingShared.token
    }
    
    /// 是否文件夹
    var isFolder: Bool{
        return !self.dfsModel.fileFlag
    }
    
    /// 是否文件
    var isFile: Bool{
        return self.dfsModel.fileFlag
    }
}
