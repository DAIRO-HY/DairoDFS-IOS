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
    
    ///主题色,添加按钮使用。深色模式下也要看得清,不随系统变化
    private static let THEME_COLOR = Color(red: 0.008, green: 0.616, blue: 0.58)
    
    ///当前选中的页面标记
    private let pageTag: TabPage
    init(_ pageTag: TabPage) {
        self.pageTag = pageTag
    }
    
    var body: some View {
        ZStack{
            HStack{
                self.tabBtn("文件", "folder.fill", isSelected: self.pageTag == .FILE_PAGE){
                    FilePage().relaunch()
                }
                Spacer().frame(width: 60)
                self.tabBtn("我的", "person.fill", isSelected: self.pageTag == .MINE_PAGE){
                    MinePage().relaunch()
                }
            }
            
            //添加按钮
            Button(action: {
                
                //显示添加视图
                NotificationCenter.default.post(name: Notification.Name(FileAddView.FILE_ADD_VIEW_SHOW_FLAG), object: nil)
            }){
                Image(systemName: "plus")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .liquidGlassBackground(HomeTabView.THEME_COLOR, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 4)
        .frame(height: 60)
        .liquidGlassBackground(in: Capsule())
        .frame(maxWidth: 420)
        .padding(.horizontal)
        .padding(.bottom, 4)
    }
    
    private func tabBtn(_ text: String, _ icon: String, isSelected: Bool, action: @escaping ()->Void) -> some View{
        Button(action: {
            if !isSelected{//不能用disabled,会让选中的按钮变灰
                action()
            }
        }){
            let label = VStack(spacing: 3){
                Image(systemName: icon).font(.title3)
                Text(text).font(.footnote)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .contentShape(Capsule())
            if isSelected{
                
                //玻璃叠在玻璃上几乎看不出来,加一点颜色
                label.liquidGlassBackground(Color.primary.opacity(0.12), in: Capsule())
            } else {
                label
            }
        }
        .foregroundColor(.primary)
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack{
        Spacer()
        HomeTabView(.FILE_PAGE)
    }
}
