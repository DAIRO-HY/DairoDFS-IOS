//
//  FileViewModel.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//
import Foundation
import SwiftUI
import Photos
import CommonCrypto
import DairoUI_IOS

class SystemAlbumViewModel : ObservableObject{
    
    //当前相册信息列表
    var albumList = [SystemAlbumBean]()
    
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
    
    init(_ mode: UploadMode){
        self.uploadMode = mode
    }
    
    func fetchPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
                var albumAsset = [SystemAlbumBean]()
                
                let now = Date().timeIntervalSince1970
                fetchResult.enumerateObjects { asset, _, _ in
                    let index = albumAsset.count
                    self.identifier2index[asset.localIdentifier] = index
                    albumAsset.append(
                        SystemAlbumBean(
                            identifier: asset.localIdentifier,
                            index: index,
                            asset: asset
                        )
                    )
                }
//                print("-->\(Date().timeIntervalSince1970 - now)")
                Task{@MainActor in
                    self.albumList = albumAsset
                    self.freashFlag += 1
                }
            } else {
                Toast.show("未授权访问相册")
            }
        }
    }
    
    /// 加载相册信息
    /// - Parameter index 序号
    func loadAlbumInfo(_ index: Int){
        if !self.albumList[index].mediaType.isEmpty{
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
    func onItemClick(_ item: SystemAlbumBean){
        self.checkedCount += (item.checked ? -1 : 1)
        self.albumList[item.index].checked = !item.checked
        print(PHAssetResource.assetResources(for: item.asset))
    }
    
    ///上传按钮点击事件
    func onUploadClick(_ isOnlyCheck: Bool) {
        var assetList = [PHAsset]()
        for i in self.albumList.indices{
            if !self.albumList[i].checked{
                continue
            }
            self.albumList[i].uploadMsg = "排队中"
            assetList.append(self.albumList[i].asset)
        }
        if assetList.isEmpty{
            Toast.show("未选择任何对象")
            return
        }
        
        //标记正在上传中
        self.isUploading = true
        PHAssetUploadManager.upload(assetList, isOnlyCheck, mode: self.uploadMode)
        
        //通知相册列表页面更新
        NotificationCenter.default.post(name: Notification.Name(AlbumPage.ALBUM_PAGE_RELOAD_DATA), object: nil)
    }
    
    ///删除已经上传的相册文件
    func onDeleteClick() {
        
        //要删除的相册列表
        let deleteList = self.albumList.filter{$0.uploadMsg == "上传完成"}.map{$0.asset}
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
    
    ///文件排列
    private func sortFile(dfsList: [FileModel]) {
        
        //      //排序方式
        //      final sortType = SettingShared.sortType;
        //
        //      //升降序方式
        //      final sortOrderBy = SettingShared.sortOrderBy;
        //
        //      //排序
        //      dfsList.sort((p1, p2) {
        //        final int compareValue;
        //        if (sortType == FileSortType.NAME) {
        //          compareValue = p1.name.toLowerCase().compareTo(p2.name.toLowerCase());
        //        } else if (sortType == FileSortType.DATE) {
        //          compareValue = p1.date.compareTo(p2.date);
        //        } else if (sortType == FileSortType.SIZE) {
        //          compareValue = p1.size.compareTo(p2.size);
        //        } else if (sortType == FileSortType.EXT) {
        //          compareValue = p1.name.fileExt
        //              .toLowerCase()
        //              .compareTo(p2.name.fileExt.toLowerCase());
        //        } else {
        //          return 0;
        //        }
        //        if (sortOrderBy == FileOrderBy.UP) {
        //          //升降序方式
        //          return compareValue;
        //        }
        //        return compareValue * -1;
        //      });
        //
        //      //使文件夹始终在最上面
        //      dfsList.sort((p1, p2) {
        //        if (p1.fileFlag && !p2.fileFlag) {
        //          //都是文件夹
        //          return 1;
        //        } else if (!p1.fileFlag && p2.fileFlag) {
        //          //都是文件夹
        //          return -1;
        //        } else {
        //          return 0;
        //        }
        //      });
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
