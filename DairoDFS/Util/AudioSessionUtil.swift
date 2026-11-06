//
//  AudioSessionUtil.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/06.
//

import AVFoundation

/**
 统一管理音频会话,App启动时不占用音频,避免打断其他App正在播放的音乐
 */
enum AudioSessionUtil {

    /// 实况照片是否播放声音,App每次启动时默认关闭,打开之后在App运行期间一直保持
    static var isDliveSoundOn = false

    /// 播放歌曲和视频时独占音频,其他App的声音会被暂停,静音模式下也有声音,支持后台播放
    static func exclusive() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [])
        try? session.setActive(true)
    }

    /// 播放实况照片时使用
    /// 打开声音时压低其他App的音量,关闭声音时和其他App的声音混合,不会打断正在播放的音乐
    static func dlive() {
        let session = AVAudioSession.sharedInstance()
        if self.isDliveSoundOn {
            try? session.setCategory(.playback, mode: .default, options: [.duckOthers])
        } else {
            try? session.setCategory(.ambient, mode: .default, options: [])
        }
        try? session.setActive(true)
    }

    /// 播放结束后释放音频,通知其他App可以恢复播放或者恢复音量
    static func release() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
