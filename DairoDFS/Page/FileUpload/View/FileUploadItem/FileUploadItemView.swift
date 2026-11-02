//
//  FileListViewItem.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI
import DairoUI_IOS
import DairoFileSDK

struct FileUploadItemView: View {
    
    @ObservedObject private var vm: FileUploadViewModel
    
    ///上传信息
    private let item: UploadInfo
    
    init(_ vm: FileUploadViewModel, _ item: UploadInfo) {
        self.vm = vm
        self.item = item
    }
    
    /// 是否已经结束,跳过表示服务器上已经有相同的文件
    private var isFinish: Bool{
        return self.item.state == .finish || self.item.state == .skipped
    }
    
    var body: some View {
        HStack{
            Button(action:{
                self.vm.onCheckClick(self.item.id)
            }){
                Image(systemName: self.vm.checked.contains(self.item.id) ? "checkmark.circle" : "circle")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            VStack{
                Text(self.item.name)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack{
                    Text(Date(timeIntervalSince1970: Double(self.item.createDate) / 1000).format())
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if let size = self.item.size{
                        Text(Int64(size).fileSize)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                if self.isFinish{
                    Text(self.stateLabel)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ProgressView(value: Double(self.item.uploaded), total: Double(max(self.item.size ?? 0, max(self.item.uploaded, 1))))
                        .progressViewStyle(.linear)
                        .tint(.blue)
                    HStack{
                        if let error = self.item.error.map(FileSdkUtil.friendlyError){
                            Button(action:{
                                Toast.show(error)
                            }){
                                Text(error).font(.footnote).foregroundColor(.red)
                                    .lineLimit(1)                       // 禁止换行，只显示一行
                                    .truncationMode(.tail)              // 超出部分显示省略号
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text(self.vm.progressInfo[self.item.id] ?? Int64(self.item.uploaded).fileSize)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Text(self.stateLabel)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Button(action:{
                            self.vm.onStateClick(self.item)
                        }){
                            Image(systemName: self.item.state == .waiting || self.item.state == .uploading ? "pause.circle" : "play.circle")
                                .resizable()
                                .foregroundColor(.secondary)
                                .frame(width: 15, height: 15)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    /// 上传状态文字
    private var stateLabel: String{
        switch self.item.state{
        case .waiting: return "等待上传"
        case .uploading: return "上传中"
        case .paused: return "已暂停"
        case .error: return "上传失败"
        case .finish: return "上传完成"
        case .skipped: return "文件已存在"
        }
    }
}
