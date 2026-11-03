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
import DairoFileSDK

//@TODO: deinit函数尚未调用,待解决
class AlbumViewerViewModel: ObservableObject{
    
    ///页面切换动画时间(秒)
    ///该时间不宜过长,过长可能导致用户快速切换时显示的图片错乱
    ///该时间也不宜过短,过短会让页面闪烁一下,看起来不爽
    static let ANIMATION_TIME: Double = 0.2
    
    ///双击屏幕时视频快进、快退的秒数
    static let VIDEO_SEEK_SECONDS: Double = 10
    
    ///按住屏幕时视频的播放倍速
    static let VIDEO_SPEED_UP_RATE: Float = 2
    
    //当前视图区域的尺寸
    @Published var screenWidth = CGFloat.zero
    
    //当前视图区域的尺寸
    @Published var screenHeight = CGFloat.zero
    
    ///文件列表
    var fileModels = [FileModel]()

    /// 获取文件属性的http请求
    private var propertyApiHttp: ApiHttpBase?
    
    /// 当前图片的下载任务
    private var fetchTask: FetchTask?

    /// 当前文件属性
    private var fileProperty: FilePropertyModel?

    ///当前文件的一些标签（RAW、4K、4K60FPS......），显示在左上角
    @Published var tags = [String]()

    ///当前文件的时间,显示在顶部,优先显示拍摄时间,没有拍摄时间时显示上传时间
    @Published var fileTime: String? = nil

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
    @Published var thumbImage1: UIImage? = nil

    /// 下载进度信息
    @Published var progress = ""

    /// 标记文件是否已经下载
//    @Published var isDownload = false
    
    ///图片宽高比
    var uiImageWHRate = CGFloat.zero
    
    ///屏幕宽高比
    var screenWHRate = CGFloat.zero
    
    //没有缩放状态下的显示宽与高
    var displayW1 = CGFloat.zero
    var displayH1 = CGFloat.zero
    
    ///文件Model
    ///private var mFileModel: FileModel?
    var fm: FileModel{
        return self.fileModels[self.currentIndex]
    }
    
    //这是否是一个视频
    var isVideo = false
    
    //是否图片
    var isImage: Bool{
        return !self.isVideo
    }
    
   /// 标记当前加载的图片或者视频是否已经下载
   @Published var isShowDownloaded = false
    
    /// 标记是否下载文件
    @Published var isDownloadFlag = false
    
    /// 下载完成之后是否保存到系统相册
    private var isSaveToAlbum = false
    
    /// 是否显示操作按钮
    @Published var showActionView = true
    
    /// 视频播放计时器
    var videoTimer: Timer?
    
    /// 记录进度条是否正在拖拽中
    var videoSliderDragging = false
    
    // 创建一个 AVPlayer 实例
     var videoPlayer: AVPlayer?
    
    /// 视频总时间
    @Published var videoDuration = 1.0
    
    /// 视频当前播放时间
    @Published var videoCurrentTime = 0.0
    
    /// 视频是否正在播放
    @Published var videoIsPlaying = false
    
    /// 标记视频是否播放过
    @Published var videoIsPlayed = false
    
    /// 标记当前播放的视频是否原画
    @Published var videoIsOriginal = false
    
    /// 视频是否正在按住屏幕倍速播放
    @Published var videoIsSpeedUp = false
    
    /// 快进、快退提示的秒数,负数代表快退,nil代表不显示
    @Published var videoSeekTip: Double? = nil
    
    /// 用来让快进、快退提示自动消失的任务
    private var videoSeekTipTask: Task<Void, Never>?
    
    /// 正在跳转的目标时间(秒),连续双击时要从这个时间继续计算,因为跳转完成之前播放器的当前时间还是旧的
    private var videoSeekTarget: Double?
    
    ///当前视频质量
    @Published var videoQualityLabel = SettingShared.videoQualityLabel

    /// 是否需要重新播放视频，而不是接着上次播放
    private var isVideoReplay = true
    
    let dliveVm = AlbumViewerDliveViewModel()
    
    init(_ fileModels: [FileModel], _ index: Int){
        self.currentIndex = index
        self.fileModels = fileModels
    }

    /// 视图初始化时
    func onAppear(_ screenWidth: CGFloat, _ screenHeight: CGFloat){
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight

        //屏幕宽高比
        self.screenWHRate = self.screenWidth / self.screenHeight

        //为了保证图片未加载时也能正常切换,默认将屏幕大小作为图片大小
        self.displayW1 = self.screenWidth
        self.displayH1 = self.screenHeight

        //图片宽高比
        self.uiImageWHRate = self.screenWidth / self.screenHeight
        self.changePage(self.currentIndex)
    }
    
    /// 视图尺寸变化时(屏幕旋转、分屏等),只更新布局,不重新加载文件,视频会继续播放
    func onResize(_ screenWidth: CGFloat, _ screenHeight: CGFloat){
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
        self.screenWHRate = self.screenWidth / self.screenHeight
        self.hStackOffset = -CGFloat(self.currentIndex + 1) * self.screenWidth
        self.notShowWidth = self.screenWidth * CGFloat(self.currentIndex)
        self.currentOffsetPosition = .zero
        self.preOffsetPosition = .zero
        self.zoomAmount = 1.0
        
        //为了保证图片未加载时也能正常切换,默认将屏幕大小作为图片大小
        self.uiImageWHRate = self.uiImage.map{ $0.size.width / $0.size.height } ?? self.screenWHRate
        self.computeDisplaySize()
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
    
    //页面切换
    private func changePage(_ index: Int){
        self.isDownloadFlag = false
        self.isShowDownloaded = false
        self.isSaveToAlbum = false
        self.currentIndex = index
        self.uiImage = nil
        self.hStackOffset = -CGFloat(self.currentIndex + 1) * self.screenWidth

        //计算未显示部分占位宽度
        self.notShowWidth = self.screenWidth * CGFloat(self.currentIndex)
        self.currentOffsetPosition = .zero
        self.zoomAmount = 1.0

        self.tags.removeAll()
        self.fileTime = nil
        self.propertyApiHttp?.cancel()
        self.fileProperty = nil
        self.cancelFetch()

        //停止视频计时器
        self.videoTimer?.invalidate()
        self.videoIsPlaying = false
        self.videoIsPlayed = false
        self.videoPlayer?.pause()
        self.videoPlayer?.replaceCurrentItem(with: nil)
        self.videoPlayer = nil
        self.videoIsOriginal = false
        self.videoIsSpeedUp = false
        self.videoSeekTipTask?.cancel()
        self.videoSeekTip = nil
        self.videoSeekTarget = nil

        self.isVideo = self.fm.isVideo

        //停止实况视频播放
        self.dliveVm.clear()
        if let path = FileSdkUtil.cachedPath(self.fm.propertySource),
           let data = FileUtil.readAll(path),
           let fileProperty = try? JSONDecoder().decode(FilePropertyModel.self, from: data){//如果属性文件已经存在,解析失败时重新获取
            self.fileProperty = fileProperty
            self.initView()
        } else {
            self.progress = "正在加载文件属性"

            //加载文件属性
            let fm = self.fm
            self.propertyApiHttp = FilesApi.getProperty(ids: [fm.id]).hide().error{
                self.progress = $0
            }.fail{
                self.progress = $0.msg ?? "加载文件属性失败"
            }.send{
                self.progress = ""
                self.fileProperty = $0
                if $0.state == 1, let jsonData = try? JSONEncoder().encode($0){//如果文件已经处理完成,则将文件属性信息缓存起来
                    FileSdkUtil.putData(fm.propertySource, jsonData)
                }
                self.initView()
            }
        }
    }

    /// 初始化页面
    private func initView(){
        if self.isVideo{//视频时
            self.onVideoPlayClick()
        } else {//图片时
            self.loadPicture()
        }
        self.showTag()
    }

    /// 显示标签
    private func showTag(){
        if FileSdkUtil.cachedPath(self.fm.downloadSource) != nil{
            self.tags.append("已下载")
        }
        var fileDate = self.fileProperty?.uploadDate ?? 0
        if let propertyData = self.fileProperty?.property.data(using: .utf8),
           let property = try? JSONSerialization.jsonObject(with: propertyData, options: []) as? [String: Any]{
            if let date = property["date"] as? Int64, date > 0{//拍摄时间(毫秒)
                fileDate = date
            }
            if let width = property["width"] as? Int, let height = property["height"] as? Int{
                if width * height == 3840 * 2160{
                    self.tags.append("4K")
                } else if width * height == 1920 * 1080{
                    self.tags.append("HD")
                }
            }
            if let fps = property["fps"] as? Int{
                if (59...60).contains(fps){
                    self.tags.append("60FPS")
                }
            }
        }
        if fileDate > 0{
            self.fileTime = Date(timeIntervalSince1970: Double(fileDate) / 1000).format()
        }
        if self.fm.name.lowercased().hasSuffix(".cr3"){
            self.tags.append("RAW")
        } else if self.fm.name.lowercased().hasSuffix(".dlive"){
            self.tags.append("实况")
        }
    }
    
    ///加载图片
    func loadPicture(){
        if self.fm.isDlive{//如果这是实况照片
            self.dliveVm.setFm(self.fm)
            if let path = FileSdkUtil.cachedPath(self.fm.downloadSource){//如果文件已经下载
                let dliveInfo = DliveUtil.getInfo(path)
                if let uiImage = UIImage(data: dliveInfo.photoData){
                    self.isShowDownloaded = true
                    self.initImage(uiImage)
                }
                return
            }
        }
        
        //优先加载下载好的预览图片
        if let path = FileSdkUtil.cachedPath(self.fm.previewImageSource){
            if let uiImage = UIImage(contentsOfFile: path){
                self.isShowDownloaded = true
                self.initImage(uiImage)
            }
            return
        }
        
        //先显示缩略图
        if let path = FileSdkUtil.cachedPath(self.fm.thumbSource){
            if let uiImage = UIImage(contentsOfFile: path){
                self.initImage(uiImage)
            }
        } else if self.fm.hasThumb{//取加载缩略图
            self.fetch(self.fm.thumbSource)
        }
    }
    
    /// 下载图片,完成之后刷新视图
    private func fetch(_ source: FileSource){
        self.cancelFetch()
        self.fetchTask = FileSdkUtil.fetch(source, progress: {
            self.progress = "\($0)%"
        }, finish: { _, error in
            self.fetchTask = nil
            self.progress = error ?? ""
            if error == nil{
                self.loadPicture()
            }
        })
    }
    
    /// 取消下载图片
    func cancelFetch(){
        self.fetchTask?.cancel()
        self.fetchTask = nil
    }
    
    /**
     双击事件
     */
    func doubleClick(){
        if self.zoomAmount > 1{
            withAnimation{
                self.zoomAmount = 1
                self.fixCropImage()
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
    /// - Paramter uiImage 图片数据
    private func initImage(_ uiImage: UIImage){
        self.progress = ""
        self.uiImage = uiImage
        
        //图片宽高比
        self.uiImageWHRate = uiImage.size.width / uiImage.size.height
        self.computeDisplaySize()
    }
    
    /// 计算没有放大缩小的状态下,图片显示的宽与高
    private func computeDisplaySize(){
        if self.uiImageWHRate > self.screenWHRate {//图片的宽高比大于屏幕的宽高比,则没有放大缩小的状态下,显示的宽度为屏幕宽度
            self.displayW1 = self.screenWidth
            self.displayH1 = self.displayW1 / self.uiImageWHRate
        } else {//图片的宽高比小于屏幕的宽高比,则没有放大缩小的状态下,显示的高度为屏幕的高度
            self.displayH1 = self.screenHeight
            self.displayW1 = self.displayH1 * self.uiImageWHRate
        }
    }
    
    /// 启动视频计时器
    func startVideoTimer(){
        self.videoTimer?.invalidate()
        self.videoTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            #if DEBUG
            print("-->time:开始一次循环")
            #endif
            if self.videoSliderDragging{//进度条正在退拽中
                return
            }
            guard let player = self.videoPlayer else{
                self.videoTimer?.invalidate()
                return
            }
            guard let item = player.currentItem else{
                return
            }
            let duration = item.duration.seconds
            if duration.isNaN{
                return
            }
            self.videoDuration = duration * 1000
            self.videoCurrentTime = item.currentTime().seconds * 1000
        }
    }
    
    /// 视频播放结束,回到开头并暂停。计时器在控制栏隐藏时不运行,所以要通过系统通知来判断播放结束
    /// - Parameter item 播放结束的视频,系统里其他播放器结束时也会收到通知,要判断是否当前视频
    func onVideoPlayEnd(_ item: AVPlayerItem?){
        guard let player = self.videoPlayer, item != nil, player.currentItem === item else{
            return
        }
        self.videoTimer?.invalidate()
        self.videoSeekTarget = nil
        player.pause()
        player.seek(to: .zero)
        self.videoCurrentTime = 0
        self.videoIsPlaying = false
    }
    
    /// 暂停视频播放
    func onVideoPauseClick(){
        self.videoPlayer?.pause()
        self.videoTimer?.invalidate()
        self.videoIsPlaying = false
    }

    /// 视频播放按钮点击事件
    func onVideoPlayClick(){
        if self.isVideoReplay{//强制重新播放
            self.videoPlay()
            return
        }
        if let videoPlayer{//如果播放器仅仅是暂停，直接播放即可
            self.videoPlayer?.play()

            //开启播放进度计时器
            self.startVideoTimer()
            self.videoIsPlaying = true
            return
        }
        self.videoPlay()
    }

    /// 视频快进、快退
    /// - Parameter seconds 跳转的秒数,负数代表快退
    func onVideoSeek(_ seconds: Double){
        guard let player = self.videoPlayer, let item = player.currentItem else{
            return
        }
        let duration = item.duration.seconds
        if duration.isNaN{//视频还没有加载好
            return
        }
        let target = min(max((self.videoSeekTarget ?? item.currentTime().seconds) + seconds, 0), duration)
        self.videoSeekTarget = target
        self.videoDuration = duration * 1000
        self.videoCurrentTime = target * 1000
        self.showVideoSeekTip(seconds)
        
        //默认的跳转只会跳到附近的关键帧,关键帧间隔较大时跳转的时间不准,这里要求精确跳转
        player.seek(to: CMTime(seconds: target, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero){ finished in
            Task{ @MainActor in
                guard self.videoSeekTarget == target else{//已经有新的跳转
                    return
                }
                self.videoSeekTarget = nil
                if finished && self.videoIsPlaying && player === self.videoPlayer{//播放到结尾时播放器会自动停止,跳回去之后要继续播放
                    player.rate = self.videoIsSpeedUp ? AlbumViewerViewModel.VIDEO_SPEED_UP_RATE : 1
                }
            }
        }
    }
    
    /// 显示快进、快退提示,一段时间后自动消失
    private func showVideoSeekTip(_ seconds: Double){
        self.videoSeekTip = seconds
        self.videoSeekTipTask?.cancel()
        self.videoSeekTipTask = Task{ @MainActor in
            try? await Task.sleep(nanoseconds: 800_000_000)
            if !Task.isCancelled{
                self.videoSeekTip = nil
            }
        }
    }
    
    /// 按住屏幕倍速播放,松手恢复
    func onVideoSpeedUpChange(_ isSpeedUp: Bool){
        self.videoIsSpeedUp = isSpeedUp
        if self.videoIsPlaying{
            self.videoPlayer?.rate = isSpeedUp ? AlbumViewerViewModel.VIDEO_SPEED_UP_RATE : 1
        }
    }

    /// 选择视频清晰度播放点击事件
    func onVideoSelectResolutionClick(){
        self.videoPlay()
    }
    
    /// 播放点击事件
    private func videoPlay(){
        self.videoIsPlayed = true//标记视频播放过
        self.isVideoReplay = false
        var currentTime = CMTime.zero//记录当前播放时间，方便切换清晰度之后继续播放
        if let videoPlayer{//获取当前播放时间,接下来接着播放
           if let item = videoPlayer.currentItem{
                currentTime = item.currentTime()
           }
        }
        if let path = FileSdkUtil.cachedPath(self.fm.downloadSource){//如果该视频文件已经被下载,直接播放已经下载的文件
            self.videoPlayer = AVPlayer(url: URL(fileURLWithPath:  path))
            self.videoPlayer?.seek(to: currentTime)
            self.videoPlayer?.play()
            
            //开启播放进度计时器
            self.startVideoTimer()
            self.isShowDownloaded = true
            self.videoIsOriginal = true
            self.videoIsPlaying = true
            return
        }
        guard self.fileProperty != nil else{
            Toast.show("未获取到文件信息")
            return
        }

        let videoSource = self.videoOnlineSource
        self.videoIsOriginal = videoSource.cacheKey == self.fm.downloadSource.cacheKey
        guard let asset = videoSource.directAsset else{
            Toast.show("视频加载失败")
            return
        }
        Task.detached{ //网络视频应该通过异步任务加载,否则可能导致UI卡顿
            self.videoPlayer = AVPlayer(playerItem: AVPlayerItem(asset: asset))
            self.videoPlayer?.currentItem?.asset.loadValuesAsynchronously(forKeys: ["duration"]){
                var error: NSError?
                let status = self.videoPlayer?.currentItem?.asset.statusOfValue(forKey: "duration", error: &error)
                if status == .loaded {//视频缓冲完成
                    Task{ @MainActor in
                        self.videoIsPlaying = true
                        self.videoPlayer?.seek(to: currentTime)
                        self.videoPlayer?.play()
                        self.startVideoTimer()
                    }
                } else if status == .failed {
                    Task{ @MainActor in
                        Toast.show("视频加载失败,请检查网络或访问权限")
                    }
                }
            }
        }
    }

    /// 视频在线播放时的文件
    private var videoOnlineSource: FileSource{
        guard (self.fileProperty!.extraList.contains{ $0.name == "preview" }) else {//没有预览视频，使用原视频
            return self.fm.downloadSource
        }
        switch SettingShared.videoQuality{
        case SettingShared.VIDEO_QUALITY_ORIGINAL://播放原文件视频
            return self.fm.downloadSource
        case SettingShared.VIDEO_QUALITY_SMOOTH://播放流畅视频
            return self.fm.previewVideoSource
        default://自动
            if SettingShared.isLanServer{//如果是局域网,则优先原画
                return self.fm.downloadSource
            } else {//播放流畅视频
                return self.fm.previewVideoSource
            }
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
        guard FileSdkUtil.cachedPath(self.fm.downloadSource) != nil, let id = FileSdkUtil.cacheId(self.fm.downloadSource) else{
            Toast.show("请先将文件下载之后才能共享")
            return
        }
        guard let source = UIApplication.shared.windows.last?.rootViewController else {
            return
        }
        let name = self.fm.name
        let shareFolder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).path
        Task.detached{
            
            //缓存文件的名字是缓存ID,导出到临时目录,这样其他app看到的才是真实的文件名
            do {
                let path = try FileSdkUtil.get().export(id: id, destDir: shareFolder, name: name)
                Task{@MainActor in
                    let vc = UIActivityViewController(
                        activityItems: [URL(fileURLWithPath: path)],
                        applicationActivities: nil
                    )
                    vc.excludedActivityTypes = nil
                    vc.popoverPresentationController?.sourceView = source.view
                    source.present(vc, animated: true)
                }
            } catch {
                Toast.show(error.fileSdkMessage)
            }
        }
    }
    
    /// 删除按钮点击事件
    func onDeleteClick(){
        FilesApi.delete(ids: [self.fm.id]).send {
            
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
        do {
            try FileSdkUtil.download(self.fm.downloadSource)
        } catch {
            self.progress = error.fileSdkMessage
            self.downloadFinish()
            return
        }
        if FileSdkUtil.cachedPath(self.fm.downloadSource) != nil{// 文件已经被下载
            self.downloadFinish()
            return
        }
    }
    
    /// SDK事件,更新当前文件的下载进度
    func onFileSdkEvent(_ event: Event){
        guard self.isDownloadFlag, let id = FileSdkUtil.cacheId(self.fm.downloadSource) else{
            return
        }
        switch event{
        case let .progress(eventId, _, size, downloaded, _):
            if eventId == id, let size, size > 0{
                self.progress = "\(Int(Double(downloaded) / Double(size) * 100))%"
            }
        case let .stateChanged(eventId, _, state, error):
            if eventId != id{
                return
            }
            if state == .finish{
                self.progress = ""
                self.downloadFinish()
            } else if state == .error{
                self.progress = FileSdkUtil.friendlyError(error ?? "下载失败")
                self.downloadFinish()
            }
        default:
            break
        }
    }
    
    /// 文件下载完成后的操作
    func downloadFinish(){
        if let path = FileSdkUtil.cachedPath(self.fm.downloadSource){ //文件不一定下载成功,所以这里要加判断
            if self.isSaveToAlbum{// 下载完成之后保存到相册
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    let request = PHAssetCreationRequest.forAsset()
                    if self.isVideo{//视频时
                        options.shouldMoveFile = false // 是否移动文件,而不是复制
                        let videoURL = URL(fileURLWithPath: path)
                        request.addResource(with: .video, fileURL: videoURL, options: options)
                        return
                    }
                    if self.fm.isDlive{//实况照片时
                        options.shouldMoveFile = true // 是否移动文件,而不是复制
                        let dliveInfo = DliveUtil.getInfo(path)
                        
                        // 添加 JPEG 作为照片
                        let photoURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + "." + dliveInfo.photoExt)
                        FileManager.default.createFile(atPath: photoURL.path, contents: dliveInfo.photoData)
                        request.addResource(with: .photo, fileURL: photoURL, options: options)
                        
                        
                        // 添加 MOV 作为实况视频
                        let videoURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + "." + dliveInfo.videoExt)
                        FileManager.default.createFile(atPath: videoURL.path, contents: dliveInfo.videoData)
                        request.addResource(with: .pairedVideo, fileURL: videoURL, options: options)
                        return
                    }
                    options.shouldMoveFile = false // 是否移动文件,而不是复制
                    let data = FileUtil.readAll(path)!
                    request.addResource(with: .photo, data: data, options: options)
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
            if self.isVideo{
                if !self.isShowDownloaded{//当前显示的视频并非已下载版
                    self.isVideoReplay = true
                    if self.videoIsPlaying{//如果当前视频正在播放中,则重新播放已经下载的版本
                        self.onVideoPlayClick()
                    }
                }
            }
        } else {
            Toast.show("下载失败:\(self.progress)")
        }
        
        //取消下载模式
        self.isDownloadFlag = false
        self.isSaveToAlbum = false
    }
    
    ///  加载原图点击事件
    func onLoadOriginalClick(){
        
        //请求加载原图
        self.fetch(self.fm.previewImageSource)
    }
    
    
    deinit{
        print("-->AlbumViewerViewModel.deinit")
    }
}
