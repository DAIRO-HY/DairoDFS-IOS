//
//  DocumentPicker.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/08/21.
//

import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    var onPick: ([URL]) -> Void
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onPick: onPick)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // 允许选择任意类型的文件，比如 pdf, image, plainText
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data])
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onPick: ([URL]) -> Void
        init(onPick: @escaping ([URL]) -> Void) {
            self.onPick = onPick
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            self.onPick(urls)
//            if let url = urls.first {
//                // iOS 沙盒限制，需要先拷贝一份到 App 的临时目录
//                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
//                try? FileManager.default.copyItem(at: url, to: tempURL)
//                onPick(tempURL)
//            }
        }
    }
}
