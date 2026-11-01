//
//  FileUploadSource.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/01.
//

import Foundation
import Photos
import CryptoKit
import DairoFileSDK

/// 给SDK提供上传数据,支持系统相册和文件选择器选择的文件
/// SDK保存的是上传数据的ID,App重启之后会通过同一个ID重新读取数据,所以ID必须稳定
/// 所有函数都在SDK的后台线程调用,可以阻塞
final class FileUploadSource: UploadSourceProvider, @unchecked Sendable {
    
    private static let ASSET_PREFIX = "asset:"
    private static let BOOKMARK_PREFIX = "bookmark:"
    
    /// 相册数据导出的临时目录
    private static let tempFolder = FileManager.default.temporaryDirectory.appendingPathComponent("upload-asset")
    
    private let lock = NSLock()
    
    /// 上传数据ID => 正在读取的数据
    private var sessions = [String : FileUploadSession]()
    
    /// 相册文件的上传数据ID
    static func makeId(identifier: String) -> String {
        return FileUploadSource.ASSET_PREFIX + identifier
    }
    
    /// 文件选择器选择的文件的上传数据ID
    static func makeId(bookmark: Data) -> String {
        return FileUploadSource.BOOKMARK_PREFIX + bookmark.base64EncodedString()
    }
    
    /// 从上传数据ID里取出相册文件唯一ID,不是相册文件时返回nil
    static func identifier(id: String) -> String? {
        guard id.hasPrefix(FileUploadSource.ASSET_PREFIX) else{
            return nil
        }
        return String(id.dropFirst(FileUploadSource.ASSET_PREFIX.count))
    }
    
    /// 删除上次运行遗留的临时文件,要在开始上传之前调用
    static func clearTemp() {
        try? FileManager.default.removeItem(at: FileUploadSource.tempFolder)
    }
    
    /// 上传时保存的文件扩展名
    static func uploadExt(_ asset: PHAsset) -> String {
        if asset.mediaSubtypes.contains(.photoLive){
            return "dlive"
        }
        let filename = PHAssetResource.assetResources(for: asset).first?.originalFilename ?? ""
        return (filename as NSString).pathExtension.lowercased()
    }
    
    /// 计算相册文件上传数据的MD5,不要在主线程调用
    static func md5(identifier: String) throws -> String {
        let url = try FileUploadSource.exportAsset(identifier)
        defer{
            try? FileManager.default.removeItem(at: url)
        }
        let handle = try FileHandle(forReadingFrom: url)
        defer{
            try? handle.close()
        }
        var md5 = Insecure.MD5()
        while let data = try handle.read(upToCount: 1024 * 1024), !data.isEmpty{
            md5.update(data: data)
        }
        return md5.finalize().map{ String(format: "%02x", $0) }.joined()
    }
    
    /// 将实况照片的图片和视频合并成一个文件
    /// 文件头部格式:dlive|图片格式|图片大小|视频格式|视频大小-
    static func writeDlive(photo: URL, photoExt: String, video: URL, videoExt: String, to target: URL) throws {
        let photoSize = try FileUploadSource.fileSize(photo)
        let videoSize = try FileUploadSource.fileSize(video)
        let head = "dlive|\(photoExt)|\(photoSize)|\(videoExt)|\(videoSize)-"
        FileManager.default.createFile(atPath: target.path, contents: Data(head.utf8))
        let output = try FileHandle(forWritingTo: target)
        defer{
            try? output.close()
        }
        try output.seekToEnd()
        for url in [photo, video]{
            let input = try FileHandle(forReadingFrom: url)
            defer{
                try? input.close()
            }
            while let data = try input.read(upToCount: 1024 * 1024), !data.isEmpty{
                try output.write(contentsOf: data)
            }
        }
    }
    
    static func fileSize(_ url: URL) throws -> UInt64 {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        return attributes[.size] as? UInt64 ?? 0
    }
    
    /// 将相册文件的上传数据导出到临时文件,需要时会从iCloud下载
    fileprivate static func exportAsset(_ identifier: String) throws -> URL {
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject else{
            throw CallbackError.Failed(msg: "相册文件不存在")
        }
        let resources = PHAssetResource.assetResources(for: asset)
        try FileManager.default.createDirectory(at: FileUploadSource.tempFolder, withIntermediateDirectories: true)
        let target = FileUploadSource.tempFolder.appendingPathComponent(UUID().uuidString)
        if !asset.mediaSubtypes.contains(.photoLive){
            guard let resource = (resources.first{ $0.type == .photo || $0.type == .video }) else{
                throw CallbackError.Failed(msg: "没有找到相册文件的数据")
            }
            try FileUploadSource.export(resource, to: target)
            return target
        }
        guard let photo = (resources.first{ $0.type == .photo }), let video = (resources.first{ $0.type == .pairedVideo }) else{
            throw CallbackError.Failed(msg: "没有找到实况照片的数据")
        }
        let photoUrl = target.appendingPathExtension("photo")
        let videoUrl = target.appendingPathExtension("video")
        defer{
            try? FileManager.default.removeItem(at: photoUrl)
            try? FileManager.default.removeItem(at: videoUrl)
        }
        try FileUploadSource.export(photo, to: photoUrl)
        try FileUploadSource.export(video, to: videoUrl)
        try FileUploadSource.writeDlive(
            photo: photoUrl,
            photoExt: (photo.originalFilename as NSString).pathExtension.lowercased(),
            video: videoUrl,
            videoExt: (video.originalFilename as NSString).pathExtension.lowercased(),
            to: target
        )
        return target
    }
    
    /// 将相册资源写入文件,写入完成之后才返回
    private static func export(_ resource: PHAssetResource, to url: URL) throws {
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true// 允许从iCloud下载
        let semaphore = DispatchSemaphore(value: 0)
        var exportError: Error?
        PHAssetResourceManager.default().writeData(for: resource, toFile: url, options: options){
            exportError = $0
            semaphore.signal()
        }
        semaphore.wait()
        if let exportError{
            throw CallbackError.Failed(msg: "读取相册文件失败:\(exportError.localizedDescription)")
        }
    }
    
    /// 获取正在读取的数据
    private func session(_ id: String) -> FileUploadSession {
        self.lock.lock()
        defer{
            self.lock.unlock()
        }
        if let session = self.sessions[id]{
            return session
        }
        let session = FileUploadSession(id)
        self.sessions[id] = session
        return session
    }
    
    func size(id: String) throws -> UInt64 {
        return try self.session(id).size()
    }
    
    func read(id: String, offset: UInt64, len: UInt64) throws -> Data {
        return try self.session(id).read(offset: offset, len: len)
    }
    
    func close(id: String) {
        self.lock.lock()
        self.sessions.removeValue(forKey: id)
        self.lock.unlock()
    }
    
    /// 打开上传数据,返回文件路径和结束读取时要执行的操作
    fileprivate static func open(_ id: String) throws -> (url: URL, close: () -> Void) {
        if let identifier = FileUploadSource.identifier(id: id){
            let url = try FileUploadSource.exportAsset(identifier)
            return (url, { try? FileManager.default.removeItem(at: url) })
        }
        guard id.hasPrefix(FileUploadSource.BOOKMARK_PREFIX),
              let bookmark = Data(base64Encoded: String(id.dropFirst(FileUploadSource.BOOKMARK_PREFIX.count))) else{
            throw CallbackError.Failed(msg: "上传数据不正确")
        }
        do {
            var isStale = false
            
            //通过data恢复URL,确保app退出后该文件依然能够访问
            let url = try URL(resolvingBookmarkData: bookmark, options: [.withoutImplicitStartAccessing], relativeTo: nil, bookmarkDataIsStale: &isStale)
            let isAccessing = url.startAccessingSecurityScopedResource()
            return (url, {
                if isAccessing{
                    url.stopAccessingSecurityScopedResource()
                }
            })
        } catch {
            throw CallbackError.Failed(msg: "无法访问文件:\(error.localizedDescription)")
        }
    }
}

/// 一个正在读取的上传数据,第一次读取时才打开,对象销毁时释放
private final class FileUploadSession {
    
    private let id: String
    
    private let lock = NSLock()
    
    private var handle: FileHandle?
    
    private var fileSize: UInt64 = 0
    
    private var onClose: (() -> Void)?
    
    init(_ id: String) {
        self.id = id
    }
    
    private func openIfNeed() throws -> FileHandle {
        if let handle = self.handle{
            return handle
        }
        let (url, close) = try FileUploadSource.open(self.id)
        do {
            self.fileSize = try FileUploadSource.fileSize(url)
            let handle = try FileHandle(forReadingFrom: url)
            self.handle = handle
            self.onClose = close
            return handle
        } catch {
            close()
            throw CallbackError.Failed(msg: "读取文件失败:\(error.localizedDescription)")
        }
    }
    
    func size() throws -> UInt64 {
        self.lock.lock()
        defer{
            self.lock.unlock()
        }
        _ = try self.openIfNeed()
        return self.fileSize
    }
    
    /// 读取数据,除了文件末尾,返回的长度必须等于len
    func read(offset: UInt64, len: UInt64) throws -> Data {
        self.lock.lock()
        defer{
            self.lock.unlock()
        }
        let handle = try self.openIfNeed()
        do {
            try handle.seek(toOffset: offset)
            var result = Data()
            while result.count < Int(len){
                guard let data = try handle.read(upToCount: Int(len) - result.count), !data.isEmpty else{
                    break
                }
                result.append(data)
            }
            return result
        } catch {
            throw CallbackError.Failed(msg: "读取文件失败:\(error.localizedDescription)")
        }
    }
    
    deinit{
        try? self.handle?.close()
        self.onClose?()
    }
}
