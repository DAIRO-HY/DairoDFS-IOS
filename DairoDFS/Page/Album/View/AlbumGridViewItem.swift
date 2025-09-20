//
//  AlbumGridViewItem.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/04.
//

import SwiftUI
import DairoUI_IOS

struct AlbumGridViewItem: View {
    
    ///文件信息
    private let entity: AlbumEntity
    
    private let isSelectMode: Bool
    
    private let size: CGFloat
    
    init(_ entity: AlbumEntity, size: CGFloat, isSelectMode: Bool) {
        self.entity = entity
        self.size = size
        self.isSelectMode = isSelectMode
    }
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            self.thumb
            if let duration = Int(self.entity.fm.other1) , duration > 0{//如果有视频时间
                Text(duration.timeFormat)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .offset(x: -5, y: -5)
                    .shadow(color: .black,radius: 3, x: 2, y: 2)
            }
            
            if self.isSelectMode{//如果是选择模式
                Section{
                    if self.entity.isSelected{//当前为选中状态
                        Image(systemName: "checkmark.circle.fill")
                    }
//                    else {
//                        Image(systemName: "circle")
//                    }
                }
                .font(.title2)
                .foregroundStyle(Color.gl.bgPrimary)
                .shadow(color: .white,radius: 3, x: 2, y: 2)
                .offset(x: -5, y: -5)
            }
        }
    }
    
    private var thumb: some View{
        Section{
            if self.entity.fm.hasThumb{//如果有缩略图
                let thumbUrl = self.entity.fm.onlineThumb(width: Int(self.size) * 3, height: Int(self.size) * 3)
                let thumbId = self.entity.fm.onlineThumbId(width: Int(self.size) * 3, height: Int(self.size) * 3)
                CacheImage(thumbUrl, downloadId: thumbId)
                    .frame(width: self.size, height: self.size)
            }else{//没有缩略图
                Image(systemName: "document.fill")
                    .resizable()
                    .frame(width: self.size, height: self.size)
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    AlbumGridViewItem(getTestEntity(), size: 300, isSelectMode: true)
}


private func getTestEntity() -> AlbumEntity{
    var dfb = AlbumEntity(0, 
        FileModel(
            id: 1,
            name: "文件名",
            size: 123456789,
            fileFlag: true,
            date: 123456,
            thumb: "http://192.168.10.112:8031/d/oq8221/WechatIMG2.jpg",
            other1:"12:00"
        )
    )
    dfb.isSelected = true
    return dfb
}

