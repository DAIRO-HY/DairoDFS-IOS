//
//  FileOptionBarView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI

struct SystemAlbumOptionView: View {
    
    @EnvironmentObject var vm: SystemAlbumViewModel
    
    var body: some View {
        VStack(spacing: 8){
            if let msg = self.vm.uploadCountMsg{//上传数量通知
                Divider()
                HStack{
                    Text(msg).foregroundColor(.secondary)
                    Spacer()
                    if self.vm.isUploading{//正在上传中,显示取消按钮
                        Button(action: {
                            
                            //取消所有上传操作
                            PHAssetUploadManager.cancel()
                        }){
                            Text("取消")
                        }
                    }
                }.padding(.horizontal, 5)
            }
            Divider()
            HStack{
                Text("排序:").foregroundColor(.secondary)
                self.sortBtn("名称")
                self.sortBtn("时间")
                self.sortBtn("大小")
                self.sortBtn("类型")
                Spacer()
            }.padding(.horizontal, 5)
            Divider()
            HStack{
                UCOptionMenuButton("全选", icon: "checklist.checked", action: self.vm.onCheckAllClick)
                UCOptionMenuButton("上传", icon: "square.and.arrow.up", disabled: self.vm.checkedCount == 0 || self.vm.isUploading){
                    self.vm.onUploadClick(false)
                }
                if self.vm.uploadMode == .album{// 只有相册同步模式才允许检查
                    UCOptionMenuButton("同步检查", icon: "square.and.arrow.up"){
                        self.vm.onUploadClick(true)
                    }
                }
                UCOptionMenuButton("删除已上传", icon: "trash", disabled: self.vm.isUploading, action: self.vm.onDeleteClick)
            }
        }.onReceive(NotificationCenter.default.publisher(for: Notification.Name(PHAssetUploadManager.NOTIFY_UPLOAD_COUNT))){
            self.vm.uploadCountMsg = $0.object as! String
        }.onReceive(NotificationCenter.default.publisher(for: Notification.Name(PHAssetUploadManager.NOTIFY_UPLOAD_PROGRESS))){
            let values = $0.object as! Array<String>
            let localIdentifier = values[0]
            let uploadMsg = values[1]
            
            //当前文件所在序号
            guard let index = self.vm.identifier2index[localIdentifier] else{
                return
            }
            self.vm.albumList[index].uploadMsg = uploadMsg
        }.onReceive(NotificationCenter.default.publisher(for: Notification.Name(PHAssetUploadManager.NOTIFY_UPLOAD_ITEM_FINISH))){
            let values = $0.object as! Array<String>
            let localIdentifier = values[0]
            let uploadMsg = values[1]
            
            //当前文件所在序号
            guard let index = self.vm.identifier2index[localIdentifier] else{
                return
            }
            self.vm.albumList[index].uploadMsg = uploadMsg
        }.onReceive(NotificationCenter.default.publisher(for: Notification.Name(PHAssetUploadManager.NOTIFY_UPLOAD_FINISH))){ _ in
            self.vm.isUploading = false
        }
    }
    
    /**
     排序按钮
     */
    private func sortBtn(_ label: String) -> some View{
        return Button(action:{
            
        }){
            Text(label)
        }.buttonStyle(.row)
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
