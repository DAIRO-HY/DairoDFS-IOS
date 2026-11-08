# DairoDFS-IOS

DairoDFS 的 iOS 客户端，用来连接你自己部署的 [DairoDFS](https://github.com/DAIRO-HY/DairoDFS) 服务器，在 iPhone 和 iPad 上管理文件、浏览相册、播放视频和音乐。

<table>
  <tr>
    <td><img src="Document/AppStore截图/iPhone%206.3寸/01-相册.png" width="200"></td>
    <td><img src="Document/AppStore截图/iPhone%206.3寸/03-按月.png" width="200"></td>
    <td><img src="Document/AppStore截图/iPhone%206.3寸/04-查看图片.png" width="200"></td>
    <td><img src="Document/AppStore截图/iPhone%206.3寸/05-视频.png" width="200"></td>
  </tr>
  <tr>
    <td><img src="Document/AppStore截图/iPhone%206.3寸/06-文件.png" width="200"></td>
    <td><img src="Document/AppStore截图/iPhone%206.3寸/08-音乐.png" width="200"></td>
    <td><img src="Document/AppStore截图/iPhone%206.3寸/09-相册深色.png" width="200"></td>
    <td><img src="Document/AppStore截图/iPhone%206.3寸/10-我的.png" width="200"></td>
  </tr>
</table>

# 1. 功能

## 1). 相册模式

- 按时间显示服务器上的照片和视频，可以按年、按月分组浏览；
- 左右滑动查看大图，支持缩放；
- 在线播放视频；
- 把手机相册里的照片和视频上传到服务器，可以在上传后删除手机里的原图；
- 把服务器上的照片和视频保存到手机相册。

## 2). 文件模式

- 浏览服务器上的文件和文件夹；
- 上传、下载、创建文件夹、重命名、复制、移动、删除、查看属性；
- 回收站，可以还原或彻底删除；
- 在线播放音乐，切到后台或锁屏后可以继续播放。

在“我的”页面里可以切换文件模式和相册模式。

## 3). 其他

- 可以登录多个账号，在账号之间切换；
- 支持明亮模式、黑暗模式和跟随系统；
- 支持 iPhone 和 iPad；
- 浏览过的图片和视频会缓存在手机上，再次打开时不用重新下载。

# 2. 使用

1. 先部署 DairoDFS 服务器，安装方法见 [DairoDFS](https://github.com/DAIRO-HY/DairoDFS)。
2. 打开 App，填写服务器地址、用户名和密码登录。服务器地址可以带端口，例如 `192.168.1.100:8031`；没有写 `http://` 或 `https://` 时，App 会自动加上 `http://`。

App 只和你填写的服务器通信，不收集任何个人信息，详见[隐私政策](Document/PrivacyPolicy.md)。

# 3. 编译

## 1). 环境要求

- macOS 和 Xcode；
- 编译 SDK 需要 Rust 环境；
- App 最低支持 iOS 15.6。

## 2). 依赖

App 依赖两个本地的 Swift Package，需要按下面的目录结构把三个仓库放在一起：

```
任意目录/
├── xcode/
│   ├── DairoDFS-IOS/        # 本项目
│   └── DairoUI_IOS/         # 界面组件库
└── java/idea/
    └── DairoDFS/            # 服务器项目，里面的 dairo-file-sdk 是 App 用到的 SDK
```

- [DairoUI_IOS](https://github.com/DAIRO-HY/DairoUI_IOS)：设置页、弹窗、提示等界面组件；
- [DairoDFS](https://github.com/DAIRO-HY/DairoDFS) 里的 `dairo-file-sdk`：用 Rust 写的客户端 SDK，负责文件下载、缓存、上传和视频播放。

## 3). 步骤

```bash
#下载代码
mkdir -p xcode java/idea
git clone https://github.com/DAIRO-HY/DairoDFS-IOS.git xcode/DairoDFS-IOS
git clone https://github.com/DAIRO-HY/DairoUI_IOS.git xcode/DairoUI_IOS
git clone https://github.com/DAIRO-HY/DairoDFS.git java/idea/DairoDFS

#编译 iOS 用的 SDK，大约需要 10 分钟
cd java/idea/DairoDFS
./dairo-file-sdk/build.sh ios
```

SDK 编译完成后，用 Xcode 打开 `DairoDFS.xcodeproj`，选择设备运行即可。

# 4. 许可证

本项目使用 [Apache License 2.0](LICENSE)。
