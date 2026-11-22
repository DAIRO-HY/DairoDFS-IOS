//
//  ShareViewController.swift
//  DairoDFSShare
//
//  Created by zhoulq on 2026/11/23.
//

import SwiftUI
import UIKit

/**
 分享扩展入口,在Info.plist的NSExtensionPrincipalClass里指定
 选择文件夹之后把分享的文件复制到共享目录,由主App上传
 */
final class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let model = ShareFolderViewModel(
            onCancel: { [weak self] in
                self?.extensionContext?.cancelRequest(withError: NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError))
            },
            onUpload: { [weak self] folder in
                try await self?.save(folder: folder)
            }
        )
        let host = UIHostingController(rootView: ShareFolderView(model: model))
        self.addChild(host)
        host.view.frame = self.view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(host.view)
        host.didMove(toParent: self)
    }

    /// 保存分享的文件,完成之后关闭分享界面
    private func save(folder: String) async throws {
        guard let login = ShareUploadStore.login else{
            throw ShareUploadError("请先打开DairoDFS登录")
        }
        let providers = (self.extensionContext?.inputItems as? [NSExtensionItem] ?? [])
            .flatMap{ $0.attachments ?? [] }
        let record = try await ShareFileSaver.save(providers, account: login.account, folder: folder)
        ShareUploadStore.lastFolder = folder
        await ShareNotification.show(count: record.files.count)
        self.extensionContext?.completeRequest(returningItems: nil)
    }
}
