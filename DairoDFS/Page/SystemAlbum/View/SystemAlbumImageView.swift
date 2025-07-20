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
    
    //图片尺寸
    let size: CGFloat
    
    //相册信息Bean
    let albumBean: SystemAlbumBean
    
    //预览图片
    @State private var image: UIImage?
    
    var body: some View {
        ZStack(alignment: .topLeading){
            if let uiImage = self.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: self.size, height: self.size)
                    .clipped()
            } else {
                ProgressView("Loading...")
            }
            VStack(spacing: 0){
                HStack{
                    if self.albumBean.checked{//如果是选择状态
                        Image(systemName:"checkmark.circle.fill")
                    }
                    Spacer()
                }
                Spacer()
                HStack{
                    Spacer()
                    if let duration = self.albumBean.duration{
                        Text(duration).foregroundColor(.white).font(.footnote).shadow(color: .black, radius: 2, x: 1, y: 1)
                        Spacer().frame(width: 5)
                    }
                }
                if !self.albumBean.uploadMsg.isEmpty{//上传状态
                    Button(action: {
                        Toast.show(self.albumBean.uploadMsg)
                    }){
                        Text(self.albumBean.uploadMsg)
                            .font(.footnote).foregroundColor(.white)
                    }.frame(maxWidth: .infinity).frame(height: 20).background(Color.black.opacity(0.5))
                }
            }
        }
        .frame(width: self.size, height: self.size)
        .background(Color.black)
        .onAppear {
            self.requestImage() { img in
                self.image = img
            }
        }
    }
    
    func requestImage(targetSize: CGSize = CGSize(width: 200, height: 200), completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false//用于控制图像请求是 同步执行 还是 异步执行。
        options.isNetworkAccessAllowed = false// 允许从iCloud下载
        
        PHImageManager.default().requestImage(
            for: self.albumBean.asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options) { image, _ in
                completion(image)
            }
    }
}

//#Preview {
//    AssetImageView()
//}
