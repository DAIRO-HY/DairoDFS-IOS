//
//  ShareFileSaver.swift
//  DairoDFSShare
//
//  Created by zhoulq on 2026/11/23.
//

import Foundation
import UniformTypeIdentifiers

/// 把分享的内容复制到共享目录
enum ShareFileSaver {

    /// 复制所有分享的文件,并保存上传记录
    static func save(_ providers: [NSItemProvider], account: String, folder: String) async throws -> ShareUploadRecord {
        let batch = try ShareUploadStore.createBatch()
        guard let batchUrl = ShareUploadStore.folder?.appendingPathComponent(batch) else{
            throw ShareUploadError("无法访问共享目录")
        }
        do {
            var files = [String]()
            for provider in providers{
                guard let type = ShareFileSaver.fileType(provider) else{
                    continue
                }
                let name = try await ShareFileSaver.copy(provider, type: type, to: batchUrl, exists: Set(files))
                files.append(name)
            }
            if files.isEmpty{
                throw ShareUploadError("没有可以上传的文件")
            }
            let record = ShareUploadRecord(batch: batch, account: account, folder: folder, files: files)
            try ShareUploadStore.saveRecord(record)
            return record
        } catch {
            try? FileManager.default.removeItem(at: batchUrl)
            throw error
        }
    }

    /// 选择要读取的数据类型,优先使用排在前面的,链接和文字不上传
    private static func fileType(_ provider: NSItemProvider) -> UTType? {
        for identifier in provider.registeredTypeIdentifiers{
            guard let type = UTType(identifier) else{
                continue
            }
            if type.conforms(to: .data) && !type.conforms(to: .url) && !type.conforms(to: .text){
                return type
            }
        }
        return nil
    }

    /// 复制一个文件,返回保存的文件名
    private static func copy(_ provider: NSItemProvider, type: UTType, to folder: URL, exists: Set<String>) async throws -> String {
        return try await withCheckedThrowingContinuation{ continuation in
            _ = provider.loadFileRepresentation(forTypeIdentifier: type.identifier){ url, error in

                //系统给的临时文件在回调结束后就会被删除,必须在这里复制
                guard let url else{
                    continuation.resume(throwing: ShareUploadError("读取分享的文件失败:\(error?.localizedDescription ?? "")"))
                    return
                }
                let name = ShareFileSaver.uniqueName(ShareFileSaver.fileName(provider, type: type, url: url), exists: exists)
                do {
                    try FileManager.default.copyItem(at: url, to: folder.appendingPathComponent(name))
                    continuation.resume(returning: name)
                } catch {
                    continuation.resume(throwing: ShareUploadError("保存分享的文件失败:\(error.localizedDescription)"))
                }
            }
        }
    }

    /// 文件名,优先使用分享来源给的名字,没有扩展名时补上
    private static func fileName(_ provider: NSItemProvider, type: UTType, url: URL) -> String {
        var name = provider.suggestedName ?? ""
        if name.isEmpty{
            name = url.lastPathComponent
        }
        name = name.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: ":", with: "_")
        if (name as NSString).pathExtension.isEmpty{
            let ext = url.pathExtension.isEmpty ? (type.preferredFilenameExtension ?? "") : url.pathExtension
            if !ext.isEmpty{
                name += "." + ext
            }
        }
        return name
    }

    /// 同一次分享里文件名重复时,在扩展名前面加序号
    private static func uniqueName(_ name: String, exists: Set<String>) -> String {
        if !exists.contains(name){
            return name
        }
        let base = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension
        var index = 1
        while true{
            let newName = ext.isEmpty ? "\(base)(\(index))" : "\(base)(\(index)).\(ext)"
            if !exists.contains(newName){
                return newName
            }
            index += 1
        }
    }
}
