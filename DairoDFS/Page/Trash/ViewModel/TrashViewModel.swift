//
//  FileViewModel.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import Foundation
import SwiftUI
import DairoUI_IOS

class TrashViewModel : ObservableObject{
    
    ///记录当前选中的文件数
    @Published var selectedCount = 0
    
    /// 回收站数据列表
    @Published var entities = [TrashEntity]()
    
    init(){
        self.loadData()
    }
    
    ///加载数据
    func loadData(){
        TrashApi.getList().post{
            var entities = [TrashEntity]()
            for item in $0{
                entities.append(TrashEntity(item))
            }
            self.entities = entities
            self.clearSelected()
        }
    }
    
    /**
     清空已经选择的文件
     */
    func clearSelected(){
        for item in self.entities{
            item.isSelected = false
        }
        self.selectedCount = 0
    }
    
    /**
     全选
     */
    func selectAll(){
        for item in self.entities{
            item.isSelected = true
        }
        self.selectedCount = self.entities.count
    }
    
    /// 删除按钮点击事件
    func onDeleteClick(){
        TrashApi.logicDelete(ids: self.entities.filter{$0.isSelected}.map{$0.fm.id}).post {
            Toast.show("操作成功")
            self.loadData()
        }
    }
    
    /// 还原按钮点击事件
    func onRecoverClick(){
        TrashApi.trashRecover(ids: self.entities.filter{$0.isSelected}.map{$0.fm.id}).post {
            Toast.show("操作成功")
            self.loadData()
        }
    }
    
    deinit{
        debugPrint("-->TrashViewModel.deinit")
    }
}
