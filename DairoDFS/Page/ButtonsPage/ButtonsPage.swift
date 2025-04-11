//
//  ButtonsPage.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/11.
//

import SwiftUI
import DairoUI_IOS

struct ButtonsPage: View {
    var body: some View {
        VStack{
            UCButton.primary("主调色按钮"){
                
            }
            UCButton.secondary("次要按钮"){
                
            }
        }.padding()
    }
}

#Preview {
    ButtonsPage()
}
