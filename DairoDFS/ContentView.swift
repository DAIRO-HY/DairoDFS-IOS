//
//  ContentView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/09.
//  pushtest

import SwiftUI
struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(["按钮","分组按钮","相册"], id: \.self) { label in
                        NavigationLink(destination: {
                            switch label{
                            case "按钮":
                                ButtonsPage()
                            default:
                                EmptyView()
                            }
                        }) {
                            Text(label)
                        }
                        //                            let imageInfo = viewModel.images[index]
                        //                            Button(action:{
                        //                                viewModel.delete(assets: [viewModel.images[0].asset,viewModel.images[1].asset,viewModel.images[2].asset,viewModel.images[3].asset])
                        //                            }){
                        //                                VStack{
                        //                                    Image(uiImage: imageInfo.image)
                        //                                        .resizable()
                        //                                        .scaledToFill()
                        //                                        .frame(width: 100, height: 100)
                        //                                        .clipped()
                        //        //                            Text("\(index)-\(getAssetFileExtension(imageInfo.asset)!)-\(Costom.getCostom())")
                        //                                    Text("\(index)-\(getAssetFileExtension(imageInfo.asset)!)")
                        //                                }
                        //                            }
                        //                        }
                    }
                    .padding()
                }
            }.navigationTitle("首页")
        }
    }
}


#Preview {
    ContentView()
}
