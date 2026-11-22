//
//  TextInputAlert.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/23.
//

import SwiftUI

extension View {

    /**
     带输入框的弹窗,主App和分享扩展共用
     - Parameter text: 输入框内容,弹出时显示的就是它的值
     - Parameter confirmRole: 确认按钮的样式
     - Parameter onConfirm: 点击确认按钮时调用,参数是输入的内容
     */
    func textInputAlert(_ title: String,
                        isPresented: Binding<Bool>,
                        text: Binding<String>,
                        placeholder: String,
                        confirm: String,
                        confirmRole: ButtonRole? = nil,
                        onConfirm: @escaping (_ text: String) -> Void) -> some View {
        self.modifier(TextInputAlertModifier(
            title: title,
            isPresented: isPresented,
            text: text,
            placeholder: placeholder,
            confirm: confirm,
            confirmRole: confirmRole,
            onConfirm: onConfirm
        ))
    }
}

private struct TextInputAlertModifier: ViewModifier {
    let title: String
    let isPresented: Binding<Bool>
    let text: Binding<String>
    let placeholder: String
    let confirm: String
    let confirmRole: ButtonRole?
    let onConfirm: (_ text: String) -> Void

    func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            content.alert(self.title, isPresented: self.isPresented) {
                TextField(self.placeholder, text: self.text)
                Button(self.confirm, role: self.confirmRole) {
                    self.onConfirm(self.text.wrappedValue)
                }
                Button("取消", role: .cancel) {}
            }
        } else {

            //iOS15兼容:SwiftUI的alert在iOS15上不显示输入框,最低版本升到16后删除这个分支和iOS15文件夹
            content.background(TextInputAlertiOS15(
                title: self.title,
                isPresented: self.isPresented,
                text: self.text,
                placeholder: self.placeholder,
                confirm: self.confirm,
                isDestructive: self.confirmRole == .destructive,
                onConfirm: self.onConfirm
            ))
        }
    }
}
