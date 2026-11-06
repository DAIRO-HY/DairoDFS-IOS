//
//  AlbumModeBarView.swift
//  DairoDFS
//

import SwiftUI

/// 底部切换相册显示方式的按钮
struct AlbumModeBarView: View {
    
    @EnvironmentObject var vm: AlbumViewModel
    
    var body: some View {
        VStack{
            Spacer()
            HStack(spacing: 8){
                self.getButton("按年", .year)
                self.getButton("按月", .month)
                self.getButton("全部", .all)
            }
            .padding(.bottom, 8)
        }
    }
    
    private func getButton(_ label: String, _ mode: AlbumViewMode) -> some View{
        Button(action: {
            self.vm.viewMode = mode
        }){
            let text = Text(label)
                .font(.subheadline)
                .fontWeight(self.vm.viewMode == mode ? .semibold : .regular)
                .foregroundColor(.primary)
                .frame(width: 72, height: 40)
            if self.vm.viewMode == mode{
                
                //选中的按钮加一点颜色
                text.liquidGlassBackground(Color.primary.opacity(0.12), in: Capsule())
            } else {
                text.liquidGlassBackground(in: Capsule(), interactive: true)
            }
        }
        .buttonStyle(.plain)
    }
}
