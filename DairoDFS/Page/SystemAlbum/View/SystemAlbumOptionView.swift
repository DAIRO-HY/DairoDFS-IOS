//
//  FileOptionBarView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI
import DairoFileSDK

struct SystemAlbumOptionView: View {
    
    @EnvironmentObject var vm: SystemAlbumViewModel
    
    var body: some View {
        VStack(spacing: 8){
            if let msg = self.vm.uploadCountMsg{//上传数量通知
                HStack{
                    Text(msg)
                        .font(.footnote)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .liquidGlassBackground(in: Capsule())
                    Spacer()
                    if self.vm.isUploading{//正在上传中,显示取消按钮
                        Button(action: {
                            
                            //取消所有上传操作
                            self.vm.onCancelClick()
                        }){
                            Text("取消")
                                .font(.footnote)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .liquidGlassBackground(in: Capsule(), interactive: true)
                        }
                    }
                }.padding(.horizontal)
            }
            HStack{
                OptionButton("全选", icon: "checklist.checked", action: self.vm.onCheckAllClick)
                OptionButton("上传", icon: "square.and.arrow.up", disabled: self.vm.checkedCount == 0 || self.vm.isUploading){
                    self.vm.onUploadClick(false)
                }
                if self.vm.uploadMode == .album{// 只有相册同步模式才允许检查
                    OptionButton("同步检查", icon: "square.and.arrow.up"){
                        self.vm.onUploadClick(true)
                    }
                }
                OptionButton("删除已上传", icon: "trash", disabled: self.vm.isUploading, action: self.vm.onDeleteClick)
            }
        }
        .padding(.vertical, 8)
        .onReceive(NotificationCenter.default.publisher(for: FileSdkUtil.EVENT)){
            self.vm.onFileSdkEvent($0.object as! Event)
        }
    }
}

//#Preview {
//    FileOptionView_preview()
//}
//
//private struct FileOptionView_preview: View {
//
//    @StateObject var fileVm = FileViewModel()
//
//    var body: some View {
//        AlbumSyncOptionView().environmentObject(self.fileVm)
//    }
//}
