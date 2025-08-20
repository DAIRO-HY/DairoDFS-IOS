//
//  FileOptionBarView.swift
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
                    ZStack{
                        Image(systemName: "chevron.left")
                            .resizable()
                            .foregroundColor(Color.gl.black)
                            .frame(width: 11, height: 20)
                            .shadow(color: Color.gl.white, radius: 3, x: 2, y: 2)
                    }
                    .frame(width: 40, height: 40)
                }
                Spacer()
            }
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
}
