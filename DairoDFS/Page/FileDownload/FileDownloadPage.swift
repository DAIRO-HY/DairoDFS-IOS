//
//  FileDownloadPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/01.
//

import SwiftUI
import DairoUI_IOS
import DairoFileSDK

struct FileDownloadPage: View {
    
    @StateObject private var vm = FileDownloadViewModel()
    
    @State private var showDeleteAlert = false
    
    /// 是否跳转设置页面
    @State private var isShowSet = false
    
    var body: some View {
        VStack(spacing: 0){
            Picker("", selection: Binding(get: { self.vm.mode }, set: { self.vm.onModeClick($0) })){
                Text("下载").tag(CacheMode.save)
                Text("缓存").tag(CacheMode.cache)
            }
            .pickerStyle(.segmented)
            .padding(8)
            ScrollView{
                LazyVStack{
                    ForEach(self.vm.list, id: \.id) { item in
                        self.itemView(item)
                    }
                }
            }
            .frame(maxHeight: .infinity)
            
            //操作按钮浮在列表上面
            .safeAreaInset(edge: .bottom, spacing: 0){
                self.optionView
            }
        }
        .navigationTitle("下载管理")
        .onReceive(NotificationCenter.default.publisher(for: FileSdkUtil.EVENT)){
            self.vm.onFileSdkEvent($0.object as! Event)
        }
        .alert("确认删除吗？", isPresented: self.$showDeleteAlert) {
            Button("删除", role: .destructive, action: self.vm.onDeleteClick)
            Button("取消", role: .cancel) { }
        } message: {
            Text("此操作无法撤销")
        }
    }
    
    /// 底部操作按钮
    private var optionView: some View{
        HStack{
            NavigationLink(destination: FileDownloadSetPage(), isActive: self.$isShowSet){
                EmptyView()
            }
            OptionButton("全选", icon: "checklist.checked", action: self.vm.onCheckAllClick)
            OptionButton("全暂停", icon: "pause.circle", disabled: self.vm.mode != .save, action: self.vm.onPauseAllClick)
            OptionButton("全开始", icon: "play.circle", disabled: self.vm.mode != .save, action: self.vm.onStartAllClick)
            OptionButton("删除(\(self.vm.checked.count))", icon: "trash", disabled: self.vm.checked.isEmpty){
                self.showDeleteAlert = true
            }
            OptionButton("设置", icon: "gearshape"){
                self.isShowSet = true
            }
        }
        .padding(.vertical, 8)
    }
    
    /// 一行文件信息
    private func itemView(_ item: CacheInfo) -> some View{
        HStack{
            Button(action:{
                self.vm.onCheckClick(item.id)
            }){
                Image(systemName: self.vm.checked.contains(item.id) ? "checkmark.circle" : "circle")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            VStack(alignment: .leading){
                Text(item.name ?? item.id).font(.body).lineLimit(1)
                if item.state == .finish{
                    Text(Int64(item.size ?? item.downloaded).fileSize).font(.footnote).foregroundColor(.secondary)
                } else {
                    ProgressView(value: Double(item.downloaded), total: Double(max(item.size ?? 0, max(item.downloaded, 1))))
                        .progressViewStyle(.linear)
                    HStack{
                        if let error = item.error{
                            Text(FileSdkUtil.friendlyError(error)).font(.footnote).foregroundColor(.red).lineLimit(1)
                        } else {
                            Text(self.progressInfo(item)).font(.footnote).foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(self.stateLabel(item.state)).font(.footnote).foregroundColor(.secondary)
                        Button(action:{
                            self.vm.onStateClick(item)
                        }){
                            Image(systemName: item.state == .waiting || item.state == .downloading ? "pause.circle" : "play.circle")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Divider()
            }
        }
        .padding(.horizontal)
    }
    
    /// 下载进度信息
    private func progressInfo(_ item: CacheInfo) -> String{
        let downloaded = Int64(item.downloaded).fileSize
        if let speed = self.vm.speeds[item.id]{
            return "\(downloaded)(\(Int64(speed).fileSize)/S)"
        }
        return downloaded
    }
    
    /// 下载状态文字
    private func stateLabel(_ state: DownloadState) -> String{
        switch state{
        case .waiting: return "等待下载"
        case .downloading: return "下载中"
        case .paused: return "已暂停"
        case .error: return "下载失败"
        case .finish: return "下载完成"
        }
    }
}
