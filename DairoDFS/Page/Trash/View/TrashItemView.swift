//
//  FileListViewItem.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI
import DairoUI_IOS

struct TrashItemView: View {
    
    ///回收站文件信息
    private let entity: TrashEntity
    
    init(_ entity: TrashEntity) {
        self.entity = entity
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
            if self.entity.isSelected{//当前为选中状态
                Image(systemName: "checkmark.circle")
                    .font(.title2)
            } else {
                Image(systemName: "circle")
                    .font(.title2)
            }
        }
    }
    
    ///缩略图
    private var thumb: some View{
        Section{
            if !self.entity.fm.thumb.isEmpty{//如果有缩略图
                let url = SettingShared.domainNotNull + self.entity.fm.thumb + "?extra=thumb&_token=" + SettingShared.token
                CacheImage(url, downloadId: "\(self.entity.fm.id)-thumb")
                    .frame(width: 44, height: 44)
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
