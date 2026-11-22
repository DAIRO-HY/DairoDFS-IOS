//
//  ShareUploadStore.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/23.
//

import Foundation

/**
 主App和分享扩展共用的数据,保存在App Group里
 分享扩展把文件复制到共享目录,再写一个上传记录,主App回到前台时把记录交给SDK上传
 这个文件同时编译到主App和分享扩展,不能引用只有主App才有的代码
 */
enum ShareUploadStore {

    /// App Group ID,要和两个target的entitlements一致
    static let GROUP_ID = "group.cn.dairo.dfs"

    /// 上传ID前缀,后面是文件相对共享目录的路径
    static let UPLOAD_ID_PREFIX = "share:"

    /// 分享之后提醒打开App的通知ID
    static let NOTIFICATION_ID = "cn.dairo.dfs.share-upload"

    /// 上传记录的扩展名
    private static let RECORD_EXT = "json"

    private static let KEY_DOMAIN = "SHARE_DOMAIN"
    private static let KEY_TOKEN = "SHARE_TOKEN"
    private static let KEY_ACCOUNT = "SHARE_ACCOUNT"
    private static let KEY_LAST_FOLDER = "SHARE_LAST_FOLDER"

    private static var defaults: UserDefaults? {
        return UserDefaults(suiteName: ShareUploadStore.GROUP_ID)
    }

    /// 共享的上传文件目录,每次分享一个子目录,记录文件和子目录同名
    static var folder: URL? {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: ShareUploadStore.GROUP_ID)?
            .appendingPathComponent("share-upload")
    }

    /*----------------------------------------------------------------------------------*/

    /// 当前登录的账号,分享扩展用它来获取文件夹列表
    static var login: ShareLogin? {
        guard let defaults = ShareUploadStore.defaults,
              let domain = defaults.string(forKey: ShareUploadStore.KEY_DOMAIN),
              let token = defaults.string(forKey: ShareUploadStore.KEY_TOKEN),
              let account = defaults.string(forKey: ShareUploadStore.KEY_ACCOUNT) else{
            return nil
        }
        return ShareLogin(domain: domain, token: token, account: account)
    }

    /// 主App登录状态变化之后保存,nil表示没有登录
    static func saveLogin(_ login: ShareLogin?) {
        guard let defaults = ShareUploadStore.defaults else{
            return
        }
        guard let login else{
            defaults.removeObject(forKey: ShareUploadStore.KEY_DOMAIN)
            defaults.removeObject(forKey: ShareUploadStore.KEY_TOKEN)
            defaults.removeObject(forKey: ShareUploadStore.KEY_ACCOUNT)
            return
        }
        defaults.set(login.domain, forKey: ShareUploadStore.KEY_DOMAIN)
        defaults.set(login.token, forKey: ShareUploadStore.KEY_TOKEN)
        defaults.set(login.account, forKey: ShareUploadStore.KEY_ACCOUNT)
    }

    /// 上次分享时选择的文件夹
    static var lastFolder: String {
        get{
            return ShareUploadStore.defaults?.string(forKey: ShareUploadStore.KEY_LAST_FOLDER) ?? ""
        }
        set{
            ShareUploadStore.defaults?.set(newValue, forKey: ShareUploadStore.KEY_LAST_FOLDER)
        }
    }

    /*----------------------------------------------------------------------------------*/

    /// 创建一次分享的文件目录,返回目录名
    static func createBatch() throws -> String {
        guard let folder = ShareUploadStore.folder else{
            throw ShareUploadError("无法访问共享目录")
        }
        let name = UUID().uuidString
        try FileManager.default.createDirectory(at: folder.appendingPathComponent(name), withIntermediateDirectories: true)
        return name
    }

    /// 文件复制完成之后保存上传记录,主App只处理有记录的目录
    static func saveRecord(_ record: ShareUploadRecord) throws {
        guard let folder = ShareUploadStore.folder else{
            throw ShareUploadError("无法访问共享目录")
        }
        let data = try JSONEncoder().encode(record)
        try data.write(to: folder.appendingPathComponent(record.batch).appendingPathExtension(ShareUploadStore.RECORD_EXT), options: .atomic)
    }

    /// 所有还没交给SDK的上传记录
    static func listRecords() -> [ShareUploadRecord] {
        guard let folder = ShareUploadStore.folder,
              let urls = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) else{
            return []
        }
        return urls.filter{ $0.pathExtension == ShareUploadStore.RECORD_EXT }.compactMap{
            guard let data = try? Data(contentsOf: $0) else{
                return nil
            }
            return try? JSONDecoder().decode(ShareUploadRecord.self, from: data)
        }
    }

    /// 上传记录交给SDK之后删除
    static func deleteRecord(_ record: ShareUploadRecord) {
        guard let folder = ShareUploadStore.folder else{
            return
        }
        try? FileManager.default.removeItem(at: folder.appendingPathComponent(record.batch).appendingPathExtension(ShareUploadStore.RECORD_EXT))
    }
}

/// 分享扩展使用的登录信息
struct ShareLogin {

    /// 服务器地址
    let domain: String

    /// 登录票据
    let token: String

    /// 上传账号,和SDK的上传账号一致
    let account: String
}

/// 一次分享的上传记录
struct ShareUploadRecord: Codable {

    /// 文件所在的目录名
    let batch: String

    /// 上传账号,和主App当前账号一致时才上传
    let account: String

    /// 上传到DFS的文件夹
    let folder: String

    /// 目录里的文件名
    let files: [String]
}

struct ShareUploadError: LocalizedError {
    let msg: String

    init(_ msg: String) {
        self.msg = msg
    }

    var errorDescription: String? {
        return self.msg
    }
}
