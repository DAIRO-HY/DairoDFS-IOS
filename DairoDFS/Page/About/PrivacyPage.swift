//
//  PrivacyPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/19.
//

import SwiftUI

/// 隐私政策,内容和Document/PrivacyPolicy.md的中文部分一致,修改时两边一起改
struct PrivacyPage: View {

    /// 生效日期
    private static let EFFECTIVE_DATE = "2026年11月7日"

    /// 每一节的标题和内容
    private static let SECTIONS: [(title: String, content: String)] = [
        ("说明", """
        DairoDFS（以下简称"本App"）是一款开源的文件管理客户端，用来连接你自己部署的DairoDFS服务器。本政策说明本App会处理哪些信息，以及这些信息去了哪里。
        """),
        ("我们不收集你的任何信息", """
        本App的开发者不运营任何收集用户数据的服务器。本App：
        · 不收集、不上传、不出售任何个人信息给开发者或第三方；
        · 不包含广告，不包含任何第三方统计、分析或追踪SDK；
        · 不追踪你在其他App或网站上的活动。
        """),
        ("你的数据只发送到你自己指定的服务器", """
        使用本App时，你需要填写服务器地址、用户名和密码。本App只会和你填写的这台服务器通信，传输的内容包括：
        · 登录时的用户名和密码，用来换取登录票据；
        · 你浏览、上传、下载、移动、删除的文件和文件夹；
        · 你主动选择上传的照片和视频；
        · 一个由设备标识计算出的设备ID，供服务器区分登录设备。
        这台服务器由你自己或你的服务器管理员部署和管理，数据如何存储和保护，由服务器的管理者负责。本App的开发者无法访问这些数据。
        """),
        ("保存在你设备上的信息", """
        为了让App正常使用，以下信息只保存在你的设备上：
        · 服务器地址、用户名和登录票据（不保存密码）；
        · 主题、功能模式、下载数量等设置；
        · 已浏览过的图片、视频、音乐等文件的缓存，以及你主动下载的文件。
        你可以在App的"下载管理"中清理缓存。删除本App会同时删除以上所有信息。
        """),
        ("App使用的权限", """
        · 照片（读取）：用来显示系统相册里的照片和视频，把你选择的内容上传到你的服务器，并在你确认后删除已上传的照片。
        · 照片（添加）：用来把服务器上的照片和视频保存到系统相册。
        · 本地网络：用来连接你部署在局域网内的服务器。
        以上权限都只在你使用对应功能时才会请求，你可以随时在系统"设置"中关闭。
        """),
        ("儿童隐私", """
        本App不面向儿童收集任何信息。
        """),
        ("政策更新", """
        如果本政策有变化，我们会更新本页面并修改上方的生效日期。
        """),
        ("联系我们", """
        如果你对本政策有任何疑问，请发送邮件到 hy.zhoulq@gmail.com，或在GitHub上提交Issue：https://github.com/DAIRO-HY/DairoDFS-IOS/issues
        """)
    ]

    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 20){
                Text("生效日期：" + PrivacyPage.EFFECTIVE_DATE)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                ForEach(PrivacyPage.SECTIONS, id: \.title){ section in
                    VStack(alignment: .leading, spacing: 8){
                        Text(section.title).font(.headline)
                        Text(section.content)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding()
            .frame(maxWidth: 700, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("隐私政策")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView{
        PrivacyPage()
    }
}
