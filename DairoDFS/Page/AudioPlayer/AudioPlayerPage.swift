//
//  AudioPlayerPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/03.
//

import SwiftUI
import DairoUI_IOS

/**
 音频播放页面,App进入后台后继续播放,关闭页面时停止播放
 */
struct AudioPlayerPage: View {
    
    @StateObject private var vm: AudioPlayerViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    init(_ fm: FileModel) {
        self._vm = StateObject(wrappedValue: AudioPlayerViewModel(fm))
    }
    
    var body: some View {
        VStack(spacing: 24){
            HStack{
                Spacer()
                Button("关闭"){
                    self.dismiss()
                }
            }
            Spacer()
            Image(systemName: "music.note")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 96, height: 96)
                .foregroundColor(.secondary)
            Text(self.vm.name)
                .font(.headline)
                .multilineTextAlignment(.center)
            if let errorMsg = self.vm.errorMsg{
                Text(errorMsg).font(.footnote).foregroundColor(.red)
            }
            VStack(spacing: 4){
                Slider(value: Binding(get: { min(self.vm.currentTime, self.vm.duration) }, set: { self.vm.currentTime = $0 }),
                       in: 0...max(self.vm.duration, 1)){ isEditing in
                    self.vm.isDragging = isEditing
                    if !isEditing{
                        self.vm.seek(self.vm.currentTime)
                    }
                }
                .disabled(self.vm.duration == 0)
                HStack{
                    Text(AudioPlayerPage.format(self.vm.currentTime))
                    Spacer()
                    Text(AudioPlayerPage.format(self.vm.duration))
                }
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            Button(action: self.vm.onPlayClick){
                Image(systemName: self.vm.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 64, height: 64)
            }
            .accessibilityLabel(self.vm.isPlaying ? "暂停" : "播放")
            .disabled(self.vm.errorMsg != nil)
            Spacer()
        }
        .padding()
        .onDisappear(perform: self.vm.stop)
    }
    
    /// 格式化播放时间
    private static func format(_ seconds: Double) -> String {
        return ((seconds.isFinite ? seconds : 0) * 1000).timeFormat
    }
}
