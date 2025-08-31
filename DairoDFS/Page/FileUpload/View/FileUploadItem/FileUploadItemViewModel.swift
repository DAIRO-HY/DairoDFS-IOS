//
//  DownloadItemViewModel.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/14.
//

import Foundation

class FileUploadItemViewModel : ObservableObject{
    
    /// 当前上传信息
    let dto: FileUploaderDto
    
    /// 文件总大小
    @Published var total: Int64 = 1
    
    /// 已经上传大小
    @Published var uploadedSize: Int64 = 0
    
    /// 上传错误
    @Published var error: String? = nil
    
    /// 进度信息
    @Published var progressInfo: String = ""
    
    /// 上传状态
    @Published var uploadState: Int8 = 0
    
    /// 上传状态
    @Published var uploadStateLabel = ""
    init(_ id: Int64){
        self.dto = FileUploaderDBUtil.selectOne(id)!
        self.total = self.dto.size
        self.uploadedSize = self.dto.uploadedSize
        self.error = self.dto.error
        self.progressInfo = self.dto.uploadedSize.fileSize
        self.setUploadState(self.dto.state)
    }
    
    /// 设置上传状态
    func setUploadState(_ state: Int8){
        if state == 0{
            self.uploadStateLabel = "等待上传"
        } else if state == 1{
            self.uploadStateLabel = "上传中"
        } else if state == 2{
            self.uploadStateLabel = "已暂停"
        } else if state == 3{
            self.uploadStateLabel = "上传失败"
        } else if state == 10{
            self.uploadStateLabel = "上传完成"
        }
        self.uploadState = state
    }
    
    /// 暂停/开始点击事件
    func onUploadStateClick(){
        if self.uploadState == 0 || self.uploadState == 1{// 当前准备下载或正在下载中
            FileUploaderManager.cancel(self.dto.id)
            self.setUploadState(2)
            
            //将其设置为暂停中
            FileUploaderDBUtil.setState(self.dto.id, 2)
        } else {
            self.error = nil
            self.setUploadState(0)
            
            //将其设置为准备下载中
            FileUploaderDBUtil.setState(self.dto.id, 0)
            
            //开启循环下载
            FileUploaderManager.loopUpload()
        }
    }
    
    deinit{
        print("-->FileUploadItemViewModel.deinit")
    }
}
