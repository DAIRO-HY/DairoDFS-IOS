//
//  FileModel++.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/07/31.
//

extension FileModel{
    
    /// 生成获取附属文件地址
    /// - Parameter ext 要下载的文件后缀
    func makeExtraUrl(_ extra: String, _ ext: String = "") -> String{
        let baseUrl = SettingShared.domainNotNull + "/app/files/extra/\(self.id)/\(self.name)\(ext)?_token=" + SettingShared.token + "&extra=\(extra)"// + "&wait=10"
        return baseUrl
    }

    /// 得到文件缩略图文件下载ID
    var thumbDownloadId: String{
        return "\(self.id)-thumb"
    }

    /// 得到缩略图URL
    var thumbUrl: String{
        return self.makeExtraUrl("thumb", "-thumb.jpg")
    }

    ///得到文件缩略图文件下载ID
    var downloadId: String{
        return "\(self.id)"
    }

    /// 得到下载文件的url
    var download: String{
        return self.makeExtraUrl("")
    }

    ///得到文件预览文件下载ID
    var previewDownloadId: String{
        if self.previewImage == self.download{
            return self.downloadId
        }else{
            return self.downloadId + "-preview"
        }
    }

    ///得到文件预览url
    var previewImage: String{
        let lowerName = self.name.lowercased()
        if lowerName.hasSuffix(".jpg")
            || lowerName.hasSuffix(".jpeg")
            || lowerName.hasSuffix(".png")
            || lowerName.hasSuffix(".heic"){//这些格式的预览图和原图都是一样的
            return self.download
        } else {
            return self.makeExtraUrl("preview", ".jpg")
        }
    }

    /// 在线获取图片缩略图ID
    func onlineThumbId(width: Int, height: Int, maxSize: Int = 0) -> String{
        return "thumb-\(self.id)-\(width)-\(height)-\(maxSize)"
    }

    /// 在线获取图片缩略图
    func onlineThumb(width: Int, height: Int, maxSize: Int = 0) -> String{
        return "\(SettingShared.domainNotNull)/app/files/thumb_online/\(self.id)/\(self.id)-\(width)-\(height)-\(maxSize).jpg?_token=\(SettingShared.token)&width=\(width)&height=\(height)&maxSize=\(maxSize)"
    }
    
    /// 实况照片预览视频
    var dliveVideoPreviewId: String{
        return self.downloadId + "-preview-dlive"
    }
    
    /// 实况照片预览视频
    var dliveVideoPreview: String{
        return self.makeExtraUrl("preview-dlive", ".mp4")
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
        || lowerName.hasSuffix(".cr3")
        || lowerName.hasSuffix(".tiff")
        || lowerName.hasSuffix(".dlive")
    }

    ///这是否是实况照片
    var isDlive: Bool{
        let lowerName = self.name.lowercased()
        return lowerName.hasSuffix(".dlive")
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
