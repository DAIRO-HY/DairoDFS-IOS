//
//  PhotoGridView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/09.
//

import SwiftUICore
import SwiftUI
import Photos

struct PhotoGridView: View {
    @StateObject private var viewModel = PhotoLibraryViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(viewModel.images.indices, id: \.self) { index in
                    let imageInfo = viewModel.images[index]
                    Button(action:{
                        viewModel.delete(assets: [viewModel.images[0].asset,viewModel.images[1].asset,viewModel.images[2].asset,viewModel.images[3].asset])
                    }){
                        VStack{
                            Image(uiImage: imageInfo.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                            Text("\(index)-\(getAssetFileExtension(imageInfo.asset)!)")
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("所有照片")
    }
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
