//
//  FileModel++.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/07/31.
//

extension FileModel{
    
    /// 是否有缩略图
    var hasThumb: Bool{
        return !self.thumb.isEmpty
    }
    
    ///得到缩略图URL
    var thumbUrl: String{
        return SettingShared.domainNotNull + self.thumb + "?extra=thumb&_token=" + SettingShared.token
    }
    
    ///得到下载文件的url
    var download: String{
        let baseUrl = SettingShared.domainNotNull + "/app/files/preview/\(self.id)/\(self.name)?_token=" + SettingShared.token //+ "&wait=10"
        return baseUrl
    }
    
    ///得到文件预览url
    var preview: String{
        let lowerName = self.name.lowercased()
        if lowerName.hasSuffix(".jpg")
            || lowerName.hasSuffix(".jpeg")
            || lowerName.hasSuffix(".png")
            || lowerName.hasSuffix(".heic") {//这些格式的预览图和原图都是一样的
            return self.download
        } else if lowerName.hasSuffix(".mov")
                    || lowerName.hasSuffix(".mp4") {//视频文件时
            return self.download
        } else{
            return self.download + "&extra=preview"
        }
    }
    
    ///得到文件缩略图文件下载ID
    var downloadId: String{
        return "\(self.id)"
    }
    
    ///得到文件预览文件下载ID
    var previewDownloadId: String{
        if self.preview == self.download{
            return self.downloadId
        }else{
            return self.downloadId + "-preview"
        }
    }
    
    /// 文件预览的文件名
    var previewDownloadFileName: String{
        let lowerName = self.name.lowercased()
        if lowerName.hasSuffix(".cr3"){
            return self.name + ".jpg"
        }
        return self.name
    }
    
    ///得到文件缩略图文件下载ID
    var thumbDownloadId: String{
        return "\(self.id)-thumb"
    }
    
    ///这是否是一个视频文件
    var isVideo: Bool{
        let lowerName = self.name.lowercased()
        return lowerName.hasSuffix(".mov")
            || lowerName.hasSuffix(".mp4")
    }
    
    ///这是否是一个图片文件
    var isImage: Bool{
        let lowerName = self.name.lowercased()
        return lowerName.hasSuffix(".jpg")
        || lowerName.hasSuffix(".jpeg")
        || lowerName.hasSuffix(".png")
        || lowerName.hasSuffix(".heic")
        || lowerName.hasSuffix(".gif")
        || lowerName.hasSuffix(".psd")
    }
    
    /// 是否文件夹
    var isFolder: Bool{
        return !self.fileFlag
    }
    
    /// 是否文件
    var isFile: Bool{
        return self.fileFlag
    }
}
