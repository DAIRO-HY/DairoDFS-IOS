//
//  AlbumGroupCardView.swift
//  DairoDFS
//

import SwiftUI

/// 一个分组:上面是标题,下面是照片
struct AlbumGroupCardView: View {
    
    /// 照片之间的缝隙
    private static let GAP: CGFloat = 4
    
    private let group: AlbumGroup
    
    /// 整个分组的宽度
    private let width: CGFloat
    
    /// 照片点击事件
    private let onClick: (FileModel) -> Void
    
    /// 屏幕的缩放比例,用来计算照片的实际像素大小
    @Environment(\.displayScale) private var displayScale
    
    init(_ group: AlbumGroup, width: CGFloat, onClick: @escaping (FileModel) -> Void) {
        self.group = group
        self.width = width
        self.onClick = onClick
    }
    
    /// 一行放3张正方形照片时,每张照片的边长
    private var smallSize: CGFloat{
        return (self.width - AlbumGroupCardView.GAP * 2) / 3
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6){
            Text(self.group.title)
                .font(.headline)
                .padding(.leading, 4)
            self.photosView
        }
    }
    
    /// 根据照片数量选择排列方式
    @ViewBuilder
    private var photosView: some View{
        let photos = self.group.photos
        switch photos.count{
        case 1:
            self.getPhoto(photos[0], width: self.width, height: self.width * 0.6)
        case 2://左右各一张
            let size = (self.width - AlbumGroupCardView.GAP) / 2
            HStack(spacing: AlbumGroupCardView.GAP){
                self.getPhoto(photos[0], width: size, height: size)
                self.getPhoto(photos[1], width: size, height: size)
            }
        case 3://左边一张,右边两张,右边两张加起来和左边一样高
            let smallSize = self.smallSize
            let bigSize = smallSize * 2 + AlbumGroupCardView.GAP
            HStack(spacing: AlbumGroupCardView.GAP){
                self.getPhoto(photos[0], width: bigSize, height: bigSize)
                VStack(spacing: AlbumGroupCardView.GAP){
                    self.getPhoto(photos[1], width: smallSize, height: smallSize)
                    self.getPhoto(photos[2], width: smallSize, height: smallSize)
                }
            }
        default://第一行一张,第二行三张
            VStack(spacing: AlbumGroupCardView.GAP){
                self.getPhoto(photos[0], width: self.width, height: self.width * 0.6)
                HStack(spacing: AlbumGroupCardView.GAP){
                    self.getPhoto(photos[1], width: self.smallSize, height: self.smallSize)
                    self.getPhoto(photos[2], width: self.smallSize, height: self.smallSize)
                    self.getPhoto(photos[3], width: self.smallSize, height: self.smallSize)
                }
            }
        }
    }
    
    /// 一张照片,左上角显示拍摄日期
    private func getPhoto(_ photo: AlbumGroupPhoto, width: CGFloat, height: CGFloat) -> some View{
        Button(action: {
            self.onClick(photo.fm)
        }){
            ZStack(alignment: .topLeading){
                if photo.fm.hasThumb{
                    
                    //按实际像素请求在线生成的图片,这样不会模糊也不会有锯齿,生成期间先显示缩略图
                    DfsImage(photo.fm.thumbOnlineSource(width: width * self.displayScale, height: height * self.displayScale), fallback: photo.fm.thumbSource)
                        .frame(width: width, height: height)
                        .clipped()
                } else {
                    Image(systemName: "document.fill")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                        .frame(width: width, height: height)
                        .background(Color(uiColor: .tertiarySystemBackground))
                }
                Text(photo.dateLabel)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 3, x: 1, y: 1)
                    .padding(6)
            }
            .frame(width: width, height: height)
            .contentShape(Rectangle())
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}
