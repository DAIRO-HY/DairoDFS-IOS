import SwiftUI
import DairoUI_IOS

/// 标签视图
struct AlbumViewerTagView: View {
    @EnvironmentObject var vm: AlbumViewerViewModel
    var body: some View {
        VStack{
            Spacer().frame(height: 92)
            HStack(alignment: .top, spacing: 5){
                ForEach(self.vm.tags, id: \.self){
                    Text($0)
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(.black.opacity(0.6))
                        .cornerRadius(100)         // 圆角半径
                }
                if self.vm.fm.isDlive{
                    AlbumViewerDliveSoundButton(self.vm.dliveVm)
                }
                Spacer()
            }.padding()
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 实况照片的声音开关,样式和标签一样
private struct AlbumViewerDliveSoundButton: View {
    
    @ObservedObject private var dliveVm: AlbumViewerDliveViewModel
    
    init(_ dliveVm: AlbumViewerDliveViewModel) {
        self.dliveVm = dliveVm
    }
    
    var body: some View {
        Button(action: self.dliveVm.onSoundClick){
            Image(systemName: self.dliveVm.isSoundOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                .font(.footnote)
                .foregroundColor(.white)
                .padding(5)
                .background(.black.opacity(0.6))
                .cornerRadius(100)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(self.dliveVm.isSoundOn ? "关闭实况声音" : "打开实况声音")
    }
}
