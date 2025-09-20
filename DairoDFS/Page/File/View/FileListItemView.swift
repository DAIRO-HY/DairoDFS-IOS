//
//  FileListViewItem.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI
import DairoUI_IOS

struct FileListItemView: View {
    
    ///文件信息
    private let dfsFile: FileEntity
    
    private let isSelectMode: Bool
    init(_ dfsFile: FileEntity, isSelectMode: Bool) {
        self.dfsFile = dfsFile
        self.isSelectMode = isSelectMode
    }
    var body: some View {
        HStack{
            Spacer().frame(width: 8)
            
            //缩略图
            self.thumb
            VStack{
                Text(self.dfsFile.fm.name)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(Date(timeIntervalSince1970: Double(self.dfsFile.fm.date) / 1000).format() + "    " + self.dfsFile.fm.size.fileSize)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
            }
            if self.isSelectMode{//如果是选择模式
                if self.dfsFile.isSelected{//当前为选中状态
                    Image(systemName: "checkmark.circle")
                        .font(.title2)
                } else {
                    Image(systemName: "circle")
                        .font(.title2)
                }
            }
        }
    }
    
    ///缩略图
    private var thumb: some View{
        Section{
            if self.dfsFile.fm.isFile{
                if self.dfsFile.fm.hasThumb{//如果有缩略图
                    let width = 44
                    let thumbUrl = self.dfsFile.fm.onlineThumb(width: width * 3, height: width * 3)
                    let thumbId = self.dfsFile.fm.onlineThumbId(width: width * 3, height: width * 3)
                    CacheImage(thumbUrl, downloadId: thumbId)
                        .frame(width: CGFloat(width), height: CGFloat(width))
                        .cornerRadius(6)
                }else{//没有缩略图
                    Image(systemName: "questionmark.square.fill")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 5, y: 5)
                }
            } else {
                Image(systemName: "folder.fill")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .foregroundColor(.cyan)
            }
        }
    }
}

#Preview {
    FileListItemView(getDfsFileBean(), isSelectMode: false)
}

private func getDfsFileBean() -> FileEntity{
    let dfb = FileEntity(
        FileModel(
            id: 1,
            name: "文件名",
            size: 123456789,
            fileFlag: true,
            date: 1234567890,
            thumb: "http://192.168.10.112:8031/d/oq8221/WechatIMG2.jpg",
            other1: ""
        )
    )
    dfb.isSelected = true
    return dfb
}

