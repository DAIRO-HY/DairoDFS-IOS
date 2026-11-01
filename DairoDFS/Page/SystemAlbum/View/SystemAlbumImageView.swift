//
//  AssetImageView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/07/11.
//

import SwiftUI
import Photos
import DairoUI_IOS


struct SystemAlbumImageView: View {
    @EnvironmentObject var vm: SystemAlbumViewModel
    
    //图片尺寸
    let size: CGFloat
    
    //相册信息Bean
    //    let albumBean: SystemAlbumBean
    
    //预览图片
    @State private var image: UIImage?
    
    //当前上传进度信息
    @State private var progress = ""
    
    /// 当前序号
    private let index: Int
    
    private let localIdentifier: String
    
    init(_ size: CGFloat, _ index: Int, _ localIdentifier: String){
        self.size = size
        self.index = index
        self.localIdentifier = localIdentifier
    }
    
    var body: some View {
        ZStack(alignment: .topLeading){
            
            //相册列表刷新时,列表可能已经变短,而这个视图还没有被移除
            if let uiImage = self.image, self.vm.albumList.indices.contains(self.index) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: self.size, height: self.size)
                    .clipped()
                let albumBean = self.vm.albumList[self.index]
                if !albumBean.locallyAvailable{//图片在iCloud中
                    ZStack{
                        Color.black.opacity(0.2)
                        Image(systemName: "exclamationmark.icloud")
                            .resizable()
                            .frame(width: 64, height: 40).foregroundColor(.white).shadow(color: .black, radius: 2, x: 1, y: 1)
                            .opacity(0.6)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                VStack(spacing: 0){
                    HStack{
                        if albumBean.checked{//如果是选择状态
                            Image(systemName:"checkmark.circle.fill")
                                .resizable()
                                .frame(width: 18, height: 18)
                            //                            .font(.body)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 2, x: 1, y: 1)
                        }
                        Spacer()
                        if albumBean.mediaType == "Live Photo"{
                            Image(systemName:"livephoto")
                                .resizable()
                                .frame(width: 18, height: 18)
                            //                            .font(.body)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 2, x: 1, y: 1)
                        }
                    }
                    .padding(8)
                    Spacer()
                    HStack{
                        Spacer()
                        if let duration = albumBean.duration{
                            Text(duration).foregroundColor(.white).font(.footnote).shadow(color: .black, radius: 2, x: 1, y: 1)
                            Spacer().frame(width: 5)
                        }
                    }
                    if !self.progress.isEmpty{//上传状态
                        Button(action: {
                            Toast.show(self.progress)
                        }){
                            Text(self.progress)
                                .font(.footnote).foregroundColor(.white)
                        }.frame(maxWidth: .infinity).frame(height: 20).background(Color.black.opacity(0.5))
                    }
                }
            } else {
                ProgressView("Loading...")
            }
            
        }
        .frame(width: self.size, height: self.size)
        .background(Color.black)
        .onAppear {
            Task.detached{
                self.vm.loadAlbumInfo(self.index)
                self.requestImage()
            }
        }.onReceive(NotificationCenter.default.publisher(for: Notification.Name(SystemAlbumViewModel.NOTIFY_UPLOAD_PROGRESS + self.localIdentifier))){
            self.progress = $0.object as! String
        }
    }
    
    private func requestImage(targetSize: CGSize = CGSize(width: 200, height: 200)) {
        guard self.vm.albumList.indices.contains(self.index) else{
            return
        }
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false//用于控制图像请求是 同步执行 还是 异步执行。
        options.isNetworkAccessAllowed = true// 允许从iCloud下载
        PHImageManager.default().requestImage(
            for: self.vm.albumList[self.index].asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options) { image, _ in
                Task{@MainActor in
                    if self.progress.isEmpty, self.vm.albumList.indices.contains(self.index){
                        self.progress = self.vm.albumList[self.index].uploadMsg
                    }
                    self.image = image
                }
            }
    }
}

//#Preview {
//    AssetImageView()
//}
