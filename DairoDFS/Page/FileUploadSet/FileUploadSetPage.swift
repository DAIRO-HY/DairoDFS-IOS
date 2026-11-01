//
//  FileUploadSetPage.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/15.
//

import SwiftUI
import DairoUI_IOS

struct FileUploadSetPage: View {
    @State private var showDeleteAlert = false
    
    /// 同时上传文件数
    @State private var maxUploadingCount = SettingShared.fileSdkMaxUploadingCount > 0 ? SettingShared.fileSdkMaxUploadingCount : 1
    
    /// 同时上传文件数模版
    private let uploadAsyncCountDemo = [1,2,3,4,5].map{
        SettingPickerData("\($0)",$0)
    }
    
    var body: some View {
        SettingStack(embedInNavigationStack: false){
            SettingPage(navigationTitleDisplayMode:.inline){
                SettingGroup{
                    SettingPicker("同时上传文件数",data: self.uploadAsyncCountDemo, value: self.$maxUploadingCount){ value in
                        SettingShared.fileSdkMaxUploadingCount = value
                        (try? FileSdkUtil.get())?.setMaxUploadingCount(count: UInt32(value))
                        return true
                    }
                    .icon("square.and.arrow.down.fill", backgroundColor: Color.red)
                }
            }
        }
        .navigationTitle("上传设置")
    }
}

#Preview {
    FileUploadSetPage()
}
