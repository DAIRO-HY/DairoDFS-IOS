//
//  ShareUploadReceiver.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/23.
//

import Foundation
import DairoFileSDK
import DairoUI_IOS
import UserNotifications

/**
 把分享扩展保存的文件交给SDK上传,所有方法都在主线程调用
 上传完成或者跳过之后删除共享目录里的文件,上传记录被删除的文件在下次接收时清理
 */
enum ShareUploadReceiver {

    /// 是否已经开始监听上传事件
    private static var isStarted = false

    /// 开始监听上传事件,在SDK创建之后调用
    static func start() {
        guard !ShareUploadReceiver.isStarted else{
            return
        }
        ShareUploadReceiver.isStarted = true
        NotificationCenter.default.addObserver(forName: FileSdkUtil.EVENT, object: nil, queue: .main){
            guard case let .uploadStateChanged(id, state, _) = $0.object as? Event, state == .finish || state == .skipped else{
                return
            }
            ShareUploadReceiver.deleteUploadedFile(id)
        }
    }

    /// 接收当前账号的分享文件,App回到前台和切换账号之后调用
    static func receive() {
        print("TMPLOG receive account=\(FileSdkUtil.dfsAccount ?? "nil") records=\(ShareUploadStore.listRecords().map{ $0.account + "|" + $0.batch }) folder=\(ShareUploadStore.folder?.path ?? "nil") files=\((try? FileManager.default.contentsOfDirectory(atPath: ShareUploadStore.folder?.path ?? "")) ?? [])")
        guard let account = FileSdkUtil.dfsAccount, let sdk = try? FileSdkUtil.get() else{
            return
        }
        var count = 0
        for record in ShareUploadStore.listRecords() where record.account == account{
            let items = record.files.map{
                UploadItem(source: .custom(id: ShareUploadStore.UPLOAD_ID_PREFIX + record.batch + "/" + $0), dfsPath: record.folder + "/" + $0)
            }
            do {
                _ = try sdk.addUploads(items: items)
                ShareUploadStore.deleteRecord(record)
                count += items.count
            } catch {
                Toast.show(error.fileSdkMessage)
            }
        }
        if count > 0{
            Toast.show("已添加\(count)个分享的文件到上传列表")
        }
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [ShareUploadStore.NOTIFICATION_ID])
        ShareUploadReceiver.clean(sdk)
    }

    /// 共享目录里的文件路径,不是分享的文件时返回nil
    static func fileUrl(id: String) -> URL? {
        guard id.hasPrefix(ShareUploadStore.UPLOAD_ID_PREFIX), let folder = ShareUploadStore.folder else{
            return nil
        }
        return folder.appendingPathComponent(String(id.dropFirst(ShareUploadStore.UPLOAD_ID_PREFIX.count)))
    }

    /// 上传完成之后删除分享的文件,目录空了之后一起删除
    private static func deleteUploadedFile(_ id: Int64) {
        guard let upload = try? FileSdkUtil.get().getUpload(id: id),
              case let .custom(sourceId) = upload.source,
              let url = ShareUploadReceiver.fileUrl(id: sourceId) else{
            return
        }
        try? FileManager.default.removeItem(at: url)
        let batch = url.deletingLastPathComponent()
        if (try? FileManager.default.contentsOfDirectory(atPath: batch.path))?.isEmpty == true{
            try? FileManager.default.removeItem(at: batch)
        }
    }

    /// 删除已经没有上传任务的文件,比如上传记录被用户删除了
    private static func clean(_ sdk: FileSdk) {
        guard let folder = ShareUploadStore.folder,
              let batches = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: [.isDirectoryKey]),
              batches.contains(where: { $0.hasDirectoryPath }) else{
            return
        }

        //还没交给SDK的目录不能删除,可能是其他账号的,也可能分享扩展正在复制
        let waitingBatches = Set(ShareUploadStore.listRecords().map{ $0.batch })
        DispatchQueue.global().async {
            var usingIds = Set<String>()
            let limit: UInt64 = 1000
            var offset: UInt64 = 0
            while true{
                guard let list = try? sdk.listUploads(query: UploadQuery(account: nil, state: nil, offset: offset, limit: limit)) else{
                    return
                }
                for upload in list where upload.state != .finish && upload.state != .skipped{
                    if case let .custom(id) = upload.source, id.hasPrefix(ShareUploadStore.UPLOAD_ID_PREFIX){
                        usingIds.insert(String(id.dropFirst(ShareUploadStore.UPLOAD_ID_PREFIX.count)))
                    }
                }
                if UInt64(list.count) < limit{
                    break
                }
                offset += limit
            }
            let fileManager = FileManager.default
            for batch in batches where batch.hasDirectoryPath && !waitingBatches.contains(batch.lastPathComponent){

                //分享扩展复制文件时还没有上传记录,刚创建的目录先不删除
                let created = (try? batch.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date()
                if Date().timeIntervalSince(created) < 24 * 60 * 60{
                    continue
                }
                let files = (try? fileManager.contentsOfDirectory(atPath: batch.path)) ?? []
                for file in files where !usingIds.contains(batch.lastPathComponent + "/" + file){
                    try? fileManager.removeItem(at: batch.appendingPathComponent(file))
                }
                if (try? fileManager.contentsOfDirectory(atPath: batch.path))?.isEmpty == true{
                    try? fileManager.removeItem(at: batch)
                }
            }
        }
    }
}
