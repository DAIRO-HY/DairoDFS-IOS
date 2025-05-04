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
//        FileOptionBarView().environmentObject(self.fileVm)
        AlbumGridView().environmentObject(self.fileVm)
//        FileOptionView().environmentObject(self.fileVm)
    }
}

#Preview {
    AlbumPage()
}
