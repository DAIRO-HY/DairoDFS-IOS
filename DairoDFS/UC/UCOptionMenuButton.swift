//
//  UCOptionMenuButton.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/04.
//

import SwiftUI

struct UCOptionMenuButton: View {
    
    ///高度
    private let HEIGHT = 42.0
    
    ///标题
    private let label: String
    
    ///图标
    private let icon: String
    
    ///字体颜色
    //    final Color? color;
    
    ///是否禁用
    private let disabled: Bool
    
    ///点击回调事件
    private let action: () -> Void
    
    init(_ label: String, icon: String, disabled: Bool = false, action: @escaping () -> Void) {
        self.label = label
        self.icon = icon
        self.disabled = disabled
        self.action = action
    }
    
    var body: some View {
        Button(action: self.action){
            VStack{
                Image(systemName: self.icon)
                Text(self.label)
            }.opacity(self.disabled ? 0.6 : 1)
        }
        .buttonStyle(.row)
        .disabled(self.disabled)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    UCOptionMenuButton("标题",icon:"document.fill", disabled: false){
        
    }
}
