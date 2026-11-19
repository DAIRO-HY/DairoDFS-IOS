//
//  AboutPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/19.
//

import SwiftUI
import DairoUI_IOS

/// 关于,版本信息、免责声明、隐私政策
struct AboutPage: View {

    /// 免责声明
    private static let DISCLAIMER = "DairoDFS是一个文件管理客户端，本身不提供任何文件、图片、视频内容。App里浏览、上传和下载的内容全部保存在你自己填写的服务器上，由服务器的管理者负责。请只存储和分享你有权使用的内容，不要用于违法用途。"

    /// 服务器端的GitHub项目地址
    private static let SERVER_GITHUB_URL = "https://github.com/DAIRO-HY/DairoDFS"

    /// 版本名
    private var versionName: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    var body: some View {
        SettingStack(embedInNavigationStack: false) {
            SettingPage(title: "关于") {
                SettingCustomView{
                    VStack(spacing: 8){
                        Image("logo")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .cornerRadius(14)
                        Text("DairoDFS \(self.versionName)").font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                }
                SettingGroup{
                    SettingNavigationLink("隐私政策"){
                        PrivacyPage().anyView
                    }
                }
                SettingGroup(header: "免责声明"){
                    SettingCustomView{
                        Text(AboutPage.DISCLAIMER)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding()
                            //文字不够一行宽时,背景也要和其他分组一样宽
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        //固定显示在屏幕最底部
        .overlay(alignment: .bottom){
            self.githubLink
        }
    }

    /// 服务器端项目地址,点击用浏览器打开
    private var githubLink: some View {
        VStack(spacing: 6){
            Text("服务器端项目地址")
                .font(.footnote)
                .foregroundColor(.secondary)
            if let url = URL(string: AboutPage.SERVER_GITHUB_URL){
                Link(destination: url){
                    Label(AboutPage.SERVER_GITHUB_URL.replacingOccurrences(of: "https://", with: ""), systemImage: "link")
                        .font(.footnote)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

#Preview {
    NavigationView{
        AboutPage()
    }
}
