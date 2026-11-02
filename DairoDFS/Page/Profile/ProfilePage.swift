//
//  ProfilePage.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/02.
//

import SwiftUI
import DairoUI_IOS

struct ProfilePage: View {
    
    @StateObject private var vm = ProfileViewModel()
    
    /// 显示头像操作菜单
    @State private var showAvatarMenu = false
    
    /// 显示图片选择器
    @State private var showImagePicker = false
    
    var body: some View {
        SettingStack(embedInNavigationStack: false) {
            SettingPage(title:"个人资料") {
                SettingCustomView {
                    Button(action:{
                        self.showAvatarMenu = true
                    }){
                        VStack(spacing: 8){
                            UserAvatar(self.vm.user, size: 80)
                            Text("更换头像").font(.footnote).foregroundColor(.secondary)
                        }
                        .padding(32)
                    }.frame(maxWidth: .infinity)
                }
                SettingGroup{
                    SettingTextField(title: "昵称", text: self.$vm.nickname, placeholder: self.vm.user?.name ?? "")
                }
                SettingGroup{
                    SettingButtonSingle("保存昵称",action: self.vm.onSaveNicknameClick)
                }
            }
        }
        .confirmationDialog("更换头像", isPresented: self.$showAvatarMenu, titleVisibility: .visible) {
            Button("从相册选择") {
                self.showImagePicker = true
            }
            if self.vm.hasAvatar{
                Button("删除头像", role: .destructive) {
                    self.vm.onDeleteAvatarClick()
                }
            }
            Button("取消", role: .cancel) { }
        }
        .sheet(isPresented: self.$showImagePicker) {
            SingleImagePicker(isPresented: self.$showImagePicker, onPick: self.vm.onAvatarPick)
        }
    }
}

#Preview {
    ProfilePage()
}
