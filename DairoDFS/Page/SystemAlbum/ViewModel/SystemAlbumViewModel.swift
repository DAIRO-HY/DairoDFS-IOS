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
    @Published var albumList = [SystemAlbumBean]()
    
    //文件唯一ID对应所在序号
    var identifier2index = [String:Int]()
    
    /// 当前请求的文件夹
    var currentFolder = ""
    
    ///记录当前选中的文件数
    @Published var checkedCount = 0
    
    @Published var dfsFileList = [DfsFileEntity]()
    
    ///  剪切板模式
    @Published var clipboardType = 0
    
    ///选择模式
    @Published var isSelectMode = true
    
    ///记录当前选中的文件数
    @Published var status = ""
    
    ///上传数量通知消息
    @Published var uploadCountMsg: String?
    
    init(){
        self.fetchPhotos()
    }
    
    func fetchPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
                var albumAsset = [SystemAlbumBean]()
                fetchResult.enumerateObjects { asset, _, _ in
                    let index = albumAsset.count
                    self.identifier2index[asset.localIdentifier] = index
                    let bean = self.getAssetFileExtension(asset, index)
                    albumAsset.append(bean)
                }
                Task{@MainActor in
                    self.albumList = albumAsset
                }
                debugPrint(albumAsset.count)
            } else {
                print("未授权访问相册")
            }
        }
    }
    
    //获取文件信息
    private func getAssetFileExtension(_ asset: PHAsset, _ index: Int) -> SystemAlbumBean {
        //        var ext = ""
        //        let resources = PHAssetResource.assetResources(for: asset)
        //
        //        var name = ""
        //        if let resource = resources.first {
        //            let originalFilename = resource.originalFilename
        //            ext = (originalFilename as NSString).pathExtension.lowercased()
        //            name = originalFilename
        //        }
        //        var mediaType = ""
        //        if asset.mediaSubtypes.contains(.photoLive) {
        //            // 实况照片
        //            mediaType = "Live Photo"
        //        } else if asset.mediaType == .image {
        //            // 普通图片
        //            mediaType = "Image"
        //        } else if asset.mediaType == .video {
        //            // 视频
        //            mediaType = "Video"
        //        }
        //       return AlbumSyncBean(identifier: asset.localIdentifier, asset: asset, mediaType: mediaType, ext: ext, name: name)
        return SystemAlbumBean(identifier: asset.localIdentifier, index: index, asset: asset, mediaType: "mediaType", ext: "ext", name: "name")
    }
    
    //检查是否已经上传
    func onCheckExistsClick(){
        self.loopMakeMd5AndCheckExists(0)
    }
    
    //图片点击事件
    func onItemClick(_ item: SystemAlbumBean){
        self.checkedCount += (item.checked ? -1 : 1)
        self.albumList[item.index].checked = !item.checked
    }
    
    ///上传按钮点击事件
    func onUploadClick() {
        var assetList = [PHAsset]()
        for i in self.albumList.indices{
            if !self.albumList[i].checked{
                continue
            }
            self.albumList[i].uploadMsg = "等待上传"
            assetList.append(self.albumList[i].asset)
        }
        if assetList.isEmpty{
            Toast.show("请选择后上传")
            return
        }
        PHAssetUploadManager.upload(assetList)
//        self.loopUpload(0)
    }
    
    func delete(assets: [PHAsset]) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets as NSArray)
        }) { success, error in
            if success {
                print("照片已删除")
            } else {
                print("删除失败: \(error?.localizedDescription ?? "未知错误")")
            }
        }
    }
    
    /**
     重新加载
     */
    func reload(){
        self.loadSubFile(self.currentFolder)
    }
    
    ///获取文件列表
    func loadSubFile(_ folderPath: String) {
        DfsFileShared.getSubList(folderPath){list in
            //        if (this.filePageState.isFinish) {
            //          //如果页面已经关闭，那就什么也不做。防止异步操作时，页面被关闭报错
            //          return;
            //        }
            //        this.sortFile(list);
            
            var dfsFileList = [DfsFileEntity]()
            for item in list{
                dfsFileList.append(DfsFileEntity(item))
            }
            self.dfsFileList = dfsFileList
            //        this.dfsFileList = list.map((it) => DfsFileVM(folderPath, it)).toList();
            //        this.filePageState.selectedCount = 0;
            
            //        //设置当前显示的文件夹路径
            //        this.filePageState.currentFolderVN.value = folderPath;
            //
            //        //记录当前打开的文件夹
            //        SettingShared.lastOpenFolder = folderPath;
            //
            //        //重回文件页面
            //        this.redraw();
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
    
    /**
     清空已经选择的文件
     */
    func clearSelected(){
        for item in self.dfsFileList{
            item.isSelected = false
        }
        self.checkedCount = 0
    }
    
    // 全选点击事件
    func onCheckAllClick(){
        for i in 0 ..< self.albumList.endIndex{
            self.albumList[i].checked = true
        }
        self.checkedCount = self.albumList.count
    }
    
    //循环上传相册数据
    private func loopUpload(_ index: Int){
        if index >= self.albumList.count{//数据已经遍历完成
            return
        }
        if !self.albumList[index].checked{
            self.loopUpload(index + 1)
            return
        }
        
        //去计算文件md5
        self.conputeMd5(index){
            
            //去检查有没有上传过
            self.checkExists(index){
                
                //继续获取下一个相册
                //self.loopUpload(index + 1)
                self.upload(index)
            }
        }
    }
    
    //循环上传图片
    private func upload(_ index: Int){
//        let bean = self.albumList[index]
//        let uploader = StreamUploader(bean.asset)
//        
//        let url = SettingShared.domainNotNull + "/app/file_upload/by_stream/" + bean.md5!
//        uploader.upload(to: url)
    }
    
    //循环去获取图片上传状态
    private func loopMakeMd5AndCheckExists(_ index: Int){
        if index >= self.albumList.count{//数据已经遍历完成
            return
        }
        
        //去计算文件md5
        self.conputeMd5(index){
            
            //去检查有没有上传过
            self.checkExists(index){
                
                //继续获取下一个相册
                self.loopMakeMd5AndCheckExists(index + 1)
            }
        }
    }
    
    ///计算图片MD5
    /// - index 当前计算的下标
    private func conputeMd5(_ index: Int,  callback: @escaping () -> Void) {
        // 确保是视频类型
        //        guard asset.mediaType == .video else {
        //            completion(nil)
        //            return
        //        }
        
        // 获取视频资源（注意有多个时可能需要更精确过滤）
        //        guard let resource = PHAssetResource.assetResources(for: asset).first(where: { $0.type == .video }) else {
        //            print("未找到视频资源")
        //            completion(nil)
        //            return
        //        }
        
        self.status = "正在检查\(index + 1)/\(self.albumList.count)"
        let bean = self.albumList[index]
        
        // 设置读取选项（可设置 isNetworkAccessAllowed 等）
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true
        
        // 初始化 MD5 计算上下文
        var context = CC_MD5_CTX()
        CC_MD5_Init(&context)
        
        // 读取资源数据并计算 MD5
        PHAssetResourceManager.default().requestData(for: PHAssetResource.assetResources(for: bean.asset).first!, options: options, dataReceivedHandler: { data in
            data.withUnsafeBytes { buffer in
                _ = CC_MD5_Update(&context, buffer.baseAddress, CC_LONG(data.count))
            }
        }, completionHandler: { error in
            if let error = error {
                print("读取失败: \(error)")
                //                completion(nil)
            } else {
                // 计算最终的 MD5 值
                var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
                CC_MD5_Final(&digest, &context)
                
                // 转换为十六进制字符串
                let md5 = digest.map { String(format: "%02x", $0) }.joined()
                //                completion(md5String)
                Task{@MainActor in
                    self.albumList[index].md5 = md5
                    callback()
                    //                    self.checkExists(index)
                }
            }
        })
    }
    
    //通过md5检查文件是否已经上传
    private func checkExists(_ index: Int, callback: @escaping () -> Void){
        let bean = self.albumList[index]
        FileUploadApi.checkExistsByMd5(md5: bean.md5!).hide().post {
            self.albumList[index].existsFlag = $0 ? 1 : 0
            callback()
        }
    }
    
    
    deinit{
        debugPrint("-->SystemAlbumViewModel.deinit")
    }
}
