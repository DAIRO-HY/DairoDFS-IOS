//
//  AlbumPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/04.
//

import SwiftUI
import DairoUI_IOS

struct AlbumPage: View {
    
    /// 页面重新加载标识
    static let ALBUM_PAGE_RELOAD_DATA = "ALBUM_PAGE_RELOAD_DATA"
    
    @StateObject var vm = AlbumViewModel()
    
    var body: some View {
        NavigationView{
            ZStack{
                
                //图片上传页面
                NavigationLink(destination: SystemAlbumPage(mode: .album), isActive: self.$vm.showAlbunSyncPage){
                    EmptyView()
                }
                
                //撑开内部控件,使功能按钮初始化时就显示在右上角
//                Spacer().frame(maxWidth: .infinity, maxHeight: .infinity)
                AlbumGridView().environmentObject(self.vm)
                AlbumOptionBarView().environmentObject(self.vm)
                AlbumOptionView().environmentObject(self.vm)
            }
            .navigationTitle("相册")
            .navigationBarHidden(true)
            
            //刷新数据通知
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name(AlbumPage.ALBUM_PAGE_RELOAD_DATA))){ _ in
                self.vm.isNeedReloadData = true
            }
            .onChange(of: self.vm.showViewerPage){
                if $0{
                    self.vm.isNeedReloadData = false
                    return
                }
                
                //当相册查看页面关闭时,如果需要更新数据
                if self.vm.isNeedReloadData{
                    
                    //删除数据缓存
                    LocalObjectUtil.delete(AlbumViewModel.LOCAL_OBJ_KEY_ALBUM)
                    self.vm.loadData()
                }
            }.onChange(of: self.vm.showAlbunSyncPage){
                if $0{
                    self.vm.isNeedReloadData = false
                    return
                }
                
                //当相册查看页面关闭时,如果需要更新数据
                if self.vm.isNeedReloadData{
                    
                    //删除数据缓存
                    LocalObjectUtil.delete(AlbumViewModel.LOCAL_OBJ_KEY_ALBUM)
                    self.vm.loadData()
                }
            }
            .fullScreenCover(isPresented: self.$vm.showViewerPage) {
                let viewModel = self.vm.getAlbumViewerViewModel()
                RootView{
                    AlbumViewerPage(viewModel, self.$vm.showViewerPage)
                }
            }
        }
    }
}

#Preview {
    AlbumPage()
}
