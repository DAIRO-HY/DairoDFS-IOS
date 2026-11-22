//
//  ShareFolderView.swift
//  DairoDFSShare
//
//  Created by zhoulq on 2026/11/23.
//

import SwiftUI

/// 选择上传到的文件夹
struct ShareFolderView: View {

    @ObservedObject var model: ShareFolderViewModel

    var body: some View {
        NavigationView {
            self.content
                .navigationTitle(self.model.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消", action: self.model.onCancel)
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            self.model.newFolderName = ""
                            self.model.isShowCreateFolder = true
                        } label: {
                            Label("新建文件夹", systemImage: "folder.badge.plus")
                        }
                        .disabled(self.model.login == nil || self.model.isLoading || self.model.loadError != nil)
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    if self.model.login != nil{
                        self.bottomBar
                    }
                }
        }
        .navigationViewStyle(.stack)
        .disabled(self.model.waitingText != nil)
        .overlay {
            if let text = self.model.waitingText{
                ProgressView(text)
                    .padding(24)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .textInputAlert("新建文件夹", isPresented: self.$model.isShowCreateFolder, text: self.$model.newFolderName, placeholder: "文件夹名", confirm: "创建") {
            self.model.createFolder($0)
        }
        .alert(self.model.errorTitle, isPresented: self.$model.isShowError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(self.model.errorMessage)
        }
        .task {
            await self.model.load()
        }
    }

    @ViewBuilder
    private var content: some View {
        if self.model.login == nil{
            self.message("请先打开DairoDFS登录")
        } else if let error = self.model.loadError{
            VStack(spacing: 16) {
                Text(error)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("重试") {
                    Task {
                        await self.model.load()
                    }
                }
                if !self.model.folder.isEmpty{
                    Button("回到根目录") {
                        self.model.open("")
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if self.model.isLoading{
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                if !self.model.folder.isEmpty{
                    Button {
                        self.model.open(self.model.parentFolder)
                    } label: {
                        Label("返回上一级", systemImage: "arrow.turn.up.left")
                    }
                }
                ForEach(self.model.folders, id: \.self) { name in
                    Button {
                        self.model.open(self.model.folder + "/" + name)
                    } label: {
                        HStack {
                            Label(name, systemImage: "folder.fill")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .overlay {
                if self.model.folders.isEmpty && self.model.folder.isEmpty{
                    self.message("没有文件夹,将上传到根目录")
                }
            }
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 8) {
            Text("上传到:" + (self.model.folder.isEmpty ? "/" : self.model.folder))
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.head)
            Button {
                self.model.upload()
            } label: {
                Text("上传到这里")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(self.model.isLoading || self.model.loadError != nil)
        }
        .padding()
        .background(.bar)
    }

    private func message(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@MainActor
final class ShareFolderViewModel: ObservableObject {

    let login = ShareUploadStore.login

    /// 当前文件夹,空字符串表示根目录
    @Published private(set) var folder = ShareUploadStore.lastFolder

    /// 当前文件夹下的子文件夹名
    @Published private(set) var folders = [String]()

    @Published private(set) var isLoading = false

    @Published private(set) var loadError: String?

    /// 正在保存文件或创建文件夹时显示的文字,nil表示没有在处理
    @Published private(set) var waitingText: String?

    @Published var isShowError = false

    @Published private(set) var errorTitle = ""

    @Published private(set) var errorMessage = ""

    let onCancel: () -> Void

    private let onUpload: (_ folder: String) async throws -> Void

    /// 是否显示新建文件夹的输入框
    @Published var isShowCreateFolder = false

    /// 新建文件夹的名字
    @Published var newFolderName = ""

    /// 上次分享时选择的文件夹,打开失败时回到根目录
    private var lastFolder = ShareUploadStore.lastFolder

    /// 正在加载的请求,切换文件夹时取消
    private var loadTask: Task<Void, Never>?

    init(onCancel: @escaping () -> Void, onUpload: @escaping (_ folder: String) async throws -> Void) {
        self.onCancel = onCancel
        self.onUpload = onUpload
    }

    var title: String {
        return self.folder.isEmpty ? "选择上传位置" : (self.folder as NSString).lastPathComponent
    }

    var parentFolder: String {
        guard let index = self.folder.lastIndex(of: "/") else{
            return ""
        }
        return String(self.folder[..<index])
    }

    func open(_ folder: String) {
        self.folder = folder
        self.loadTask?.cancel()
        self.loadTask = Task {
            await self.load()
        }
    }

    func load() async {
        guard let login = self.login else{
            return
        }
        let folder = self.folder
        self.isLoading = true
        self.loadError = nil
        do {
            let folders = try await ShareFolderApi.folders(login, folder: folder)
            guard folder == self.folder else{
                return
            }
            self.folders = folders
            self.isLoading = false
        } catch is CancellationError {
        } catch let error as URLError where error.code == .cancelled {
        } catch is ShareFolderApi.ServerError where !folder.isEmpty && folder == self.folder && folder == self.lastFolder {

            //上次选择的文件夹可能已经被删除,服务器返回错误时回到根目录,网络问题时显示错误让用户重试
            self.lastFolder = ""
            ShareUploadStore.lastFolder = ""
            self.open("")
        } catch {
            guard folder == self.folder else{
                return
            }
            self.isLoading = false
            self.loadError = error.localizedDescription
        }
    }

    func upload() {
        self.waitingText = "正在保存文件"
        Task {
            do {
                try await self.onUpload(self.folder)
            } catch {
                self.waitingText = nil
                self.showError("上传失败", error)
            }
        }
    }

    /// 在当前文件夹下新建文件夹,成功之后进入新文件夹
    func createFolder(_ name: String) {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, let login = self.login else{
            return
        }
        guard !name.contains("/") else{
            self.showError("创建文件夹失败", ShareUploadError("文件夹名不能包含/"))
            return
        }
        let folder = self.folder + "/" + name
        self.waitingText = "正在创建文件夹"
        Task {
            do {
                try await ShareFolderApi.createFolder(login, folder: folder)
                self.waitingText = nil
                self.open(folder)
            } catch {
                self.waitingText = nil
                self.showError("创建文件夹失败", error)
            }
        }
    }

    private func showError(_ title: String, _ error: Error) {
        self.errorTitle = title
        self.errorMessage = error.localizedDescription
        self.isShowError = true
    }
}

/// 分享扩展里用到的接口
enum ShareFolderApi {

    /// 服务器返回的错误,不包括网络问题和登录失效
    struct ServerError: LocalizedError {
        let msg: String

        var errorDescription: String? {
            return self.msg
        }
    }

    private struct ListModel: Decodable {
        let list: [Item]
    }

    private struct Item: Decodable {
        let name: String
        let fileFlag: Bool
    }

    /// 表单验证失败时的返回内容
    private struct FormFailModel: Decodable {
        let msg: String?
        let data: [String : [String]]?
    }

    /// 创建文件夹
    /// - Parameter folder 文件夹完整路径
    static func createFolder(_ login: ShareLogin, folder: String) async throws {
        guard let url = URL(string: login.domain + "/api/files/create_folder") else{
            throw ShareUploadError("服务器地址不正确:" + login.domain)
        }
        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "folder", value: folder)]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.setValue("Bearer " + login.token, forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        //URLComponents不会编码+,服务器会把它当成空格
        request.httpBody = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B").data(using: .utf8)
        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        if statusCode == 401{
            throw ShareUploadError("登录已失效,请打开DairoDFS重新登录")
        }
        guard statusCode == 200 else{
            throw ShareUploadError(ShareFolderApi.failMessage(data) ?? "创建文件夹失败(\(statusCode))")
        }
    }

    /// 服务器返回的错误信息,表单验证失败时优先显示字段的错误信息
    private static func failMessage(_ data: Data) -> String? {
        if let model = try? JSONDecoder().decode(FormFailModel.self, from: data){
            return model.data?.values.first{ !$0.isEmpty }?.first ?? model.msg
        }
        let msg = String(data: data, encoding: .utf8) ?? ""
        return msg.isEmpty ? nil : msg
    }

    /// 获取文件夹下的子文件夹名
    static func folders(_ login: ShareLogin, folder: String) async throws -> [String] {
        guard var components = URLComponents(string: login.domain + "/api/files/list") else{
            throw ShareUploadError("服务器地址不正确:" + login.domain)
        }
        components.queryItems = [URLQueryItem(name: "folder", value: folder)]

        //URLComponents不会编码+,服务器会把它当成空格
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        guard let url = components.url else{
            throw ShareUploadError("服务器地址不正确:" + login.domain)
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.setValue("Bearer " + login.token, forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        if statusCode == 401{
            throw ShareUploadError("登录已失效,请打开DairoDFS重新登录")
        }
        guard statusCode == 200 else{
            throw ServerError(msg: ShareFolderApi.failMessage(data) ?? "获取文件夹失败(\(statusCode))")
        }
        guard let model = try? JSONDecoder().decode(ListModel.self, from: data) else{
            throw ShareUploadError("服务器返回数据格式不正确")
        }
        return model.list.filter{ !$0.fileFlag }.map{ $0.name }
    }
}
