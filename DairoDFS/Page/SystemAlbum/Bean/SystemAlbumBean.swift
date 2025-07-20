//
//  AlbumSyncBean.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/07/10.
//

import Photos

struct SystemAlbumBean{
    
    //相册唯一值
    let identifier: String
    
    //当前对象所在索引
    let index: Int
    
    //相册数据
    let asset: PHAsset
    
    //媒体类型类型
    let mediaType: String
    
    //文件后缀
    let ext: String
    
    //文件名
    let name: String
    
    //视频时长
    let duration: String?
    
    //文件的md5
    var md5: String?
    
    //上传标记  -1:未知  0:未上传  1:已上传
    var existsFlag = -1
    
    //上传消息
    var uploadMsg = ""
    
    //是否选中
    var checked = false
}
