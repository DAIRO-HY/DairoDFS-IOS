//
//  FileListViewItem.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI
import DairoUI_IOS

struct FileUploadItemView: View {
    
    private let isChecked: Bool
    
    private let pageVm: FileUploadViewModel
    
    ///文件信息
    @ObservedObject private var vm: FileUploadItemViewModel
    init(_ pageVm: FileUploadViewModel, _ id: Int64, _ isChecked: Bool) {
        self.pageVm = pageVm
        self.isChecked = isChecked
        self.vm = FileUploadItemViewModel(id)
    }
    var body: some View {
        HStack{
            Button(action:{
                self.pageVm.onCheckClick(self.vm.dto.id)
            }){
                if self.isChecked{
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 5, y: 5)
                } else {
                    Image(systemName: "circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 5, y: 5)
                }
            }
            
            //缩略图
            self.thumb
            VStack{
                Text(self.vm.dto.name)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack{
                    Text(DateUtil.format(self.vm.dto.date))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if self.vm.total > 0{
                        Text(self.vm.total.fileSize)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                if self.vm.uploadState != 10{
                    ProgressView(value: Float64(self.vm.uploadedSize), total: Float64(self.vm.total))
                        .progressViewStyle(.linear)
                        .tint(.blue)
                    HStack{
                        if let error = self.vm.error{
                            Button(action:{
                                Toast.show(error)
                            }){
                                Text(error).font(.footnote).foregroundColor(.red)
                                    .lineLimit(1)                       // 禁止换行，只显示一行
                                    .truncationMode(.tail)              // 超出部分显示省略号
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text(self.vm.progressInfo)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Text(self.vm.uploadStateLabel)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        //                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Button(action:{
                            self.vm.onUploadStateClick()
                        }){
                            let isDownloading = self.vm.uploadState == 0 || self.vm.uploadState == 1
                            Image(systemName: isDownloading ? "pause.circle" : "play.circle")
                                .resizable()
                                .foregroundColor(.secondary)
                                .frame(width: 15, height: 15)
                        }
                    }
                }
            }.onReceive(NotificationCenter.default.publisher(for: Notification.Name(String(self.vm.dto.id)))){
                let userInfo = $0.userInfo!
                switch userInfo["key"] as! FileUploaderNotify{
                case .progress:/// 进度回调
                    let progress = userInfo["value"] as! [Int64]
                    self.vm.total = progress[0]
                    self.vm.uploadedSize = progress[1]
                    //                    self.vm.speed = progress[2].fileSize + "/S"
                    self.vm.progressInfo = "\(progress[1].fileSize)(\(progress[2].fileSize)/S)"
                    
                    //标记下载中
                    self.vm.setUploadState(1)
                case .pause:
                    // 标记下载暂停
                    self.vm.setUploadState(2)
                case .finish:
                    if let error = userInfo["value"] as? String{
                        
                        /// 标记下载失败
                        self.vm.setUploadState(3)
                        self.vm.error = error
                    }else{
                        
                        // 标记下载完成
                        self.vm.setUploadState(10)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    ///缩略图
    private var thumb: some View{
        Section{
            //                if self.dfsFile.fm.hasThumb{//如果有缩略图
            //                    CacheImage(self.dfsFile.fm.thumbUrl)
            //                        .frame(width: 50, height: 50)
            //                        .cornerRadius(6)
            //                } else {//没有缩略图
            //                    Image(systemName: "questionmark.square.fill")
            //                        .resizable()
            //                        .frame(width: 50, height: 50)
            //                        .foregroundColor(.white)
            //                }
            Image(systemName: "questionmark.square.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 5, y: 5)
        }
    }
}

//#Preview {
//    DownloadItemView(FileUploadViewModel(), getID(), true)
//}
//
//private func getID() -> String{
//    let id = "3wedscv"
//    try? DownloadDBUtil.addCache(id, "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=100")
//    return id
//}

