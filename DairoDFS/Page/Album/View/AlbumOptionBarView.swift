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
        HStack{
            self.optionBtn(self.fileVm.isSelectMode ? "xmark" : "ellipsis"){
                self.fileVm.isSelectMode = !self.fileVm.isSelectMode
                self.fileVm.clearSelected()
            }
            Spacer().frame(width: 10)
        }
    }
    
    private func optionBtn(_ icon: String, action: @escaping () -> Void) -> some View{
        return HStack{
            Button(action: action){
                Image(systemName: icon).foregroundColor(Color.gl.white)
                    .frame(width: 36,height: 36)
                    .animation(nil, value: self.fileVm.isSelectMode)//禁止过渡动画
            }
            .background(Color.primary)
            .clipShape(.circle)
            .buttonStyle(.row)
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
