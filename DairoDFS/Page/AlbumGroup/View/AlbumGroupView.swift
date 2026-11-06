//
//  AlbumGroupView.swift
//  DairoDFS
//

import SwiftUI

/// 相册按年、按月分组显示的列表
struct AlbumGroupView: View {
    
    /// 每个分组的最小宽度,屏幕较宽时一行显示多个分组
    private static let MIN_CARD_WIDTH: CGFloat = 340
    
    /// 分组之间的间距
    private static let SPACING: CGFloat = 16
    
    /// 要显示的分组
    private let groups: [AlbumGroup]
    
    @EnvironmentObject var vm: AlbumViewModel
    
    init(_ groups: [AlbumGroup]) {
        self.groups = groups
    }
    
    var body: some View {
        GeometryReader { geometry in
            let contentWidth = geometry.size.width - AlbumGroupView.SPACING * 2
            let columnCount = max(1, Int(contentWidth / AlbumGroupView.MIN_CARD_WIDTH))
            let cardWidth = (contentWidth - CGFloat(columnCount - 1) * AlbumGroupView.SPACING) / CGFloat(columnCount)
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(cardWidth), spacing: AlbumGroupView.SPACING, alignment: .top), count: columnCount), spacing: AlbumGroupView.SPACING) {
                        ForEach(self.groups) { group in
                            AlbumGroupCardView(group, width: cardWidth, onClick: self.vm.onGroupPhotoClick)
                        }
                    }
                    .padding(.top)
                    
                    //底部留出空间显示切换按钮,打开时滚动到最底部,显示最新的照片
                    Color.clear.frame(height: 80).id("BOTTOM")
                }
                .onAppear {
                    proxy.scrollTo("BOTTOM", anchor: .bottom)
                }
            }
        }
    }
}
