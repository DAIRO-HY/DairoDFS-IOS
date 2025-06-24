//
//  AlbumSyncViewModel.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/06/24.
//

import Photos
import SwiftUI

struct AlbumSyncImageInfo{
//    let image:UIImage
    public let asset:PHAsset
}

class AlbumSyncViewModel: ObservableObject {
    @Published var albumAsset = [PHAsset]()

    init() {
        fetchPhotos()
    }

    func fetchPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
                var albumAsset = [PHAsset]()
                fetchResult.enumerateObjects { asset, _, _ in
                    albumAsset.append(asset)
                }
                Task{@MainActor in
                    self.albumAsset = albumAsset
                }
                debugPrint(albumAsset.count)
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
