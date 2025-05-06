//
//  AlbumPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/04.
//

import SwiftUI

struct AlbumPage: View {
    
    @StateObject var fileVm = AlbumViewModel()
    
    var body: some View {
        NavigationView{
            ZStack(alignment: .topTrailing){
                
                //撑开内部控件,使功能按钮初始化时就显示在右上角
                Spacer().frame(maxWidth: .infinity, maxHeight: .infinity)
                AlbumGridView().environmentObject(self.fileVm)
                AlbumOptionBarView().environmentObject(self.fileVm)
            }
            .navigationTitle("相册")
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    AlbumPage()
}
