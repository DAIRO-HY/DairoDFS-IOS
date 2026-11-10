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
    
    ///轻扫切换页面的速度(pt/秒),松手时超过这个速度就算轻扫
    static let FLICK_VELOCITY: CGFloat = 500
    
    ///惯性滑动每毫秒的速度衰减,和系统UIScrollView的默认值一样
    static let INERTIA_DECAY: Double = 0.998
    
    ///松手时速度低于这个值(pt/秒)时没有惯性滑动
    static let INERTIA_MIN_VELOCITY: CGFloat = 100
    
    ///惯性滑动速度低于这个值(pt/秒)时停止
    static let INERTIA_STOP_VELOCITY: CGFloat = 20
    
    ///拖动超出边界时的阻力,和系统UIScrollView的效果接近
    static let RUBBER_BAND_RATE: CGFloat = 0.55
    
    ///惯性滑动超出边界时,弹回去的弹簧强度
    static let BOUNCE_STIFFNESS: CGFloat = 300
    
    ///惯性滑动超出边界时,弹回去的阻尼,这个值刚好不会来回晃动
    static let BOUNCE_DAMPING: CGFloat = 35
    
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
    
    /// 当前图片缩略图的下载任务,和图片同时下载
    private var thumbFetchTask: FetchTask?

    /// 当前文件属性
    @Published private(set) var fileProperty: FilePropertyModel?
    
    /// 文件属性是否正在加载
    @Published private(set) var propertyIsLoading = false
    
    /// 属性面板是否显示
    @Published var showInfo = false

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
    
    ///缩放比例
    @Published var zoomAmount: CGFloat = 1.0
    
    /// 图片的偏移位置
    @Published var currentOffsetPosition: CGSize = .zero
    
    /// 放大后拖动图片,松手之后的惯性滑动速度(pt/秒)
    private var inertiaVelocity = CGSize.zero
    
    /// 惯性滑动的逐帧回调,不为nil时表示正在惯性滑动
    private var inertiaLink: AlbumViewerInertiaLink?
    
    /// 是否正在惯性滑动
    var isInertiaRunning: Bool{
        return self.inertiaLink != nil
    }
    
    ///当前图片
    @Published var uiImage: UIImage? = nil
    
    ///缩略图
    @Published var thumbImage1: UIImage? = nil

    /// 图片加载失败的错误信息
    @Published var errorMsg = ""

    /// 图片是否因为网络问题加载失败,在右上角显示联网失败的图标,不显示错误信息
    @Published var isNetworkFail = false

    /// 大图、原图加载中的进度,比如:35%,还没有进度时是空字符串,没有加载时为nil
    @Published private var loadingTip: String?

    /// 下载、保存的进度,格式和loadingTip一样,没有下载时为nil
    @Published private var downloadTip: String?

    /// 加载提示里显示的进度,正在下载时优先显示下载进度
    var progressTip: String?{
        return self.downloadTip ?? self.loadingTip
    }

    /// 是否正在下载、保存
    var isDownloading: Bool{
        return self.downloadTip != nil
    }

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
    
    /// 视频是否正在加载(等待文件属性或者视频信息),这时不能点击播放
    @Published var videoIsLoading = false
    
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
        self.stopInertia()
        self.hStackOffset = -CGFloat(self.currentIndex + 1) * self.screenWidth
        self.notShowWidth = self.screenWidth * CGFloat(self.currentIndex)
        self.currentOffsetPosition = .zero
        self.zoomAmount = 1.0
        
        //为了保证图片未加载时也能正常切换,默认将屏幕大小作为图片大小
        self.uiImageWHRate = self.uiImage.map{ $0.size.width / $0.size.height } ?? self.screenWHRate
        self.computeDisplaySize()
    }
    
    /// 松手之后决定切换页面还是回弹
    /// - Parameter velocity 松手时手指的水平速度,向右为正
    func fixPageViewPosition(velocity: CGFloat = 0){
        
        //页面切换滑动距离
        let threshold = self.screenWidth / 4
        
        //本次拖拽的距离 = 当前页偏移位置 - 上页偏移位置
        let dragDistance = (-CGFloat(self.currentIndex + 1) * self.screenWidth) - self.hStackOffset
        var currentIndex = self.currentIndex
        
        if abs(velocity) > AlbumViewerViewModel.FLICK_VELOCITY{//轻扫时看方向,距离再短也切换。往回扫时不切换
            if dragDistance < 0 && velocity > 0{
                currentIndex -= 1
            } else if dragDistance > 0 && velocity < 0{
                currentIndex += 1
            }
        } else if dragDistance < -threshold {//如果移动的距离达到了页面切换的距离
            currentIndex -= 1
        } else if dragDistance > threshold {
            currentIndex += 1
        }
        if !self.fileModels.indices.contains(currentIndex){//如果切换页面超出了当前页面数量返回
            currentIndex = self.currentIndex
        }
        
        if currentIndex != self.currentIndex{//如果页面要切换
            withAnimation(.linear(duration: AlbumViewerViewModel.ANIMATION_TIME)){
                self.hStackOffset = -CGFloat(currentIndex + 1) * self.screenWidth
            }
            
            //等待动画结束之后再切换页面,防止页面跳闪
            Task{@MainActor in
                await Task.sleep(UInt64(1_000_000_000.0 * AlbumViewerViewModel.ANIMATION_TIME) + 50_000_000)
                self.changePage(currentIndex)
            }
        } else if dragDistance != 0{//拖拽距离达不到页面迁移的标准,则回弹
            withAnimation(.linear(duration: AlbumViewerViewModel.ANIMATION_TIME)){
                self.hStackOffset = -CGFloat(currentIndex + 1) * self.screenWidth
            }
        }
    }
    
    //页面切换
    private func changePage(_ index: Int){
        self.stopInertia()
        self.downloadTip = nil
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
        self.propertyIsLoading = false
        self.fileProperty = nil
        self.cancelFetch()

        //停止视频计时器
        self.videoTimer?.invalidate()
        self.videoIsPlaying = false
        self.videoIsPlayed = false
        self.stopVideoPlayer()
        self.videoIsOriginal = false
        self.videoIsLoading = false
        self.videoIsSpeedUp = false
        self.videoSeekTipTask?.cancel()
        self.videoSeekTip = nil
        self.videoSeekTarget = nil

        self.isVideo = self.fm.isVideo

        //停止实况视频播放
        self.dliveVm.clear()
        self.errorMsg = ""
        self.isNetworkFail = false
        
        //图片和已下载的视频不依赖文件属性,不用等它加载完成,否则网络较差时要一直等待
        if !self.isVideo{
            self.loadPicture()
        } else if FileSdkUtil.cachedPath(self.fm.downloadSource) != nil{
            self.onVideoPlayClick()
        }
        if let path = FileSdkUtil.cachedPath(self.fm.propertySource),
           let data = FileUtil.readAll(path),
           let fileProperty = try? JSONDecoder().decode(FilePropertyModel.self, from: data){//如果属性文件已经存在,解析失败时重新获取
            self.fileProperty = fileProperty
            self.initView()
        } else {
            self.loadProperty()
        }
    }
    
    /// 加载文件属性,图片加载失败时只是不显示时间和标签,不提示错误
    private func loadProperty(){
        if self.isVideo && self.videoPlayer == nil{
            self.videoIsLoading = true
        }
        self.propertyIsLoading = true
        let fm = self.fm
        self.propertyApiHttp = FilesApi.getProperty(ids: [fm.id]).hide().finish{
            self.propertyIsLoading = false
        }.error{
            self.onLoadPropertyFail($0)
        }.fail{
            self.onLoadPropertyFail($0.msg ?? "加载文件属性失败")
        }.send{
            self.onPropertyLoaded(fm, $0)
        }
    }
    
    /// 文件属性加载完成
    private func onPropertyLoaded(_ fm: FileModel, _ fileProperty: FilePropertyModel){
        self.fileProperty = fileProperty
        if fileProperty.state == 1, let jsonData = try? JSONEncoder().encode(fileProperty){//如果文件已经处理完成,则将文件属性信息缓存起来
            FileSdkUtil.putData(fm.propertySource, jsonData)
        }
        self.initView()
    }
    
    /// 文件属性加载失败,视频没有属性不知道该播放哪个清晰度,恢复播放按钮,点击时重新加载
    private func onLoadPropertyFail(_ msg: String){
        if self.isVideo && self.videoIsLoading{
            self.videoIsLoading = false
            Toast.show(msg)
        }
    }

    /// 属性按钮点击事件
    func onInfoClick(){
        if !self.propertyIsLoading{//缓存的属性可能已经过期(服务端补充了字段、其他设备改了拍摄时间),这里重新加载,失败时继续显示缓存
            self.loadProperty()
        }
        self.showInfo = true
    }
    
    /// 修改拍摄时间
    /// - Parameter date 拍摄时间(毫秒),0代表恢复成照片本身的拍摄时间
    /// - Parameter finish 请求结束,失败时返回错误信息
    func updateCaptureTime(_ date: Int64, finish: @escaping (_ error: String?) -> Void){
        
        //避免正在进行的加载覆盖修改结果
        self.propertyApiHttp?.cancel()
        self.propertyIsLoading = false
        let fm = self.fm
        FilesApi.updateCaptureTime(id: fm.id, date: date).hide().error{
            finish($0)
        }.fail{
            finish($0.msg ?? "修改拍摄时间失败")
        }.send{
            self.onPropertyLoaded(fm, $0)
            
            //拍摄时间决定相册排序,通知相册列表页面更新
            NotificationCenter.default.post(name: Notification.Name(AlbumPage.ALBUM_PAGE_RELOAD_DATA), object: nil)
            finish(nil)
        }
    }
    
    /// 初始化页面
    private func initView(){
        if self.isVideo && self.videoPlayer == nil{//视频时,已下载的视频已经开始播放
            self.onVideoPlayClick()
        }
        self.showTag()
    }

    /// 显示标签
    private func showTag(){
        self.tags.removeAll()
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
        }
        if self.showCachedOriginal(){
            return
        }
        
        //先显示缩略图,避免网络较差时黑屏,再加载清晰的图片
        self.loadThumb()
        self.loadScreenImage()
    }
    
    /// 显示已下载或已缓存的原图
    /// - Returns: 没有可以显示的图片时返回false
    private func showCachedOriginal() -> Bool{
        var uiImage: UIImage?
        if let path = FileSdkUtil.cachedPath(self.fm.downloadSource){
            if self.fm.isDlive{//如果这是实况照片
                uiImage = UIImage(data: DliveUtil.getInfo(path).photoData)
            } else {
                uiImage = UIImage(contentsOfFile: path)
            }
        }
        
        //RAW等格式没有下载原文件时,或者原文件无法显示时,看大图预览有没有缓存
        if uiImage == nil, let path = FileSdkUtil.cachedPath(self.fm.previewImageSource){
            uiImage = UIImage(contentsOfFile: path)
        }
        guard let uiImage else{
            return false
        }
        self.isShowDownloaded = true
        self.initImage(uiImage)
        return true
    }
    
    /// 加载缩略图,更清晰的图片已经显示时不再显示
    private func loadThumb(){
        if let path = FileSdkUtil.cachedPath(self.fm.thumbSource){
            if let uiImage = UIImage(contentsOfFile: path){
                self.initImage(uiImage)
            }
        } else if self.fm.hasThumb{
            self.thumbFetchTask = FileSdkUtil.fetch(self.fm.thumbSource, progress: { _ in }, finish: { path, _ in
                self.thumbFetchTask = nil
                if self.uiImage == nil, let path, let uiImage = UIImage(contentsOfFile: path){
                    self.initImage(uiImage)
                }
            })
        }
    }
    
    /// 加载适合当前屏幕的图片,服务器无法生成时直接加载原图
    private func loadScreenImage(){
        let source = self.fm.screenImageSource
        if let path = FileSdkUtil.cachedPath(source), let uiImage = UIImage(contentsOfFile: path){
            self.initImage(uiImage)
            return
        }
        self.fetch(source, notFound: self.loadOriginal){ path in
            if let uiImage = UIImage(contentsOfFile: path){
                self.initImage(uiImage)
            }
        }
    }
    
    /// 加载原图
    private func loadOriginal(){
        self.fetch(self.fm.previewImageSource){ _ in
            _ = self.showCachedOriginal()
        }
    }

    /// 下载图片
    /// - Parameter notFound: 文件不存在时执行,没有指定时显示错误信息
    /// - Parameter success: 下载成功时执行
    private func fetch(_ source: FileSource, notFound: (() -> Void)? = nil, success: @escaping (_ path: String) -> Void){
        self.fetchTask?.cancel()
        self.loadingTip = ""
        self.fetchTask = FileSdkUtil.fetch(source, progress: {
            self.loadingTip = "\($0)%"
        }, finish: { path, error in
            self.fetchTask = nil
            self.errorMsg = ""
            self.isNetworkFail = false
            self.loadingTip = nil
            if let path{
                success(path)
            } else if let notFound, case .NotFound = error as? SdkError{
                notFound()
            } else if case .Network = error as? SdkError{//网络错误信息里有请求地址,不适合显示给用户
                self.isNetworkFail = true
            } else {
                self.errorMsg = error?.fileSdkMessage ?? ""
            }
        })
    }
    
    /// 取消下载图片
    func cancelFetch(){
        self.fetchTask?.cancel()
        self.fetchTask = nil
        self.loadingTip = nil
        self.thumbFetchTask?.cancel()
        self.thumbFetchTask = nil
    }
    
    /**
     双击事件
     - Parameter center: 双击的位置,放大时以这个位置为中心
     */
    func doubleClick(_ center: CGPoint){
        withAnimation{
            if self.zoomAmount > 1{
                self.zoomAmount = 1
            } else {
                
                // 适合屏幕宽度的倍率
                let screenWidthZoom = self.screenWidth / self.displayW1
                
                // 适合屏幕高度的倍率
                let screenHeightZoom = self.screenHeight / self.displayH1
                
                var zoom = max(screenWidthZoom, screenHeightZoom)
                if screenWidthZoom == screenHeightZoom && screenWidthZoom == 1{//当前照片本身就是屏幕大小的比例
                    zoom = 2
                }
                self.onImagePinch(zoom / self.zoomAmount, center: center, translation: .zero)
            }
            self.fixCropImage()
        }
    }
    
    ///初始化图片显示
    /// - Paramter uiImage 图片数据
    private func initImage(_ uiImage: UIImage){
        self.errorMsg = ""
        self.isNetworkFail = false
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
        if self.fileProperty == nil && FileSdkUtil.cachedPath(self.fm.downloadSource) == nil{//文件属性之前加载失败,重新加载,成功后自动播放
            self.loadProperty()
            return
        }
        if self.isVideoReplay{//强制重新播放
            self.videoPlay()
            return
        }
        if let videoPlayer{//如果播放器仅仅是暂停，直接播放即可
            AudioSessionUtil.exclusive()
            self.videoPlayer?.play()

            //开启播放进度计时器
            self.startVideoTimer()
            self.videoIsPlaying = true
            return
        }
        self.videoPlay()
    }

    /// 停止播放视频,释放音频,让其他App恢复播放
    func stopVideoPlayer(){
        guard let videoPlayer else{
            return
        }
        videoPlayer.pause()
        videoPlayer.replaceCurrentItem(with: nil)
        self.videoPlayer = nil
        AudioSessionUtil.release()
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
        AudioSessionUtil.exclusive()
        self.videoIsPlayed = true//标记视频播放过
        self.isVideoReplay = false
        var currentTime = CMTime.zero//记录当前播放时间，方便切换清晰度之后继续播放
        if let videoPlayer{//获取当前播放时间,接下来接着播放
           if let item = videoPlayer.currentItem{
                currentTime = item.currentTime()
           }

            //切换清晰度时先停掉之前的播放器,否则之前的视频会继续播放,出现多个声音
            videoPlayer.pause()
            videoPlayer.replaceCurrentItem(with: nil)
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
            self.videoIsLoading = false
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
        self.videoIsLoading = true
        Task.detached{ //网络视频应该通过异步任务加载,否则可能导致UI卡顿
            let player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
            self.videoPlayer = player
            asset.loadValuesAsynchronously(forKeys: ["duration"]){
                var error: NSError?
                let status = asset.statusOfValue(forKey: "duration", error: &error)
                if status == .loaded {//视频缓冲完成
                    Task{ @MainActor in
                        
                        //加载期间又切换了清晰度或停止了播放,这个播放器已经不用了
                        guard player === self.videoPlayer else{
                            return
                        }
                        self.videoIsLoading = false
                        self.videoIsPlaying = true
                        player.seek(to: currentTime)
                        player.play()
                        self.startVideoTimer()
                    }
                } else if status == .failed {
                    Task{ @MainActor in
                        guard player === self.videoPlayer else{
                            return
                        }
                        self.videoIsLoading = false
                        self.isVideoReplay = true//再次点击播放时重新加载
                        self.videoIsPlayed = false//恢复显示缩略图
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
    
    /// 手指拖动,图片放大时优先移动图片,到达图片边界之后带动页面移动。超出边界的方向有阻力
    /// - Parameter delta 手指移动的距离
    func onImageDrag(_ delta: CGSize){
        let pageOffset = -CGFloat(self.currentIndex + 1) * self.screenWidth
        let maxImageOffset = max((self.displayW1 * self.zoomAmount - self.screenWidth) / 2, 0)
        
        //页面已经被带动时,反方向拖动要先把页面拖回来
        let oldPageMove = self.hStackOffset - pageOffset
        let width = self.currentOffsetPosition.width + oldPageMove + delta.width
        let imageOffset = min(max(width, -maxImageOffset), maxImageOffset)
        var pageMove = width - imageOffset
        
        //第一张和最后一张没有可以切换的页面
        let isNoPage = (pageMove > 0 && self.currentIndex == 0) || (pageMove < 0 && self.currentIndex == self.fileModels.count - 1)
        if isNoPage && abs(pageMove) > abs(oldPageMove){
            pageMove = oldPageMove + (pageMove - oldPageMove) * self.rubberBandRate(abs(oldPageMove), self.screenWidth)
        }
        self.hStackOffset = pageOffset + pageMove
        
        var height = self.currentOffsetPosition.height
        if self.zoomAmount > 1{//图片放大之后才能上下移动
            let maxHeight = max((self.displayH1 * self.zoomAmount - self.screenHeight) / 2, 0)
            let direction: CGFloat = delta.height > 0 ? 1 : -1
            
            //到达边界之前的距离没有阻力,超出边界的部分有阻力
            let distance = abs(delta.height)
            let free = min(max(maxHeight - height * direction, 0), distance)
            let overflow = max(height * direction - maxHeight, 0)
            height += direction * (free + (distance - free) * self.rubberBandRate(overflow, self.screenHeight))
        }
        self.currentOffsetPosition = CGSize(width: imageOffset, height: height)
    }
    
    /// 超出边界时手指移动和内容移动的比例,超出越多阻力越大
    /// - Parameter overflow 已经超出边界的距离
    /// - Parameter size 屏幕尺寸,内容最多超出这个距离
    private func rubberBandRate(_ overflow: CGFloat, _ size: CGFloat) -> CGFloat{
        let rate = 1 - min(overflow / size, 1)
        return AlbumViewerViewModel.RUBBER_BAND_RATE * rate * rate
    }
    
    /// 拖动结束,决定切换页面、回弹或者惯性滑动
    /// - Parameter velocity 松手时手指的速度
    func onImageDragEnd(_ velocity: CGSize){
        
        //页面被带动时说明图片已经到达边界,不需要惯性滑动
        let isPageMoved = self.hStackOffset != -CGFloat(self.currentIndex + 1) * self.screenWidth
        withAnimation{
            self.fixCropImage(velocity: velocity.width)
        }
        if !isPageMoved{
            self.startInertia(velocity)
        }
    }
    
    /// 开始惯性滑动,图片放大之后才有
    func startInertia(_ velocity: CGSize){
        self.stopInertia()
        if self.zoomAmount <= 1 || hypot(velocity.width, velocity.height) < AlbumViewerViewModel.INERTIA_MIN_VELOCITY{
            return
        }
        self.inertiaVelocity = velocity
        self.inertiaLink = AlbumViewerInertiaLink{ [weak self] in
            self?.stepInertia($0)
        }
    }
    
    /// 停止惯性滑动
    func stopInertia(){
        self.inertiaLink?.invalidate()
        self.inertiaLink = nil
    }
    
    /// 手指按下时停止惯性滑动,正在弹回时要回到边界内
    func stopInertiaByTouch(){
        self.stopInertia()
        withAnimation{
            self.fixCropImage()
        }
    }
    
    /// 惯性滑动一帧
    /// - Parameter time 距离上一帧的时间(秒)
    func stepInertia(_ time: TimeInterval){
        let maxWidth = max((self.displayW1 * self.zoomAmount - self.screenWidth) / 2, 0)
        let maxHeight = max((self.displayH1 * self.zoomAmount - self.screenHeight) / 2, 0)
        let x = self.stepInertia(self.currentOffsetPosition.width, self.inertiaVelocity.width, maxWidth, time)
        let y = self.stepInertia(self.currentOffsetPosition.height, self.inertiaVelocity.height, maxHeight, time)
        self.currentOffsetPosition = CGSize(width: x.offset, height: y.offset)
        self.inertiaVelocity = CGSize(width: x.velocity, height: y.velocity)
        if x.velocity == 0 && y.velocity == 0{
            self.stopInertia()
        }
    }
    
    /// 计算一个方向的惯性滑动。边界内速度逐渐衰减,超出边界后由弹簧拉回。这个方向结束时速度为0
    private func stepInertia(_ offset: CGFloat, _ velocity: CGFloat, _ maxOffset: CGFloat, _ time: TimeInterval) -> (offset: CGFloat, velocity: CGFloat){
        let overflow = offset - min(max(offset, -maxOffset), maxOffset)
        if overflow == 0{
            let newVelocity = velocity * CGFloat(pow(AlbumViewerViewModel.INERTIA_DECAY, time * 1000))
            if abs(newVelocity) < AlbumViewerViewModel.INERTIA_STOP_VELOCITY{
                return (offset, 0)
            }
            return (offset + newVelocity * CGFloat(time), newVelocity)
        }
        let acceleration = -AlbumViewerViewModel.BOUNCE_STIFFNESS * overflow - AlbumViewerViewModel.BOUNCE_DAMPING * velocity
        let newVelocity = velocity + acceleration * CGFloat(time)
        let newOffset = offset + newVelocity * CGFloat(time)
        let bound = overflow > 0 ? maxOffset : -maxOffset
        let isBack = overflow > 0 ? newOffset <= bound : newOffset >= bound
        if isBack || (abs(overflow) < 0.5 && abs(newVelocity) < AlbumViewerViewModel.INERTIA_STOP_VELOCITY){
            return (bound, 0)
        }
        return (newOffset, newVelocity)
    }
    
    /// 双指缩放,以双指中心点为中心缩放,同时跟随中心点移动
    /// - Parameter scale 相对上一次的缩放比例
    /// - Parameter center 双指中心点在屏幕上的位置
    /// - Parameter translation 相对上一次中心点移动的距离
    func onImagePinch(_ scale: CGFloat, center: CGPoint, translation: CGSize){
        let centerX = center.x - self.screenWidth / 2
        let centerY = center.y - self.screenHeight / 2
        self.zoomAmount *= scale
        
        //先跟随手指移动,再缩放,缩放之后中心点下的图片内容位置不变
        let width = self.currentOffsetPosition.width + translation.width
        let height = self.currentOffsetPosition.height + translation.height
        self.currentOffsetPosition = CGSize(
            width: centerX - (centerX - width) * scale,
            height: centerY - (centerY - height) * scale
        )
    }
    
    /// 双指缩放结束,超出范围时回弹
    func onImagePinchEnd(_ center: CGPoint){
        withAnimation{
            if self.zoomAmount > 8.0{//放大倍数不能大于8倍
                self.onImagePinch(8.0 / self.zoomAmount, center: center, translation: .zero)
            }
            self.fixCropImage()
        }
    }
    
    /**
     * 修复裁剪范围
     */
    func fixCropImage() {
        self.fixCropImage(velocity: 0)
    }
    
    /**
     * 修复裁剪范围
     * - Parameter velocity 松手时手指的水平速度,向右为正
     */
    func fixCropImage(velocity: CGFloat) {
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
        
        self.fixPageViewPosition(velocity: velocity)
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
        self.downloadTip = ""

        //添加下载,如果文件在缓存中,则将缓存标记为永久保存
        do {
            try FileSdkUtil.download(self.fm.downloadSource)
        } catch {
            self.downloadFinish(error.fileSdkMessage)
            return
        }
        if FileSdkUtil.cachedPath(self.fm.downloadSource) != nil{// 文件已经被下载
            self.downloadFinish()
            return
        }
    }

    /// SDK事件,更新当前文件的下载进度
    func onFileSdkEvent(_ event: Event){
        guard self.isDownloading, let id = FileSdkUtil.cacheId(self.fm.downloadSource) else{
            return
        }
        switch event{
        case let .progress(eventId, _, size, downloaded, _):
            if eventId == id, let size, size > 0{
                self.downloadTip = "\(Int(Double(downloaded) / Double(size) * 100))%"
            }
        case let .stateChanged(eventId, _, state, error):
            if eventId != id{
                return
            }
            if state == .finish{
                self.downloadFinish()
            } else if state == .error{
                self.downloadFinish(FileSdkUtil.friendlyError(error ?? "下载失败"))
            }
        default:
            break
        }
    }

    /// 文件下载完成后的操作
    /// - Parameter errorMsg: 下载失败时的错误信息
    func downloadFinish(_ errorMsg: String = ""){
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
            Toast.show("下载失败:\(errorMsg)")
        }

        //取消下载模式
        self.downloadTip = nil
        self.isSaveToAlbum = false
    }
    
    ///  加载原图点击事件
    func onLoadOriginalClick(){
        
        //请求加载原图
        self.loadOriginal()
    }
    
    
    deinit{
        print("-->AlbumViewerViewModel.deinit")
    }
}

/// 惯性滑动的逐帧回调,CADisplayLink的target必须是NSObject,而且它会强引用target,用完要调用invalidate
private final class AlbumViewerInertiaLink: NSObject {
    
    private let onFrame: (_ time: TimeInterval) -> Void
    
    private var link: CADisplayLink?
    
    init(onFrame: @escaping (_ time: TimeInterval) -> Void) {
        self.onFrame = onFrame
        super.init()
        let link = CADisplayLink(target: self, selector: #selector(self.onLink))
        link.add(to: .main, forMode: .common)
        self.link = link
    }
    
    @objc private func onLink(_ link: CADisplayLink){
        self.onFrame(link.targetTimestamp - link.timestamp)
    }
    
    func invalidate(){
        self.link?.invalidate()
        self.link = nil
    }
}
