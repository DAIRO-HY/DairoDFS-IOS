//
//  AlbumOptionBarView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI

struct AlbumOptionBarView: View {
    @EnvironmentObject var fileVm: AlbumViewModel
    var body: some View {
        VStack{
            HStack{
                Spacer()
                self.optionBtn(self.fileVm.isSelectMode ? "xmark" : "ellipsis"){
                    self.fileVm.isSelectMode = !self.fileVm.isSelectMode
                    self.fileVm.clearSelected()
                }
            }.padding()
            Spacer()
        }
    }
    
    private func optionBtn(_ icon: String, action: @escaping () -> Void) -> some View{
        return HStack{
            Button(action: action){
                Image(systemName: icon).foregroundColor(.primary)
                    .frame(width: 36,height: 36)
                    .animation(nil, value: self.fileVm.isSelectMode)//禁止过渡动画
                    .liquidGlassBackground(in: Circle(), interactive: true)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ViewPreview()
}

private struct ViewPreview: View {
    @StateObject var fileVm = AlbumViewModel()
    var body: some View {
        AlbumOptionBarView().environmentObject(self.fileVm)
    }
}
