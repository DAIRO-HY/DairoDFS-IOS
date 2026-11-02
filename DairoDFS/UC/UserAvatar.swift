//
//  UserAvatar.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/02.
//

import SwiftUI

/**
 用户头像,没有头像时显示App图标
 */
struct UserAvatar: View {
    
    private let source: FileSource?
    private let size: CGFloat
    
    init(_ user: MineModel?, size: CGFloat) {
        self.source = user.flatMap{ FileSource.avatar($0) }
        self.size = size
    }
    
    var body: some View {
        ZStack{
            if let source = self.source{
                DfsImage(source)
            } else {
                Image("logo").resizable()
            }
        }
        .frame(width: self.size, height: self.size)
        .clipShape(Circle())
    }
}
