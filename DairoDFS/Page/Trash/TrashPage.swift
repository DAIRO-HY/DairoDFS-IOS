//
//  TashPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/22.
//

import SwiftUI
import DairoUI_IOS

struct TrashPage: View {
    
    @StateObject var vm = TrashViewModel()
    
    var body: some View {
        VStack{
            ScrollView{
                LazyVStack{
                    ForEach(self.vm.entities, id: \.self.fm.id) { item in
                        Button(action: {
                            item.isSelected.toggle()
                            self.vm.selectedCount += (item.isSelected ? 1 : -1)
                        }){
                            TrashItemView(item, isSelected: item.isSelected)
                        }
                        .buttonStyle(.row)
                    }
                }
            }
            .frame(maxHeight: .infinity)
            
            //操作按钮浮在列表上面
            .safeAreaInset(edge: .bottom, spacing: 0){
                TrashOptionView().environmentObject(self.vm)
            }
        }
        .navigationTitle("回收站")
    }
}
