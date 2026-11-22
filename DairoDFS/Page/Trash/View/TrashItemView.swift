//
//  TrashItemView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI
import DairoUI_IOS

struct TrashItemView: View {

    @Environment(\.displayScale) private var displayScale
    
    ///回收站文件信息
    private let entity: TrashEntity
    
    /// 是否选中,TrashEntity是引用类型,要以值的方式传入,否则选中状态变化时视图不会刷新
    private let isSelected: Bool
    
    init(_ entity: TrashEntity, isSelected: Bool) {
        self.entity = entity
        self.isSelected = isSelected
    }
    var body: some View {
        HStack{
            Spacer().frame(width: 8)
            
            //缩略图
            self.thumb
            VStack{
                Text(self.entity.fm.name)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(self.entity.fm.date + "    " + self.entity.fm.size.fileSize)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
            }
            if self.isSelected{//当前为选中状态
                Image(systemName: "checkmark.circle")
                    .font(.title2)
            } else {
                Image(systemName: "circle")
                    .font(.title2)
            }
        }
    }
    
    /// 转成文件信息,用来生成在线图片的地址
    private var fileModel: FileModel{
        let fm = self.entity.fm
        return FileModel(id: fm.id, name: fm.name, size: fm.size, fileFlag: fm.fileFlag, date: 0, hasThumb: fm.hasThumb)
    }

    ///缩略图
    private var thumb: some View{
        Section{
            if self.entity.fm.hasThumb{//如果有缩略图
                DfsImage(FileSource.thumb(id: self.entity.fm.id), placeholder: "photo")
                    .frame(width: 44, height: 44)
                    .clipped()
                    .cornerRadius(6)
            } else if self.fileModel.canThumbOnline{//账号关掉了缩略图,服务器用原图在线生成
                DfsImage(self.fileModel.thumbOnlineSource(width: 44 * self.displayScale, height: 44 * self.displayScale), placeholder: "photo")
                    .frame(width: 44, height: 44)
                    .clipped()
                    .cornerRadius(6)
            } else {//没有缩略图
                Image(systemName: "questionmark.square.fill")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 5, y: 5)
            }
        }
    }
}
