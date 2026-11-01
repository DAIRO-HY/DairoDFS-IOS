//
//  FileDownloadSetPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/01.
//

import SwiftUI
import DairoUI_IOS
import DairoFileSDK

struct FileDownloadSetPage: View {
    
    /// 同时下载文件数
    @State private var maxSavingCount = SettingShared.fileSdkMaxSavingCount > 0 ? SettingShared.fileSdkMaxSavingCount : 3
    
    /// 同时缓存文件数
    @State private var maxCachingCount = SettingShared.fileSdkMaxCachingCount > 0 ? SettingShared.fileSdkMaxCachingCount : 5
    
    /// 缓存文件保存天数,0表示永久
    @State private var cacheExpireDays = SettingShared.fileSdkCacheExpireDays ?? 90
    
    /// 缓存分组统计
    @State private var stats = [GroupStats]()
    
    /// 要清理的缓存分组
    @State private var clearGroup: String?
    
    /// 同时下载文件数模版
    private let countDemo = (1...10).map{ SettingPickerData("\($0)", $0) }
    
    /// 缓存文件保存期限模版
    private let cacheExpireDayDemo = [
        SettingPickerData("1天", 1),
        SettingPickerData("1星期", 7),
        SettingPickerData("1个月(30天)", 30),
        SettingPickerData("3个月(90天)", 90),
        SettingPickerData("6个月(180天)", 180),
        SettingPickerData("1年(365天)", 365),
        SettingPickerData("永久", 0),
    ]
    
    var body: some View {
        SettingStack(embedInNavigationStack: false){
            SettingPage(navigationTitleDisplayMode:.inline){
                SettingGroup{
                    SettingPicker("同时下载文件数",data: self.countDemo, value: self.$maxSavingCount){ value in
                        SettingShared.fileSdkMaxSavingCount = value
                        (try? FileSdkUtil.get())?.setMaxSavingCount(count: UInt32(value))
                        return true
                    }
                    .icon("square.and.arrow.down.fill", backgroundColor: Color.red)
                    SettingPicker("同时缓存文件数",data: self.countDemo, value: self.$maxCachingCount){ value in
                        SettingShared.fileSdkMaxCachingCount = value
                        (try? FileSdkUtil.get())?.setMaxCachingCount(count: UInt32(value))
                        return true
                    }
                    .icon("square.and.arrow.down.fill", backgroundColor: Color.green)
                }
                SettingGroup{
                    SettingPicker("缓存文件保存期限",data: self.cacheExpireDayDemo, value: self.$cacheExpireDays){ value in
                        SettingShared.fileSdkCacheExpireDays = value
                        (try? FileSdkUtil.get())?.setCacheExpireDays(days: UInt32(value))
                        return true
                    }
                    .icon("timer.circle.fill", backgroundColor: Color.orange)
                }
                SettingGroup{
                    for it in self.stats{
                        SettingButton(self.groupLabel(it.group), tip: "\(it.count)个文件  " + Int64(it.size).fileSize){
                            self.clearGroup = it.group
                        }
                        .icon("calendar", backgroundColor: Color.cyan)
                    }
                }
            }
        }
        .onAppear(perform: self.loadStats)
        .alert("确认清理这些缓存吗？", isPresented: Binding(get: { self.clearGroup != nil }, set: { if !$0 { self.clearGroup = nil } })) {
            Button("清理", role: .destructive) {
                _ = try? FileSdkUtil.get().clearCache(group: self.clearGroup, beforeAccess: nil)
                self.loadStats()
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("此操作无法撤销")
        }
        .navigationTitle("下载设置")
    }
    
    /// 缓存分组的显示名
    private func groupLabel(_ group: String) -> String{
        switch group{
        case "file": return "原文件"
        case "thumb": return "缩略图"
        case "preview": return "预览文件"
        case "preview-dlive": return "实况预览视频"
        case "dlive": return "实况视频"
        case "property": return "文件属性"
        default: return group
        }
    }
    
    /// 加载缓存统计
    private func loadStats(){
        self.stats = (try? FileSdkUtil.get().stats(mode: .cache)) ?? []
    }
}
