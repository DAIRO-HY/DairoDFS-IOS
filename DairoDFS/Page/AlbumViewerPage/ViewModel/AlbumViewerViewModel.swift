//
//  ImageViewerViewModel.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/05.
//

import Foundation
import UIKit
import AVFoundation
import DairoUI_IOS
import SwiftUI
import Photos

//@TODO: deinit函数尚未调用,待解决
class AlbumViewerViewModel: ObservableObject{
    
    ///页面切换动画时间(秒)
    ///该时间不宜过长,过长可能导致用户快速切换时显示的图片错乱
    ///该时间也不宜过短,过短会让页面闪烁一下,看起来不爽
    static let ANIMATION_TIME: Double = 0.2
    
    //当前视图区域的尺寸
    let screenWidth: CGFloat
    
    //当前视图区域的尺寸
    let screenHeight: CGFloat
    
    ///文件列表
    var fileModels = [FileModel]()
    
    ///当前选中的序号
    @Published var currentIndex = 0
    
    ///用来保存HStack显示偏移量,使其HStack准确显示当前控件位置
    @Published var hStackOffset: CGFloat = 0
    
    ///未显示部分占位宽度
    @Published var notShowWidth = CGFloat(0)
    
    ///正在缩放比例
    @Published var zoomingAmount: CGFloat = 1
    
    ///缩放比例
    @Published var zoomAmount: CGFloat = 1.0
    
    /// 正在移动中的偏移位置
    @Published var currentOffsetPosition: CGSize = .zero
    
    ///记录上一次移动的位置
    @Published var preOffsetPosition: CGSize = .zero
    
    ///当前图片
    @Published var uiImage: UIImage? = nil
    
    ///缩略图
    @Published var thumbImage: UIImage? = nil
    
    /// 下载进度信息
    @Published var progress = ""
    
    ///图片宽高比
    var uiImageWHRate: CGFloat
    
    ///屏幕宽高比
    var screenWHRate: CGFloat
    
    //没有缩放状态下的显示宽与高
    var displayW1: CGFloat
    var displayH1: CGFloat
    
    // 创建一个 AVPlayer 实例
    @Published var videoPlayer: AVPlayer?
    
    ///文件Model
    ///private var mFileModel: FileModel?
    var fm: FileModel{
        return self.fileModels[self.currentIndex]
    }
    
    //这是否是一个视频
    var isVideo = false
    
    /// 标记是否下载文件
    @Published var isDownloadFlag = false
    
    /// 下载完成之后是否保存到系统相册
    private var isSaveToAlbum = false
    
    init(_ fileModels: [FileModel], _ index: Int){
        let bounds = UIScreen.main.bounds
        self.screenWidth = bounds.width
        self.screenHeight = bounds.height
        
        //屏幕宽高比
        self.screenWHRate = self.screenWidth / self.screenHeight
        
        
        //为了保证图片未加载时也能正常切换,默认将屏幕大小作为图片大小
        self.displayW1 = self.screenWidth
        self.displayH1 = self.screenHeight
        
        //图片宽高比
        self.uiImageWHRate = self.screenWidth / self.screenHeight
        
        self.fileModels = fileModels
        self.changePage(index)
    }
    
    func fixPageViewPosition(){
        
        //页面切换滑动距离
        let threshold = self.screenWidth / 4
        
        //本次拖拽的距离 = 当前页偏移位置 - 上页偏移位置
        let dragDistance = (-CGFloat(self.currentIndex + 1) * self.screenWidth) - self.hStackOffset
        var currentIndex = self.currentIndex
        
        //如果移动的距离达到了页面切换的距离
        if dragDistance < -threshold {
            currentIndex -= 1
        } else if dragDistance > threshold {
            currentIndex += 1
        }
        if !self.fileModels.indices.contains(currentIndex){//如果切换页面超出了当前页面数量返回
            currentIndex = self.currentIndex
        }
        
        if currentIndex != self.currentIndex{//如果页面要切换
            self.hStackOffset = -CGFloat(currentIndex + 1) * self.screenWidth
            
            //等待动画结束之后再切换页面,防止页面跳闪
            Task{@MainActor in
                await Task.sleep(UInt64(1_000_000_000.0 * AlbumViewerViewModel.ANIMATION_TIME) + 50_000_000)
                self.changePage(currentIndex)
            }
        } else if dragDistance != 0{//拖拽距离达不到页面迁移的标准,则回弹
            self.hStackOffset = -CGFloat(currentIndex + 1) * self.screenWidth
        }
    }
    
    //页面发生变化
    private func changePage(_ index: Int){
        self.isDownloadFlag = false
        self.isSaveToAlbum = false
        self.currentIndex = index
        self.uiImage = nil
        self.hStackOffset = -CGFloat(self.currentIndex + 1) * self.screenWidth
        
        //计算未显示部分占位宽度
        self.notShowWidth = self.screenWidth * CGFloat(self.currentIndex)
        self.currentOffsetPosition = .zero
        self.zoomAmount = 1.0
        self.isVideo = self.fm.isVideo
        if self.isVideo{//视频时
            
            //初始化播放器
            self.videoPlayer = AVPlayer(url: URL(string:  self.fm.preview)!)
        } else {//图片时
            self.loadPicture()
        }
    }
    
    ///加载图片
    func loadPicture(){
        let url = self.fm.preview
        if let imagePath = DownloadManager.getDownloadedPath(self.fm.previewDownloadId){
            if let uiImage = UIImage(contentsOfFile: imagePath){
                self.thumbImage = nil
                self.initImage(uiImage)
            }
            return
        }
        
        //先显示缩略图
        if let thumbPath = DownloadManager.getDownloadedPath(self.fm.thumbDownloadId){
            self.thumbImage = UIImage(contentsOfFile: thumbPath)
        }
        DownloadManager.cache(self.fm.previewDownloadId, url)
    }
    
    ///当前视图显示时
    func onAppear(){
        
        //初始化播放器
        self.videoPlayer = AVPlayer(url: URL(string:  self.fm.preview)!)
    }
    
    ///当前视图没有被时
    func onDisappear(){
        if let videoPlayer{
            videoPlayer.pause()
            videoPlayer.replaceCurrentItem(with: nil)
            self.videoPlayer = nil
        }
    }
    
    /**
     双击事件
     */
    func doubleClick(){
        if self.zoomAmount > 1{
            withAnimation{
                self.zoomAmount = 1
            }
        } else {
            
            // 适合屏幕宽度的倍率
            let screenWidthZoom = self.screenWidth / self.displayW1
            
            // 适合屏幕高度的倍率
            let screenHeightZoom = self.screenHeight / self.displayH1
            
            if screenWidthZoom == screenHeightZoom && screenWidthZoom == 1{//当前照片本身就是屏幕大小的比例
                withAnimation{
                    self.zoomAmount = 2
                }
            }else{//否则
                withAnimation{
                    self.zoomAmount = screenWidthZoom > screenHeightZoom ? screenWidthZoom : screenHeightZoom
                }
            }
        }
    }
    
    ///初始化图片显示
    private func initImage(_ uiImage: UIImage){
        self.uiImage = uiImage
        
        //图片宽高比
        self.uiImageWHRate = uiImage.size.width / uiImage.size.height
        
        if self.uiImageWHRate > self.screenWHRate {//图片的宽高比大于屏幕的宽高比,则没有放大缩小的状态下,显示的宽度为屏幕宽度
            self.displayW1 = self.screenWidth
            self.displayH1 = self.displayW1 / self.uiImageWHRate
        } else {//图片的宽高比小于屏幕的宽高比,则没有放大缩小的状态下,显示的高度为屏幕的高度
            self.displayH1 = self.screenHeight
            self.displayW1 = self.displayH1 * self.uiImageWHRate
        }
    }
    
    
    /**
     计算拖拽偏移位置
     */
    func computeDragPosition(_ value: DragGesture.Value) -> CGSize{
        //        var width: Double
        //        if self.displayW1 * self.zoomAmount < self.screenWidth{//如果缩放后的高小于屏幕高度,则Y轴方向不要偏移
        //            width = self.preOffsetPosition.width
        //        }else{
        //            width = value.translation.width + self.preOffsetPosition.width
        //        }
        
        
        
        let height: Double
        if self.displayH1 * self.zoomAmount < self.screenHeight{//如果缩放后的高小于屏幕高度,则Y轴方向不要偏移
            height = self.preOffsetPosition.height
        }else{
            height = value.translation.height + self.preOffsetPosition.height
        }
        
        //加上self.newPosition的目的是让图片从上次的位置开始移动
        var offset = CGSize(width: value.translation.width + self.preOffsetPosition.width, height: height)
        
        let offsetMinWidth = (self.displayW1 * self.zoomAmount - self.screenWidth) / 2
        if offset.width < -offsetMinWidth{//X轴右边越界
            self.hStackOffset = -CGFloat(self.currentIndex + 1) * self.screenWidth + (offset.width - offsetMinWidth)
            //            print("-->X轴左边越界")
            
            //X轴左边越界之后,禁止仅需拖拽,此时应该响应父控件的拖拽
            offset.width = -offsetMinWidth
        } else if offset.width > offsetMinWidth{//X轴左边越界
            self.hStackOffset = -CGFloat(self.currentIndex + 1) * self.screenWidth + (offset.width - offsetMinWidth)
            //            print("-->X轴右边越界:\(offset.width - offsetMinWidth)")
            
            //X轴左边越界之后,禁止仅需拖拽,此时应该响应父控件的拖拽
            offset.width = offsetMinWidth
        }
        return offset
        //        return CGSize(width: value.translation.width + self.preOffsetPosition.width, height: value.translation.height + self.preOffsetPosition.height)
    }
    
    /**
     * 修复裁剪范围
     */
    func fixCropImage() {
        if self.zoomAmount < 1{//手动缩小比例不能小于最小缩小比例
            self.zoomAmount = 1
        }
        
        //当前偏移
        var offset = self.currentOffsetPosition
        if self.displayW1 * self.zoomAmount < self.screenWidth{//如果缩放后的高小于屏幕宽度,则将图片屏幕水平居中(x轴偏移0)
            offset = CGSize(width: 0, height: offset.height)
        } else {
            let offsetMinWidth = (self.displayW1 * self.zoomAmount - self.screenWidth)/2
            if offset.width < -offsetMinWidth{//X轴左方越界
                offset = CGSize(width: -offsetMinWidth, height: offset.height)
            }else if offset.width > offsetMinWidth{//X轴右方越界
                offset = CGSize(width: offsetMinWidth, height: offset.height)
            }
        }
        
        
        if self.displayH1 * self.zoomAmount < self.screenHeight{//如果缩放后的高小于屏幕高度,则将图片屏幕垂直居中(y轴偏移0)
            offset = CGSize(width: offset.width, height: 0)
        } else {
            
            //拖动到边界计算
            let offsetMinHeight = (self.displayH1 * self.zoomAmount - self.screenHeight)/2
            if offset.height < -offsetMinHeight{//y轴上方越界
                offset = CGSize(width: offset.width, height: -offsetMinHeight)
            } else if offset.height > offsetMinHeight{//y轴下方越界
                offset = CGSize(width: offset.width, height: offsetMinHeight)
            }
        }
        self.currentOffsetPosition = offset
        self.preOffsetPosition = offset
        
        self.fixPageViewPosition()
    }
    
    func recycle(){
        self.uiImage = nil
    }
    
    /// 共享给其他app
    func onShareClick(){
        guard let path = DownloadManager.getDownloadedPath(self.fm.downloadId) else{
            Toast.show("请先将文件下载之后才能共享")
            return
        }
        guard let source = UIApplication.shared.windows.last?.rootViewController else {
            return
        }
        let shareFileURL = URL(string: "file://" + path)!
        let vc = UIActivityViewController(
            activityItems: [shareFileURL],
            applicationActivities: nil
        )
        vc.excludedActivityTypes = nil
        vc.popoverPresentationController?.sourceView = source.view
        source.present(vc, animated: true)
    }
    
    /// 删除按钮点击事件
    func onDeleteClick(){
        FilesApi.deleteByIds(ids: [self.fm.id]).post {
            
            //当前显示的索引
            var currentIndex = self.currentIndex
            
            //移除当前对象
            self.fileModels.remove(at: currentIndex)
            if currentIndex >= self.fileModels.count{// 如果当前序号超出了范围
                currentIndex = self.fileModels.count - 1
            }
            self.changePage(currentIndex)
            
            //通知相册列表页面更新
            NotificationCenter.default.post(name: Notification.Name(AlbumPage.ALBUM_PAGE_RELOAD_DATA), object: nil)
            Toast.show("删除成功")
        }
    }
    
    /// 仅下载点击事件
    func onDownloadOnlyClick(_ isSaveToAlbum: Bool = false){
        self.isSaveToAlbum = isSaveToAlbum
        self.isDownloadFlag = true
        
        //添加下载,如果文件在缓存中,则将缓存标记为永久保存
        DownloadManager.save([(self.fm.downloadId, self.fm.download)])
        if DownloadManager.getDownloadedPath(self.fm.downloadId) != nil{// 文件已经被下载
            self.downloadFinish()
            return
        }
    }
    
    /// 文件下载完成后的操作
    func downloadFinish(){
        if let path = DownloadManager.getDownloadedPath(self.fm.downloadId){ //文件不一定下载成功,所以这里要加判断
            if self.isSaveToAlbum{// 下载完成之后保存到相册
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    //            options.originalFilename = filename
                    
                    if self.isVideo{//视频时
                        
                        // 是否移动文件,而不是复制
                        options.shouldMoveFile = false
                        let videoURL = URL(string: "file://" + path)!
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .video, fileURL: videoURL, options: options)
                    } else {//照片时
                        
                        // 是否移动文件,而不是复制
                        options.shouldMoveFile = false
                        let data = FileUtil.readAll(path)!
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .photo, data: data, options: options)
                    }
                }) { success, error in
                    if success {
                        Toast.show("已保存到相册")
                    } else {
                        Toast.show("保存相册失败: \(error?.localizedDescription ?? "未知错误")")
                    }
                }
            } else {
                Toast.show("下载完成")
            }
        } else {
            Toast.show("下载失败:\(self.progress)")
        }
        
        //取消下载模式
        self.isDownloadFlag = false
        self.isSaveToAlbum = false
    }
    
    
    deinit{
        print("-->ImageViewerViewModel.deinit")
    }
}
