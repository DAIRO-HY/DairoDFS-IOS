//
//  SystemAlbumViewModel.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//
import Foundation
import SwiftUI
import Photos
import DairoUI_IOS
import DairoFileSDK

/// 上传模式
enum UploadMode{
    
    /// 文件的方式上传
    case file
    
    /// 相册的方式上传
    case album
}

class SystemAlbumViewModel : ObservableObject{
    
    //通知:单个相册文件的上传进度
    static let NOTIFY_UPLOAD_PROGRESS = "NOTIFY_UPLOAD_PROGRESS"
    
    //相册文件MD5的本地缓存key
    private static let KEY_MD5 = "album_md5"
    
    //已上传的提示文字,“删除已上传”只会删除这个状态的文件
    private static let MSG_UPLOADED = "上传完成"
    
    //当前相册信息列表
    var albumList = [SystemAlbumItem]()
    
    //文件唯一ID对应所在序号
    var identifier2index = [String:Int]()
    
    ///记录当前选中的文件数
    @Published var checkedCount = 0
    
    ///  剪切板模式
    @Published var clipboardType = 0
    
    /// 标记是否正在上传中
    @Published var isUploading = false
    
    ///上传数量通知消息
    @Published var uploadCountMsg: String?
    
    /// 页面刷新标记
    @Published var freashFlag = 0
    
    /// 上传模式
    let uploadMode: UploadMode
    
    /// 上传ID => 相册文件唯一ID
    private var uploadId2identifier = [Int64 : String]()
    
    /// 还没有结束的上传ID
    private var uploadingIds = Set<Int64>()
    
    /// 正在进行的同步检查
    private var checkTask: Task<Void, Never>?
    
    /// 相册文件唯一ID对应的MD5
    private var md5Map = [String : String]()
    
    init(_ mode: UploadMode){
        self.uploadMode = mode
        self.md5Map = LocalObjectUtil.read([String:String].self, SystemAlbumViewModel.KEY_MD5) ?? [:]
    }
    
    func fetchPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
                var albumAsset = [SystemAlbumItem]()
                
                let now = Date().timeIntervalSince1970
                fetchResult.enumerateObjects { asset, _, _ in
                    let index = albumAsset.count
                    self.identifier2index[asset.localIdentifier] = index
                    albumAsset.append(
                        SystemAlbumItem(
                            identifier: asset.localIdentifier,
                            index: index,
                            asset: asset
                        )
                    )
                }
//                print("-->\(Date().timeIntervalSince1970 - now)")
                Task{@MainActor in
                    self.albumList = albumAsset
                    self.checkedCount = 0
                    self.freashFlag += 1
                    
                    //重新加载之后,已经结束的上传不再显示
                    self.uploadId2identifier = self.uploadId2identifier.filter{ self.uploadingIds.contains($0.key) }
                    self.loadUploading()
                }
            } else {
                Toast.show("未授权访问相册")
            }
        }
    }
    
    /// 加载相册信息
    /// - Parameter index 序号
    func loadAlbumInfo(_ index: Int){
        if !self.albumList.indices.contains(index) || !self.albumList[index].mediaType.isEmpty{
            return
        }
        let asset = self.albumList[index].asset
        let resources = PHAssetResource.assetResources(for: asset)
        let resource = resources.first!
        let locallyAvailable = resource.value(forKey: "locallyAvailable")! as! Bool
        
        var mediaType = ""
        if asset.mediaSubtypes.contains(.photoLive) {
            // 实况照片
            mediaType = "Live Photo"
        } else if asset.mediaType == .image {
            // 普通图片
            mediaType = "Image"
        } else if asset.mediaType == .video {
            // 视频
            mediaType = "Video"
        }
        
        //视频时长
        var duration: String? = nil
        if asset.mediaType == .video{
            duration = (asset.duration * 1000).timeFormat
        }
        self.albumList[index].mediaType = mediaType
        //            self.albumList[index].ext: "",
        //            self.albumList[index].name: "",
        self.albumList[index].duration = duration
        self.albumList[index].locallyAvailable = locallyAvailable
    }
    
    //图片点击事件
    func onItemClick(_ item: SystemAlbumItem){
        self.checkedCount += (item.checked ? -1 : 1)
        self.albumList[item.index].checked = !item.checked
        print(PHAssetResource.assetResources(for: item.asset))
    }
    
    /// 恢复页面关闭之前还没有结束的上传,已经结束的不恢复,“删除已上传”只认这次打开页面之后确认过的结果
    private func loadUploading(){
        guard let account = FileSdkUtil.dfsAccount, let sdk = try? FileSdkUtil.get() else{
            return
        }
        let query = UploadQuery(account: account, state: nil, offset: 0, limit: UInt64(Int32.max))
        for item in (try? sdk.listUploads(query: query)) ?? []{
            guard case let .custom(id) = item.source, let identifier = FileUploadSource.identifier(id: id) else{
                continue
            }
            if item.state != .waiting && item.state != .uploading && item.state != .paused{
                continue
            }
            self.uploadId2identifier[item.id] = identifier
            self.uploadingIds.insert(item.id)
            self.setUploadMsg(identifier, self.stateMsg(item.state, item.error))
        }
        self.updateUploadCount()
    }
    
    ///上传按钮点击事件
    func onUploadClick(_ isOnlyCheck: Bool) {
        let uploading = Set(self.uploadingIds.compactMap{ self.uploadId2identifier[$0] })
        let assetList = self.albumList.filter{ $0.checked && !uploading.contains($0.identifier) }.map{ $0.asset }
        if assetList.isEmpty{
            Toast.show("未选择任何对象")
            return
        }
        if isOnlyCheck{
            self.check(assetList)
        } else {
            self.upload(assetList)
        }
        
        //通知相册列表页面更新
        NotificationCenter.default.post(name: Notification.Name(AlbumPage.ALBUM_PAGE_RELOAD_DATA), object: nil)
    }
    
    /// 添加上传任务
    private func upload(_ assetList: [PHAsset]){
        let isAlbum = self.uploadMode == .album
        let folder = isAlbum ? "/相册" : SettingStore.lastOpenFolder
        let time = Int64(Date().timeIntervalSince1970 * 1_000_000)
        let items = assetList.enumerated().map{ index, asset in
            UploadItem(
                source: .custom(id: FileUploadSource.makeId(identifier: asset.localIdentifier)),
                dfsPath: folder + "/\(time + Int64(index))." + FileUploadSource.uploadExt(asset),
                md5: self.md5Map[asset.localIdentifier],
                skipIfExists: isAlbum//相册同步时,已经有相同的文件就不需要再上传
            )
        }
        do {
            let ids = try FileSdkUtil.get().addUploads(items: items)

            //上一次的上传已经全部结束时,重新计算进度,否则上一次的文件也会算在总数里
            if self.uploadingIds.isEmpty{
                self.uploadId2identifier.removeAll()
            }
            for (id, asset) in zip(ids, assetList){
                self.uploadId2identifier[id] = asset.localIdentifier
                self.uploadingIds.insert(id)
                self.setUploadMsg(asset.localIdentifier, "排队中")
            }
            self.updateUploadCount()
        } catch {
            Toast.show(error.fileSdkMessage)
        }
    }
    
    /// 检查选中的文件是否已经上传
    private func check(_ assetList: [PHAsset]){
        let identifiers = assetList.map{ $0.localIdentifier }
        identifiers.forEach{ self.setUploadMsg($0, "排队中") }
        self.isUploading = true
        self.checkTask = Task{@MainActor in
            for (index, identifier) in identifiers.enumerated(){
                if Task.isCancelled{
                    break
                }
                self.uploadCountMsg = "进度:\(index + 1)/\(identifiers.count)"
                self.setUploadMsg(identifier, await self.checkOne(identifier))
            }
            identifiers.filter{ self.uploadMsg($0) == "排队中" }.forEach{ self.setUploadMsg($0, "") }
            self.checkTask = nil
            self.isUploading = !self.uploadingIds.isEmpty
        }
    }
    
    /// 检查一个文件是否已经上传,返回提示文字
    @MainActor
    private func checkOne(_ identifier: String) async -> String{
        var md5 = self.md5Map[identifier]
        if md5 == nil{
            self.setUploadMsg(identifier, "文件校验中")
            do {
                md5 = try await Task.detached{ try FileUploadSource.md5(identifier: identifier) }.value
                self.md5Map[identifier] = md5
            } catch {
                return "失败:\(error.fileSdkMessage)"
            }
        }
        self.setUploadMsg(identifier, "校验上传状态")
        let result = await withCheckedContinuation{ (continuation: CheckedContinuation<String, Never>) in
            FileUploadApi.exists(md5: md5!).hide().error{
                continuation.resume(returning: "失败:\($0)")
            }.fail{
                continuation.resume(returning: "失败:\($0.msg ?? "")")
            }.send{ (exists: Bool) in
                continuation.resume(returning: exists ? SystemAlbumViewModel.MSG_UPLOADED : "未上传")
            }
        }
        return result
    }
    
    /// 取消所有还没有结束的上传和检查,已经上传的部分服务器会保留,下次可以继续
    func onCancelClick(){
        self.checkTask?.cancel()
        let ids = Array(self.uploadingIds)
        if ids.isEmpty{
            return
        }
        Task.detached{
            do {
                try FileSdkUtil.get().deleteUploads(ids: ids)
            } catch {
                Toast.show(error.fileSdkMessage)
            }
        }
    }
    
    /// SDK事件,更新相册文件的上传状态
    func onFileSdkEvent(_ event: Event){
        switch event{
        case let .uploadProgress(id, hashing, size, done, _):
            guard let identifier = self.uploadId2identifier[id] else{
                return
            }
            if hashing{
                self.setUploadMsg(identifier, "文件校验中")
            } else {
                self.setUploadMsg(identifier, Int64(done).fileSize + "/" + Int64(size).fileSize)
            }
        case let .uploadStateChanged(id, state, error):
            guard let identifier = self.uploadId2identifier[id] else{
                return
            }
            self.setUploadMsg(identifier, self.stateMsg(state, error))
            if state == .finish || state == .skipped || state == .error{
                self.uploadingIds.remove(id)
                if state != .error, let md5 = try? FileSdkUtil.get().getUpload(id: id)?.md5{
                    self.md5Map[identifier] = md5
                }
                if state == .finish{//通知相册列表页面更新
                    NotificationCenter.default.post(name: Notification.Name(AlbumPage.ALBUM_PAGE_RELOAD_DATA), object: nil)
                }
                self.updateUploadCount()
            }
        case let .uploadRemoved(ids):
            for id in ids{
                guard let identifier = self.uploadId2identifier.removeValue(forKey: id) else{
                    continue
                }
                if self.uploadingIds.remove(id) != nil{
                    self.setUploadMsg(identifier, "")
                }
            }
            self.updateUploadCount()
        default:
            break
        }
    }
    
    /// 上传状态的提示文字
    private func stateMsg(_ state: UploadState, _ error: String?) -> String{
        switch state{
        case .waiting: return "排队中"
        case .uploading: return "准备上传"
        case .paused: return "已暂停"
        case .error: return "失败:\(FileSdkUtil.friendlyError(error ?? ""))"
        case .finish, .skipped: return SystemAlbumViewModel.MSG_UPLOADED
        }
    }
    
    /// 更新上传数量提示
    private func updateUploadCount(){
        self.isUploading = !self.uploadingIds.isEmpty || self.checkTask != nil
        if self.uploadId2identifier.isEmpty{
            self.uploadCountMsg = nil
            return
        }
        let total = self.uploadId2identifier.count
        self.uploadCountMsg = "进度:\(total - self.uploadingIds.count)/\(total)"
    }
    
    /// 相册文件当前的提示文字
    private func uploadMsg(_ identifier: String) -> String?{
        guard let index = self.identifier2index[identifier] else{
            return nil
        }
        return self.albumList[index].uploadMsg
    }
    
    /// 设置相册文件的提示文字
    private func setUploadMsg(_ identifier: String, _ msg: String){
        if let index = self.identifier2index[identifier]{
            self.albumList[index].uploadMsg = msg
        }
        NotificationCenter.default.post(name: Notification.Name(SystemAlbumViewModel.NOTIFY_UPLOAD_PROGRESS + identifier), object: msg)
    }
    
    ///保存计算好的相册文件md5,只保留相册里还存在的文件
    func saveMd5(){
        self.checkTask?.cancel()
        let md5Map = self.md5Map.filter{ self.identifier2index[$0.key] != nil }
        _ = LocalObjectUtil.write(md5Map, SystemAlbumViewModel.KEY_MD5)
    }
    
    ///删除已经上传的相册文件
    func onDeleteClick() {
        
        //要删除的相册列表
        let deleteList = self.albumList.filter{$0.uploadMsg == SystemAlbumViewModel.MSG_UPLOADED}.map{$0.asset}
        if deleteList.isEmpty{
            Toast.show("没有检查到已上传的文件")
            return
        }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(deleteList as NSArray)
        }) { success, error in
            if success {
                self.fetchPhotos()
                Toast.show("照片已删除")
            } else {
                Toast.show("删除失败: \(error?.localizedDescription ?? "未知错误")")
            }
        }
    }
    
    // 全选点击事件
    func onCheckAllClick(){
        for i in 0 ..< self.albumList.endIndex{
            self.albumList[i].checked = true
        }
        self.checkedCount = self.albumList.count
    }
    
    deinit{
        debugPrint("-->SystemAlbumViewModel.deinit")
    }
}
