//
//  FileModel++.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/07/31.
//

import UIKit

extension FileModel{
    
    /// 附属文件
    /// - Parameter extra 附属文件名,例如:thumb、preview、preview-dlive
    /// - Parameter ext 附属文件的扩展名
    private func extraSource(_ extra: String, _ ext: String) -> FileSource{
        return FileSource(
            url: SettingShared.domainNotNull + "/api/files/extra/\(self.id)/\(extra)",
            cacheKey: "/api/files/extra/\(self.id)/\(extra)",
            group: extra,
            name: "\(self.id)-\(extra).\(ext)"
        )
    }

    /// 原文件
    var downloadSource: FileSource{
        let name = self.name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? self.name
        return FileSource(
            url: SettingShared.domainNotNull + "/api/files/download/\(self.id)/\(name)",
            cacheKey: "/api/files/download/\(self.id)",
            group: "file",
            name: self.name
        )
    }

    /// 缩略图
    var thumbSource: FileSource{
        return FileSource.thumb(id: self.id)
    }

    /// 在线生成的图片,从中间裁剪成指定的大小
    /// - Parameter width 宽度,单位是像素
    /// - Parameter height 高度,单位是像素
    func thumbOnlineSource(width: CGFloat, height: CGFloat) -> FileSource{

        //布局计算出来的大小有浮点误差,同一个格子有时是389.0000001,有时是388.9999999,四舍五入才能保证每次都一样,否则缓存对不上会重新加载
        let width = Int(width.rounded())
        let height = Int(height.rounded())
        return self.thumbOnlineSource(query: "width=\(width)&height=\(height)", name: "\(width)x\(height)")
    }

    /// 在线生成的图片,按比例缩放
    /// - Parameter maxSize 最大边,单位是像素
    func thumbOnlineSource(maxSize: CGFloat) -> FileSource{
        let maxSize = Int(maxSize.rounded())
        return self.thumbOnlineSource(query: "max_size=\(maxSize)", name: "max\(maxSize)")
    }

    /// 在线生成的图片,不同大小要分开缓存
    private func thumbOnlineSource(query: String, name: String) -> FileSource{
        let path = "/api/files/thumb_online/\(self.id)?\(query)"
        return FileSource(
            url: SettingShared.domainNotNull + path,
            cacheKey: path,
            group: "thumb-online",
            name: "\(self.id)-\(name).jpg"
        )
    }

    /// 文件属性
    var propertySource: FileSource{
        return FileSource(
            url: SettingShared.domainNotNull + ApiConst.FILES_PROPERTY + "?ids=\(self.id)",
            cacheKey: ApiConst.FILES_PROPERTY + "/\(self.id)",
            group: "property",
            name: "\(self.id)-property.json"
        )
    }

    /// 图片预览
    var previewImageSource: FileSource{
        let lowerName = self.name.lowercased()
        if lowerName.hasSuffix(".psd")
            || lowerName.hasSuffix(".psb")
            || lowerName.hasSuffix(".ai")
            || lowerName.hasSuffix(".cr3")
            || lowerName.hasSuffix(".cr2")
            || lowerName.hasSuffix(".dlive"){//这些格式不能直接显示,要使用服务器生成的预览图
            return self.extraSource("preview", "jpg")
        } else {
            return self.downloadSource
        }
    }

    /// 适合当前屏幕的图片,用于快速浏览
    var screenImageSource: FileSource{
        let screenSize = UIScreen.main.nativeBounds.size
        return self.thumbOnlineSource(maxSize: max(screenSize.width, screenSize.height))
    }

    /// 流畅画质的预览视频
    var previewVideoSource: FileSource{
        return self.extraSource("preview", "mp4")
    }

    /// 实况照片预览视频
    var dliveVideoPreviewSource: FileSource{
        return self.extraSource("preview-dlive", "mp4")
    }
    
    /// 从已下载的实况照片里拆出来的视频,只存在于本地缓存
    /// - Parameter ext 视频扩展名,只在存入缓存时起作用
    func dliveVideoSource(ext: String = "mov") -> FileSource{
        return FileSource(
            url: SettingShared.domainNotNull + "/api/files/download/\(self.id)/dlive-video.\(ext)",
            cacheKey: "/dlive-video/\(self.id)",
            group: "dlive",
            name: "\(self.id)-dlive.\(ext)"
        )
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
        || lowerName.hasSuffix(".hif")
        || lowerName.hasSuffix(".gif")
        || lowerName.hasSuffix(".psd")
        || lowerName.hasSuffix(".cr3")
        || lowerName.hasSuffix(".tiff")
        || lowerName.hasSuffix(".dlive")
    }

    ///这是否是一个音频文件
    var isAudio: Bool{
        let lowerName = self.name.lowercased()
        return lowerName.hasSuffix(".mp3")
        || lowerName.hasSuffix(".m4a")
        || lowerName.hasSuffix(".aac")
        || lowerName.hasSuffix(".wav")
        || lowerName.hasSuffix(".flac")
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
