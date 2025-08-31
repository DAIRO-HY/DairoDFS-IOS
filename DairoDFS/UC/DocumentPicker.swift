//
//  DocumentPicker.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/08/21.
//

import SwiftUI
import UniformTypeIdentifiers

public struct DocumentPicker: UIViewControllerRepresentable {
    
    /// 文件选择方式 .data:文件选择  .folder:选择文件夹
    private let utType: UTType
    
    /// 文件选择时,允许选择多个文件
    private let allowsMultipleSelection: Bool
    
    /// 选择结束之后回调函数
    private let pickFunc: ([URL]) -> Void
    public init(_ utType: UTType, _ allowsMultipleSelection: Bool, pickFunc: @escaping ([URL]) -> Void){
        self.utType = utType
        self.allowsMultipleSelection = allowsMultipleSelection
        self.pickFunc = pickFunc
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(self.pickFunc)
    }
    
    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // 允许选择任意类型的文件，比如 pdf, image, plainText
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [self.utType])
        picker.allowsMultipleSelection = self.allowsMultipleSelection
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        
        /// 选择结束之后回调函数
        private let pickFunc: ([URL]) -> Void
        public init(_ pickFunc: @escaping ([URL]) -> Void){
            self.pickFunc = pickFunc
        }
        
        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            self.pickFunc(urls)
        }
    }
}
