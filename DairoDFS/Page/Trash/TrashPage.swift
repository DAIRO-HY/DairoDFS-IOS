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
                            TrashItemView(item)
                        }
                        .buttonStyle(.row)
                    }
                }
            }
            .frame(maxHeight: .infinity)
            TrashOptionView().environmentObject(self.vm)
        }
        .navigationTitle("回收站")
    }
}
