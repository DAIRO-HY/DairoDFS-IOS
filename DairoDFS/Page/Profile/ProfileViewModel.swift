//
//  ProfileViewModel.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/02.
//

import SwiftUI
import DairoUI_IOS

class ProfileViewModel: ObservableObject {
    
    ///上传头像的最大边长,服务器最终会裁剪成256×256
    private static let AVATAR_MAX_SIZE: CGFloat = 1024
    
    /// 当前登录的用户信息
    @Published var user = SettingStore.user
    
    /// 昵称
    @Published var nickname = SettingStore.user?.nickname ?? ""
    
    /// 是否有头像
    var hasAvatar: Bool {
        return self.user?.avatar?.isEmpty == false
    }
    
    /// 保存昵称点击事件
    func onSaveNicknameClick(){
        self.nickname = self.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        MineApi.nickname(nickname: self.nickname).send {
            Toast.show("保存成功")
            self.loadUser()
        }
    }
    
    /// 选择头像之后上传
    func onAvatarPick(_ image: UIImage){
        guard let jpeg = ProfileViewModel.toJpeg(image) else{
            Toast.show("读取图片失败")
            return
        }
        MineApi.uploadAvatar(jpeg: jpeg).send {
            self.loadUser()
        }
    }
    
    /// 删除头像点击事件
    func onDeleteAvatarClick(){
        MineApi.deleteAvatar().send {
            self.loadUser()
        }
    }
    
    /// 刷新用户信息
    private func loadUser(){
        MineApi.info().send{
            SettingStore.user = $0
            self.user = $0
        }
    }
    
    /// 缩小图片并转换成jpg
    private static func toJpeg(_ image: UIImage) -> Data? {
        let scale = min(1, ProfileViewModel.AVATAR_MAX_SIZE / max(image.size.width, image.size.height))
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).jpegData(withCompressionQuality: 0.9){ _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
