import SwiftUI
import DairoUI_IOS

/// 标签视图
struct AlbumViewerTagView: View {
    @EnvironmentObject var vm: AlbumViewerViewModel
    var body: some View {
        VStack{
            Spacer().frame(height: 85)
            HStack(alignment: .top, spacing: 5){
                ForEach(self.vm.tags, id: \.self){
                    Text($0)
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(.black.opacity(0.6))
                        .cornerRadius(100)         // 圆角半径
                }
                Spacer()
            }.padding()
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
