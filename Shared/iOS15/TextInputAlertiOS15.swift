//
//  TextInputAlertiOS15.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/23.
//

//==================================================================
// iOS15兼容代码,最低版本升到16后删除整个iOS15文件夹
// SwiftUI的alert在iOS15上不显示输入框,这里用UIAlertController实现
//==================================================================

import SwiftUI
import UIKit

/// 放在View的background里,isPresented为true时弹出带输入框的UIAlertController
struct TextInputAlertiOS15: UIViewControllerRepresentable {
    let title: String
    let isPresented: Binding<Bool>
    let text: Binding<String>
    let placeholder: String
    let confirm: String
    let isDestructive: Bool
    let onConfirm: (_ text: String) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.isUserInteractionEnabled = false
        controller.view.backgroundColor = .clear
        return controller
    }

    func updateUIViewController(_ controller: UIViewController, context: Context) {
        guard self.isPresented.wrappedValue, context.coordinator.alert == nil else{
            return
        }
        let alert = UIAlertController(title: self.title, message: nil, preferredStyle: .alert)
        alert.addTextField{
            $0.placeholder = self.placeholder
            $0.text = self.text.wrappedValue
            $0.clearButtonMode = .whileEditing
        }
        alert.addAction(UIAlertAction(title: self.confirm, style: self.isDestructive ? .destructive : .default){ [weak alert] _ in
            let value = alert?.textFields?.first?.text ?? ""
            context.coordinator.alert = nil
            self.text.wrappedValue = value
            self.isPresented.wrappedValue = false
            self.onConfirm(value)
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel){ _ in
            context.coordinator.alert = nil
            self.isPresented.wrappedValue = false
        })
        context.coordinator.alert = alert

        //SwiftUI更新界面时不能直接弹出,放到下一次主线程循环
        DispatchQueue.main.async {
            var top = controller
            while let presented = top.presentedViewController{
                top = presented
            }
            top.present(alert, animated: true)
        }
    }

    final class Coordinator {

        /// 正在显示的弹窗,避免重复弹出
        var alert: UIAlertController?
    }
}
