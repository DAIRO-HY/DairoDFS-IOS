//
//  FileSdkUtil.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/01.
//

import Foundation
import AVFoundation
import DairoFileSDK

/// <summary>
/// 文件下载缓存上传SDK,整个App共用一个实例
/// </summary>
enum FileSdkUtil {
    
    ///SDK事件通知名,通知的object是Event,在主线程发送
    static let EVENT = Notification.Name("FileSdkEvent")
    
    ///SDK数据目录名
    private static let ROOT_FOLDER = "dairo-file-sdk"
    
    ///SDK实例的创建结果,创建失败时,在使用的地方抛出错误
    private static let result = Result { try FileSdkUtil.create() }
    
    ///事件监听,SDK不会持有它之外的引用
    private static let eventListener = FileSdkEventListener()
    
    /**
     获取SDK实例
     */
    static func get() throws -> FileSdk {
        return try FileSdkUtil.result.get()
    }
    
    /**
     App回到前台时调用,本机HTTP服务失效时会重启,之前拿到的本机地址依然有效
     */
    static func checkServer() {
        do {
            _ = try FileSdkUtil.get().checkServer()
        } catch {
            print("检查SDK本机HTTP服务失败:\(error)")
        }
    }
    
    /**
     App进入后台时调用
     */
    static func flush() {
        do {
            try FileSdkUtil.get().flush()
        } catch {
            print("SDK保存数据失败:\(error)")
        }
    }
    
    /**
     当前上传账号,上传任务按账号区分
     */
    static var dfsAccount: String? {
        guard SettingStore.isLogin, let user = SettingStore.user else{
            return nil
        }
        return "\(SettingStore.clusterId):\(user.id)"
    }
    
    /**
     登录状态变化之后调用,只有当前账号的任务会上传
     */
    static func syncDfsAccount() {
        guard let sdk = try? FileSdkUtil.get() else{
            return
        }
        FileSdkUtil.applyDfsAccount(sdk)
    }
    
    /**
     重新登录之后继续上传失败的任务,这些任务可能是因为票据失效而失败的
     */
    static func resumeFailedUploads() {
        guard let account = FileSdkUtil.dfsAccount, let sdk = try? FileSdkUtil.get() else{
            return
        }
        let query = UploadQuery(account: account, state: .error, offset: 0, limit: UInt64(Int32.max))
        if let list = try? sdk.listUploads(query: query){
            try? sdk.resumeUploads(ids: list.map{ $0.id })
        }
    }
    
    private static func applyDfsAccount(_ sdk: FileSdk) {
        if let account = FileSdkUtil.dfsAccount{
            sdk.setDfsAccount(account: account, server: SettingStore.domainNotNull, token: SettingStore.token)
        } else {
            sdk.clearDfsAccount()
        }
    }
    
    /**
     获取已经缓存的文件路径,没有缓存时返回nil
     */
    static func cachedPath(_ source: FileSource) -> String? {
        return try? FileSdkUtil.get().cachedPath(url: source.url, options: source.options())
    }
    
    /**
     获取缓存ID,用来和事件、列表里的记录对应
     */
    static func cacheId(_ source: FileSource) -> String? {
        return try? FileSdkUtil.get().cacheId(url: source.url, options: source.options())
    }
    
    /**
     获取图片的访问方式,适合列表里大量的图片
     已经下载完成的返回文件路径,否则返回无状态的本机地址,连接断开时SDK会自动取消下载
     */
    static func localSource(_ source: FileSource) -> LocalSource? {
        return try? FileSdkUtil.get().localSource(url: source.url, options: source.options())
    }
    
    /**
     获取给播放器使用的本机地址,支持边下边播
     */
    static func open(_ source: FileSource) -> URL? {
        guard let url = try? FileSdkUtil.get().open(url: source.url, options: source.options()) else{
            return nil
        }
        return URL(string: url)
    }
    
    /**
     添加永久下载,进度通过事件通知,App重启后自动继续
     */
    static func download(_ source: FileSource) throws {
        _ = try FileSdkUtil.get().download(url: source.url, options: source.options(.save))
    }
    
    /**
     把数据存入缓存
     */
    @discardableResult
    static func putData(_ source: FileSource, _ data: Data) -> String? {
        return try? FileSdkUtil.get().putData(url: source.url, options: source.options(), data: data)
    }
    
    /**
     下载并缓存文件,回调都在主线程,取消之后不会再回调
     - Parameter progress: 下载进度(0到100)
     - Parameter finish: 下载结束,成功时返回文件路径,失败时返回错误
     */
    static func fetch(_ source: FileSource,
                      progress: @escaping (_ percent: Int) -> Void,
                      finish: @escaping (_ path: String?, _ error: Error?) -> Void) -> FetchTask? {
        do {
            let listener = FileSdkFetchListener(progress: progress, finish: finish)
            return try FileSdkUtil.get().fetch(url: source.url, options: source.options(), listener: listener)
        } catch {
            finish(nil, error)
            return nil
        }
    }
    
    /**
     将SDK的错误信息转换成给用户看的提示,没有权限时SDK返回的是地址过期或文件不存在
     */
    static func friendlyError(_ msg: String) -> String {
        if msg.hasPrefix("地址已过期或者没有权限"){
            return "没有访问权限或登录已失效"
        }
        if msg == "文件不存在"{
            return "文件不存在或没有访问权限"
        }
        return msg
    }
    
    /**
     创建SDK实例,数据目录不能用Caches,否则会被系统清理
     */
    private static func create() throws -> FileSdk {
        var root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(FileSdkUtil.ROOT_FOLDER)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try root.setResourceValues(values)
        let sdk = try FileSdk(config: SdkConfig(rootDir: root.path))
        sdk.setListener(listener: FileSdkUtil.eventListener)
        
        //SDK不负责保存设置,启动时再设置一次
        if SettingStore.fileSdkMaxSavingCount > 0{
            sdk.setMaxSavingCount(count: UInt32(SettingStore.fileSdkMaxSavingCount))
        }
        if SettingStore.fileSdkMaxCachingCount > 0{
            sdk.setMaxCachingCount(count: UInt32(SettingStore.fileSdkMaxCachingCount))
        }
        if let days = SettingStore.fileSdkCacheExpireDays{
            sdk.setCacheExpireDays(days: UInt32(days))
        }
        if SettingStore.fileSdkMaxUploadingCount > 0{
            sdk.setMaxUploadingCount(count: UInt32(SettingStore.fileSdkMaxUploadingCount))
        }
        
        //设置上传账号之后,未完成的上传任务会继续,所以要先准备好上传数据
        FileUploadSource.clearTemp()
        sdk.setUploadSourceProvider(provider: FileUploadSource())
        FileSdkUtil.applyDfsAccount(sdk)
        return sdk
    }
}

/// 要通过SDK访问的DFS文件
struct FileSource {
    
    /// 下载地址
    let url: String
    
    /// 缓存key,不包含文件名和域名,改名和切换服务器地址之后缓存依然有效
    let cacheKey: String
    
    /// 缓存分组,用于统计和清理
    let group: String
    
    /// 文件名,用来决定缓存文件的扩展名和下载列表显示的名字
    let name: String
    
    /// 下载优先级,数值越大越先下载
    var priority: Int32 = 0
    
    /// SDK访问参数
    func options(_ cache: CacheMode = .cache) -> Options {
        return Options(
            cache: cache,
            group: self.group,
            namespace: SettingStore.clusterId,
            cacheKey: self.cacheKey,
            headers: ["Authorization": "Bearer " + SettingStore.token],
            priority: self.priority,
            name: self.name
        )
    }
    
    /// 让播放器直接播放服务器上的文件,不经过SDK,所以不会产生缓存
    /// AVPlayer没有设置请求头的公开API,这里通过Cookie传登录票据
    var directAsset: AVURLAsset? {
        guard let url = URL(string: self.url), let host = url.host else{
            return nil
        }
        let cookie = HTTPCookie(properties: [
            .name: "token",
            .value: SettingStore.token,
            .domain: host,
            .path: "/"
        ])
        return AVURLAsset(url: url, options: [AVURLAssetHTTPCookiesKey: cookie.map{ [$0] } ?? []])
    }
    
    /// 缩略图
    static func thumb(id: Int64) -> FileSource {
        return FileSource(
            url: SettingStore.domainNotNull + "/api/files/thumb/\(id)",
            cacheKey: "/api/files/extra/\(id)/thumb",
            group: "thumb",
            name: "\(id)-thumb.jpg",
            
            //SDK同时下载的文件数有限,缩略图很小,不能排在在线生成的图片后面,否则在线生成很慢时,列表里一张图片也看不到
            priority: 1
        )
    }
    
    /// 用户头像,没有头像时返回nil,头像的MD5放在缓存key里,换头像之后会重新下载
    static func avatar(_ user: MineModel) -> FileSource? {
        guard let avatar = user.avatar, !avatar.isEmpty else{
            return nil
        }
        return FileSource(
            url: SettingStore.domainNotNull + ApiConst.AVATAR + "/\(user.id)?v=\(avatar)",
            cacheKey: ApiConst.AVATAR + "/\(user.id)/\(avatar)",
            group: "avatar",
            name: "\(user.id)-avatar.jpg"
        )
    }
}

/// SDK事件监听,转发到主线程的通知
private final class FileSdkEventListener: EventListener, @unchecked Sendable {
    func onEvent(event: Event) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: FileSdkUtil.EVENT, object: event)
        }
    }
}

/// 下载回调,转发到主线程
private final class FileSdkFetchListener: FetchListener, @unchecked Sendable {
    private let progress: (_ percent: Int) -> Void
    private let finish: (_ path: String?, _ error: Error?) -> Void
    
    init(progress: @escaping (_ percent: Int) -> Void, finish: @escaping (_ path: String?, _ error: Error?) -> Void) {
        self.progress = progress
        self.finish = finish
    }
    
    func onProgress(size: UInt64?, downloaded: UInt64) {
        guard let size, size > 0 else{
            return
        }
        let percent = Int(Double(downloaded) / Double(size) * 100)
        DispatchQueue.main.async {
            self.progress(percent)
        }
    }
    
    func onSuccess(path: String) {
        DispatchQueue.main.async {
            self.finish(path, nil)
        }
    }
    
    func onError(error: SdkError) {
        if case .Cancelled = error{
            return
        }
        DispatchQueue.main.async {
            self.finish(nil, error)
        }
    }
}

extension Error {
    
    /// SDK的错误信息
    var fileSdkMessage: String {
        guard let error = self as? SdkError else{
            return self.localizedDescription
        }
        switch error {
        case let .UrlExpired(_, msg), let .Http(_, msg):
            return FileSdkUtil.friendlyError(msg)
        case let .NotFound(msg), let .Server(msg), let .Source(msg), let .Network(msg), let .Io(msg),
            let .Md5Mismatch(msg), let .InvalidUrl(msg), let .Db(msg), let .NoAccount(msg), let .Cancelled(msg):
            return FileSdkUtil.friendlyError(msg)
        }
    }
}
