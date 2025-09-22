//
//  ImageViewerPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/05.
//

import SwiftUI
import DairoUI_IOS
import _AVKit_SwiftUI

class AlbumViewerDliveViewModel: ObservableObject{
    
    /// 下载进度信息
    @Published var progress = ""
    
    ///是否显示
    @Published var isShow = false
    
    var fm: FileModel?
    
    // 实况照片视频播放器
    @Published var dlivePlayer: AVPlayer?
    
    func setFm(_ fm: FileModel){
        self.isShow = true
        self.fm = fm
        self.load()
    }
    
    func load(){
        let localId = "\(self.fm!.id)-dlive-video"
        if let path = DownloadManager.getDownloadedPath(localId){//如果视频文件已经生成
            self.dlivePlayer = AVPlayer(url: URL(fileURLWithPath:  path))
            self.dlivePlayer?.play()
            Task{@MainActor in
                await Task.sleep(3_000_000_000)
                self.dlivePlayer?.pause()
                self.dlivePlayer?.replaceCurrentItem(with: nil)
                self.dlivePlayer = nil
                self.isShow = false
            }
            return
        }
        if let path = DownloadManager.getDownloadedPath(self.fm!.downloadId){//如果文件已经下载
            let dliveInfo = DliveUtil.getInfo(path)
            DownloadManager.addFile(id: localId, name: self.fm!.name + "." + dliveInfo.videoExt, data: dliveInfo.videoData, saveType: 0)
            self.load()
            return
        }
            
        //优先加载下载好的预览视频
        if let path = DownloadManager.getDownloadedPath(self.fm!.dliveVideoPreviewId){
            self.dlivePlayer = AVPlayer(url: URL(fileURLWithPath:  path))
            self.dlivePlayer?.play()
            Task{@MainActor in
                await Task.sleep(3_000_000_000)
                self.dlivePlayer?.pause()
                self.dlivePlayer?.replaceCurrentItem(with: nil)
                self.dlivePlayer = nil
                self.isShow = false
            }
            return
        }
        DownloadManager.cache(self.fm!.dliveVideoPreviewId, self.fm!.dliveVideoPreview)
    }
    
    func clear(){
        self.dlivePlayer?.pause()
        self.dlivePlayer?.replaceCurrentItem(with: nil)
        self.dlivePlayer = nil
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
                //加载原缩略图通知
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name(self.vm.fm!.dliveVideoPreviewId)), perform: self.loadImageNotity)
            }
        }
    }
    
    
    /// 加载图片通知事件
    private func loadImageNotity(npo: NotificationCenter.Publisher.Output){
        let userInfo = npo.userInfo!
        switch userInfo["key"] as! DownloadNotify{
        case .progress:/// 进度回调
            // 进度参数是一个数组,数组内容分别是 总大小,已下载大小,下载速度
            let progress = userInfo["value"] as! [Int64]
            self.vm.progress = String(Int(Float64(progress[1]) / Float64(progress[0]) * 100)) + "%"
        case .pause:
            break
        case .finish:
            guard let error = userInfo["value"] as? Error else{
                
                //刷新视图
                self.vm.load()
                return
            }
            if let error = error as? DownloaderError{
                if case let .error(msg) = error {
                    self.vm.progress = msg
                }
            } else {
                self.vm.progress = error.localizedDescription
            }
        }
    }
}
