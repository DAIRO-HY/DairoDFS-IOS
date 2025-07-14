//
//  AlbumSync.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/06/24.
//

import SwiftUI
import Photos
import CommonCrypto
import DairoUI_IOS

struct SystemAlbumPage: View {
    
    ///表间距
    private let SPACING = CGFloat(2)
    
    //列数
    private let COLUMN_NUM = 3
    
    @StateObject private var viewModel = SystemAlbumViewModel()
    var body: some View {
        GeometryReader { geometry in
            
            //每列宽度 = (屏幕宽度 - (列数 - 1) * 列间距) / 列数
            let width = (geometry.size.width - CGFloat(self.COLUMN_NUM - 1) * self.SPACING) / CGFloat(self.COLUMN_NUM)
            VStack{
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: self.SPACING), count: self.COLUMN_NUM), spacing: self.SPACING) {
                        ForEach(self.viewModel.albumList, id:\.identifier) { item in
                            //                        let asset = viewModel.albumAsset[index]
                            Button(action:{
                                self.viewModel.onItemClick(item)
                            }){
                                SystemAlbumImageView(size: width,albumBean: item)
                                                                //Text("-->:\(width)")
                                //                            Text("\(index)-\(getAssetFileExtension(imageInfo.asset)!)-\(Costom.getCostom())")
                                //                                Text("\(item.isExistsFlag)")
                                //                                Text("\(item.identifier)-\(item.name)")
                                //                            Text(getAssetFilePath(asset))
                            }.background(Color.red)
                        }
                    }
                }
                SystemAlbumOptionView().environmentObject(self.viewModel)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("所有照片")
    }
    
    func calculateAssetMD5(_ asset: PHAsset, completion: @escaping (String?) -> Void) {
        // 确保是视频类型
        //        guard asset.mediaType == .video else {
        //            completion(nil)
        //            return
        //        }
        
        // 获取视频资源（注意有多个时可能需要更精确过滤）
        //        guard let resource = PHAssetResource.assetResources(for: asset).first(where: { $0.type == .video }) else {
        //            print("未找到视频资源")
        //            completion(nil)
        //            return
        //        }
        let resource = PHAssetResource.assetResources(for: asset).first
        
        // 初始化 MD5 计算上下文
        var context = CC_MD5_CTX()
        CC_MD5_Init(&context)
        
        // 设置读取选项（可设置 isNetworkAccessAllowed 等）
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true
        
        // 读取资源数据并计算 MD5
        PHAssetResourceManager.default().requestData(for: resource!, options: options, dataReceivedHandler: { data in
            data.withUnsafeBytes { buffer in
                _ = CC_MD5_Update(&context, buffer.baseAddress, CC_LONG(data.count))
            }
        }, completionHandler: { error in
            if let error = error {
                print("读取失败: \(error)")
                completion(nil)
            } else {
                // 计算最终的 MD5 值
                var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
                CC_MD5_Final(&digest, &context)
                
                // 转换为十六进制字符串
                let md5String = digest.map { String(format: "%02x", $0) }.joined()
                completion(md5String)
            }
        })
    }
    
    //    func exportAssetToFile(asset: PHAsset) {
    //        // 获取资源列表（可能包含原始图像、缩略图等）
    //        let resources = PHAssetResource.assetResources(for: asset)
    //
    //        // 通常第一个就是原始图像/视频
    //        guard let resource = resources.first else {
    //            completion(nil)
    //            return
    //        }
    //
    //        // 创建临时文件路径
    //        let fileName = resource.originalFilename
    //        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    
    // 确保文件不存在
    //        try? FileManager.default.removeItem(at: tempURL)
    //
    //        // 写入文件
    //        PHAssetResourceManager.default().writeData(for: resource, toFile: tempURL, options: nil) { error in
    //            if let error = error {
    //                print("写入失败: \(error.localizedDescription)")
    //                completion(nil)
    //            } else {
    //                print("文件导出成功: \(tempURL.path)")
    //                completion(tempURL)
    //            }
    //        }
    //    }
    func getAssetFileExtension(_ asset: PHAsset) -> String? {
        var ext = "nil"
        let resources = PHAssetResource.assetResources(for: asset)
        if let resource = resources.first {
            let originalFilename = resource.originalFilename
            ext = (originalFilename as NSString).pathExtension.lowercased()
        }
        if asset.mediaSubtypes.contains(.photoLive) {
            // 实况照片
            return ("Live Photo: \(ext)")
        } else if asset.mediaType == .image {
            // 普通图片
            return ("Image: \(ext)")
        } else if asset.mediaType == .video {
            // 视频
            return ("Video: \(ext)")
        }
        return ext
    }
}


#Preview {
    SystemAlbumPage()
}
