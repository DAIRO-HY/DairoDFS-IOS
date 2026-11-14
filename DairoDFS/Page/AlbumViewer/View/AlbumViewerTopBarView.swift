//
//  AlbumViewerTopBarView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI
import DairoUI_IOS

/// 顶部视图
struct AlbumViewerTopBarView: View {
    
    @Binding var showViewerPage: Bool
    
    @EnvironmentObject var vm: AlbumViewerViewModel
    var body: some View {
        VStack(spacing: 0){
            Spacer().frame(height: 60)
            HStack{
                Button(action: {
                    self.showViewerPage = false
                }){
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                        .liquidGlassBackground(in: Circle(), interactive: true)
                }
                .padding(.leading, 8)
                Spacer()
                if let fileTime = self.vm.fileTime{
                    Text(fileTime)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 14)
                        .frame(height: 40)
                        .liquidGlassBackground(in: Capsule())
                }
                Spacer()
                
                //和返回按钮同宽,使时间水平居中
                Color.clear.frame(width: 40, height: 40).padding(.trailing, 8)
            }
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
}
