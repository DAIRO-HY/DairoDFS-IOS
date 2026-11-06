//
//  AudioPlayerViewModel.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/03.
//

import AVFoundation
import Combine
import MediaPlayer
import DairoUI_IOS

class AudioPlayerViewModel: ObservableObject {
    
    /// 文件名
    let name: String
    
    /// 是否正在播放
    @Published var isPlaying = false
    
    /// 当前播放位置(秒)
    @Published var currentTime = 0.0
    
    /// 音频总时长(秒),还没加载出来时为0
    @Published var duration = 0.0
    
    /// 加载失败时的提示
    @Published var errorMsg: String?
    
    /// 是否正在拖动进度条,拖动时不更新播放位置
    var isDragging = false
    
    private var player: AVPlayer?
    
    private var timeObserver: Any?
    
    private var cancellables = Set<AnyCancellable>()
    
    private var remoteCommandTargets = [(MPRemoteCommand, Any)]()
    
    init(_ fm: FileModel) {
        self.name = fm.name
        let source = fm.downloadSource
        let url = FileSdkUtil.cachedPath(source).map{ URL(fileURLWithPath: $0) } ?? FileSdkUtil.open(source)
        guard let url else{
            self.errorMsg = "音频加载失败"
            return
        }
        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        self.player = player
        self.observe(player, item)
        self.setupRemoteCommands()
        AudioSessionUtil.exclusive()
        player.play()
    }
    
    /// 监听播放状态
    private func observe(_ player: AVPlayer, _ item: AVPlayerItem){
        self.timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main){ [weak self] time in
            guard let self, !self.isDragging else{
                return
            }
            self.currentTime = time.seconds
        }
        
        //来电等情况系统会暂停播放,这里以播放器的实际状态为准
        player.publisher(for: \.timeControlStatus).receive(on: DispatchQueue.main).sink{ [weak self] status in
            self?.isPlaying = status != .paused
            self?.updateNowPlaying()
        }.store(in: &self.cancellables)
        item.publisher(for: \.status).receive(on: DispatchQueue.main).sink{ [weak self] status in
            if status == .failed{
                self?.errorMsg = "音频加载失败,请检查网络或访问权限"
            }
        }.store(in: &self.cancellables)
        item.publisher(for: \.duration).receive(on: DispatchQueue.main).sink{ [weak self] duration in
            if duration.isNumeric{
                self?.duration = duration.seconds
                self?.updateNowPlaying()
            }
        }.store(in: &self.cancellables)
        
        //播放结束后回到开头
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: item).receive(on: DispatchQueue.main).sink{ [weak self] _ in
            self?.seek(0)
        }.store(in: &self.cancellables)
    }
    
    /// 设置锁屏和控制中心的播放控制
    private func setupRemoteCommands(){
        let center = MPRemoteCommandCenter.shared()
        let add = { [weak self] (command: MPRemoteCommand, handler: @escaping (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus) in
            self?.remoteCommandTargets.append((command, command.addTarget(handler: handler)))
        }
        add(center.playCommand){ [weak self] _ in
            self?.player?.play()
            return .success
        }
        add(center.pauseCommand){ [weak self] _ in
            self?.player?.pause()
            return .success
        }
        add(center.togglePlayPauseCommand){ [weak self] _ in
            self?.onPlayClick()
            return .success
        }
        add(center.changePlaybackPositionCommand){ [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else{
                return .commandFailed
            }
            self?.seek(event.positionTime)
            return .success
        }
    }
    
    /// 更新锁屏和控制中心显示的播放信息
    private func updateNowPlaying(){
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: self.name,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: self.player?.currentTime().seconds ?? 0,
            MPNowPlayingInfoPropertyPlaybackRate: self.isPlaying ? 1.0 : 0.0
        ]
        if self.duration > 0{
            info[MPMediaItemPropertyPlaybackDuration] = self.duration
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    /// 播放/暂停按钮点击事件
    func onPlayClick(){
        guard let player = self.player else{
            return
        }
        if player.timeControlStatus == .paused{
            player.play()
        } else {
            player.pause()
        }
    }
    
    /// 跳转到指定位置
    func seek(_ seconds: Double){
        self.currentTime = seconds
        self.player?.seek(to: CMTime(seconds: seconds, preferredTimescale: 600)){ [weak self] _ in
            self?.updateNowPlaying()
        }
    }
    
    /// 关闭播放页面时停止播放
    func stop(){
        self.player?.pause()
        if let timeObserver = self.timeObserver{
            self.player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        self.cancellables.removeAll()
        self.remoteCommandTargets.forEach{ $0.0.removeTarget($0.1) }
        self.remoteCommandTargets.removeAll()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        self.player = nil
        AudioSessionUtil.release()
    }
}
