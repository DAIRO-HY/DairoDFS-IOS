//
//  AlbumViewerDliveView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/05.
//

import SwiftUI
import DairoUI_IOS
import _AVKit_SwiftUI
import DairoFileSDK

class AlbumViewerDliveViewModel: ObservableObject{
    
    /// 下载进度信息
    @Published var progress = ""
    
    ///是否显示
    @Published var isShow = false
    
    var fm: FileModel?
    
    // 实况照片视频播放器
    @Published var dlivePlayer: AVPlayer?
    
    /// 是否播放声音
    @Published var isSoundOn = AudioSessionUtil.isDliveSoundOn
    
    func setFm(_ fm: FileModel){
        self.isShow = true
        self.fm = fm
        self.load()
    }
    
    /// 当前下载任务
    private var fetchTask: FetchTask?
    
    func load(){
        let fm = self.fm!
        if let path = FileSdkUtil.cachedPath(fm.dliveVideoSource()){//如果视频文件已经生成
            self.play(path)
            return
        }
        if let path = FileSdkUtil.cachedPath(fm.downloadSource){//如果文件已经下载
            let dliveInfo = DliveUtil.getInfo(path)
            if let videoPath = FileSdkUtil.putData(fm.dliveVideoSource(ext: dliveInfo.videoExt), Data(dliveInfo.videoData)){
                self.play(videoPath)
            }
            return
        }
            
        //优先加载下载好的预览视频
        if let path = FileSdkUtil.cachedPath(fm.dliveVideoPreviewSource){
            self.play(path)
            return
        }
        self.fetchTask = FileSdkUtil.fetch(fm.dliveVideoPreviewSource, progress: {
            self.progress = "\($0)%"
        }, finish: { path, error in
            self.fetchTask = nil
            self.progress = error?.fileSdkMessage ?? ""
            if let path{
                self.play(path)
            }
        })
    }
    
    /// 播放视频,3秒之后结束
    private func play(_ path: String){
        AudioSessionUtil.dlive()
        let player = AVPlayer(url: URL(fileURLWithPath:  path))
        player.isMuted = !self.isSoundOn
        self.dlivePlayer = player
        player.play()
        Task{@MainActor in
            await Task.sleep(3_000_000_000)
            if self.dlivePlayer === player{//已经切换到其他照片或者重新播放时不要结束
                self.clear()
            }
        }
    }
    
    /// 声音开关点击事件,打开时重新播放一次
    func onSoundClick(){
        self.isSoundOn.toggle()
        AudioSessionUtil.isDliveSoundOn = self.isSoundOn
        if self.isSoundOn, let fm = self.fm{
            self.clear()
            self.setFm(fm)
        } else if let dlivePlayer{
            dlivePlayer.isMuted = true
            AudioSessionUtil.dlive()
        }
    }
    
    func clear(){
        self.fetchTask?.cancel()
        self.fetchTask = nil
        if let dlivePlayer{
            dlivePlayer.pause()
            dlivePlayer.replaceCurrentItem(with: nil)
            self.dlivePlayer = nil
            AudioSessionUtil.release()
        }
        self.isShow = false
    }
}

struct AlbumViewerDliveView: View {
    
    //    @EnvironmentObject var vm: AlbumViewerViewModel
    
    @ObservedObject private var vm: AlbumViewerDliveViewModel
    init(_ vm: AlbumViewerDliveViewModel){
        self.vm = vm
    }
    
    public var body: some View {
        if self.vm.isShow{
            if let dlivePlayer = self.vm.dlivePlayer{
                VideoPlayer(player: dlivePlayer)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }else{
                
                Text(self.vm.progress)
                    .foregroundColor(.white)
                    .shadow(color: .black,radius: 3, x: 2, y: 2)
            }
        }
    }
}
