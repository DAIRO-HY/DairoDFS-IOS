//
//  OptionButton.swift
//  DairoDFS
//

import SwiftUI
import DairoUI_IOS

/// 液态玻璃效果的操作按钮,文字较短时是圆形,文字较长时自动变宽
struct OptionButton: View {
    
    ///标题
    private let label: String
    
    ///图标
    private let icon: String
    
    ///是否禁用
    private let disabled: Bool
    
    ///点击回调事件
    private let action: () -> Void
    
    public init(_ label: String, icon: String, disabled: Bool = false, action: @escaping () -> Void) {
        self.label = label
        self.icon = icon
        self.disabled = disabled
        self.action = action
    }
    
    public var body: some View {
        Button(action: self.action){
            VStack(spacing: 0){
                Image(systemName: self.icon)
                Text(self.label)
                    .font(.footnote)
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.top, 1)
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 8)
            .frame(minWidth: 50, minHeight: 50, maxHeight: 50)
            .opacity(self.disabled ? 0.4 : 1)
            .liquidGlassBackground(in: Capsule(), interactive: true)
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.plain)
        .disabled(self.disabled)
    }
}

extension View {
    
    /// 液态玻璃背景,iOS 26以下系统使用毛玻璃
    /// - Parameter shape 背景形状
    /// - Parameter interactive 按下时是否有反馈
    @ViewBuilder
    func liquidGlassBackground<S: Shape>(in shape: S, interactive: Bool = false) -> some View{
        if #available(iOS 26.0, *){
            self.glassEffect(interactive ? .regular.interactive() : .regular, in: shape)
                .contentShape(shape)
        } else {
            self.background(.regularMaterial, in: shape)
                .contentShape(shape)
        }
    }
    
    /// 带颜色的液态玻璃背景,iOS 26以下系统使用纯色
    /// - Parameter color 颜色
    /// - Parameter shape 背景形状
    @ViewBuilder
    func liquidGlassBackground<S: Shape>(_ color: Color, in shape: S) -> some View{
        if #available(iOS 26.0, *){
            self.glassEffect(.regular.tint(color).interactive(), in: shape)
                .contentShape(shape)
        } else {
            self.background(color, in: shape)
                .contentShape(shape)
        }
    }
    
    /// 浮在列表上面的顶部按钮,iOS 26的列表内容滚动到按钮和状态栏后面时会自动渐隐
    @ViewBuilder
    func scrollTopBar<Content: View>(@ViewBuilder content: () -> Content) -> some View{
        if #available(iOS 26.0, *){
            self.safeAreaBar(edge: .top, spacing: 0, content: content)
        } else {
            self.safeAreaInset(edge: .top, spacing: 0, content: content)
        }
    }
}
