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
    
    /// 是否选中,AlbumEntity是引用类型,要以值的方式传入,否则选中状态变化时视图不会刷新
    private let isSelected: Bool
    
    /// 屏幕的缩放比例,用来计算照片的实际像素大小
    @Environment(\.displayScale) private var displayScale
    
    init(_ entity: AlbumEntity, size: CGFloat, isSelected: Bool, isSelectMode: Bool) {
        self.entity = entity
        self.size = size
        self.isSelected = isSelected
        self.isSelectMode = isSelectMode
        
        //print("-->:\(self.entity.isSelected)")
    }
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            self.thumb
            if let duration = self.entity.fm.duration, duration > 0{//如果有视频时间
                Text(duration.timeFormat)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .offset(x: -5, y: -5)
                    .shadow(color: .black,radius: 3, x: 2, y: 2)
            }
            
            if self.isSelectMode{//如果是选择模式
                Section{
                    if self.isSelected{//当前为选中状态
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
                //按实际像素请求在线生成的图片,生成期间先显示缩略图。查看页面用的也是这张缩略图,打开图片时不用走网络就能先显示
                DfsImage(self.entity.fm.thumbOnlineSource(width: self.size * self.displayScale, height: self.size * self.displayScale), fallback: self.entity.fm.thumbSource, placeholder: self.entity.fm.placeholderIcon)
                    .frame(width: self.size, height: self.size)
                    .clipped()
                    .contentShape(Rectangle())//clipped只裁剪显示,不限制点击范围,否则会点到相邻的图片
            }else{//服务器还没有生成缩略图
                ImagePlaceholder(self.entity.fm.placeholderIcon)
                    .frame(width: self.size, height: self.size)
            }
        }
    }
}

#Preview {
    AlbumGridViewItem(getTestEntity(), size: 300, isSelected: true, isSelectMode: true)
}


private func getTestEntity() -> AlbumEntity{
    var dfb = AlbumEntity(0, 
        FileModel(
            id: 1,
            name: "文件名",
            size: 123456789,
            fileFlag: true,
            date: 123456,
            hasThumb: false,
            duration: 720000
        )
    )
    dfb.isSelected = true
    return dfb
}

