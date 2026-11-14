//
//  PhotoLibraryViewModel.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/09.
//

import Photos
import SwiftUI

struct ImageInfo{
    let image:UIImage
    public let asset:PHAsset
}

class PhotoLibraryViewModel: ObservableObject {
    @Published var images: [ImageInfo] = []

    init() {
        fetchPhotos()
    }

    func fetchPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

                let fetchOptions1 = PHFetchOptions()
                fetchOptions1.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let fetchResult = PHAsset.fetchAssets(with: fetchOptions1)

                let imageManager = PHCachingImageManager()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.isSynchronous = false

                var uiImages: [ImageInfo] = []

                fetchResult.enumerateObjects { asset, _, _ in
                    imageManager.requestImage(for: asset,
                                              targetSize: targetSize,
                                              contentMode: .aspectFill,
                                              options: options) { image, _ in
                        if let image = image {
                            DispatchQueue.main.async {
                                uiImages.append(ImageInfo(
                                    image: image,
                                    asset: asset))
                                self.images = uiImages
                            }
                        }
                    }
                }
            } else {
                print("未授权访问相册")
            }
        }
    }
    
    
    func delete(assets: [PHAsset]) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets as NSArray)
        }) { success, error in
            if success {
                print("照片已删除")
            } else {
                print("删除失败: \(error?.localizedDescription ?? "未知错误")")
            }
        }
    }
}
