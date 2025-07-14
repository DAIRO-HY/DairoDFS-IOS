//
//  MemoryInputStream.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/07/12.
//

import Foundation
import Photos

class MemoryInputStream {
    
    //相册数据
    private let asset: PHAsset
    
    private let outputStream: OutputStream
    init(_ dasset: PHAsset, _ outputStream: OutputStream) {
        self.asset = dasset
        self.outputStream = outputStream
        outputStream.open()
        
        //获取文件总大小
//        self.total = PHAssetResource.assetResources(for: asset).first!.value(forKey: "fileSize") as! Int64
//        super.init(data: Data()) // 调用父类构造器
    }
    
    func readPHAssetTask(){
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = false// 允许从iCloud下载
        
        // 读取资源数据并计算 MD5
        PHAssetResourceManager.default().requestData(for: PHAssetResource.assetResources(for: self.asset).first!, options: options, dataReceivedHandler: { data in
//            self.semaphore.wait()
//            self.dataLock.lock()
//            self.data.append(data)
//            self.dataLock.unlock()
//            while self.data.count > 10 * 1024 * 1024{//如果缓存中的数据超过了指定大小,则暂停读取数据
//                self.semaphore.wait()
//            }

            print("-->count:\(data.count)")
            _ = data.withUnsafeBytes {
                self.outputStream.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: data.count)
            }
        }, completionHandler: { error in
            if let error = error {
                print("读取失败: \(error)")
            } else {
                print("读取完毕")
            }
        })
    }
    
    deinit{
        debugPrint("-->MemoryInputStream.deinit")
    }
}
