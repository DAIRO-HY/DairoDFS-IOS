//
//  FileOptionBarView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI

struct AlbumOptionBarView: View {
    @EnvironmentObject var fileVm: FileViewModel
    var body: some View {
        HStack{
            Spacer().frame(width: 10)
            self.optionBtn("arrow.left"){
                
            }
            self.optionBtn("house.fill"){//加载首页数据
                self.fileVm.loadSubFile("")
            }
            Text("sdfs").frame(maxWidth: .infinity)
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
            }
            .frame(width: 36,height: 36)
            .background(Color.primary)
            .clipShape(.circle)
            .buttonStyle(.row)
        }
    }
}

#Preview {
    FileOptionBarView()
}
