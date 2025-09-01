//
//  HomePage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI
 
//tab页面标记
enum TabPage{
    case FILE_PAGE//文件页面
    case MINE_PAGE//我的页面
}

struct HomeTabView: View {
    
    ///非选中状态透明度
    private static let DISABLED_OPACITY = 0.6
    
    ///当前选中的页面标记
    private let pageTag: TabPage
    
    //跳转相册同步班页面
    @State private var showAlbunSyncPage = false
    init(_ pageTag: TabPage) {
        self.pageTag = pageTag
    }
    
    //系统背景颜色
    @Environment(\.settingBackgroundColor) var settingBackgroundColor
    var body: some View {
        ZStack{
            
            //图片预览页面
            NavigationLink(destination: SystemAlbumPage(), isActive: self.$showAlbunSyncPage){
                EmptyView()
            }
            HStack{
                self.tabBtn("文件", "folder.fill", .white){
                    FilePage().relaunch()
                }
                .opacity(self.pageTag == .FILE_PAGE ? 1 : HomeTabView.DISABLED_OPACITY)
                .disabled(self.pageTag == .FILE_PAGE)
                Spacer().frame(width: 60)
                self.tabBtn("我的", "person.fill", .white){
                    MinePage().relaunch()
                }
                .opacity(self.pageTag == .MINE_PAGE ? 1 : HomeTabView.DISABLED_OPACITY)
                .disabled(self.pageTag == .MINE_PAGE)
            }
            
            //添加按钮
            Button(action: {
                
                //显示添加视图
                NotificationCenter.default.post(name: Notification.Name(FileAddView.FILE_ADD_VIEW_SHOW_FLAG), object: nil)
            }){
                ZStack{
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                }.padding(.all, 7)
            }
            .background(Color.gl.bgPrimary)
            .clipShape(.circle)
            .buttonStyle(.row)
            .offset(y: -7)
        }
        .frame(height: 50)
        .background(Color.gl.bgPrimary)
    }
    
    private func tabBtn(_ text: String, _ icon: String, _ color: Color, action: @escaping ()->Void) -> some View{
        Button(action: action){
            VStack{
                Image(systemName: icon).font(.title3)
                Spacer().frame(height: 3)
                Text(text).font(.footnote)
            }
            .frame(maxWidth: .infinity)
        }
        .foregroundColor(color)
        .buttonStyle(.row)
    }
}

#Preview {
    VStack{
        Spacer()
        HomeTabView(.FILE_PAGE)
    }
}
