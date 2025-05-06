//
//  ImageViewerViewModel.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/05.
//

import Foundation
import UIKit

class ImageViewerViewModel: ObservableObject{
    
    //当前视图区域的尺寸
    let screenWidth = UIScreen.main.bounds.width
    
    ///预览图列表
    var entitys = [ImageViewerEntity]()
    
    ///当前选中的序号
    @Published var index = 0
    
    ///用来保存HStack显示偏移量,使其HStack准确显示当前控件位置
    @Published var hStackOffset: CGFloat = 0
    
    /**
     * 当前图片
     */
    var inputImage: UIImage?
    
    func setEntitys(_ entitys: [ImageViewerEntity], index: Int = 0){
        self.entitys = entitys
        self.index = index
        self.hStackOffset = -CGFloat(self.index) * self.screenWidth
    }
    
    ///得到文件预览url
    func preview(_ i: Int) -> String{
        let entity = self.entitys[i]
        let baseUrl = SettingShared.domainNotNull + "/app/files/preview/\(entity.id)/\(entity.name)?_token=" + SettingShared.token
        
        let lowerName = entity.name.lowercased()
        if entity.name.hasSuffix(".cr3"){
            return baseUrl + "&extra=preview"
        }
        return baseUrl
    }
    
    func fixPageViewPosition(){
        
        let threshold = self.screenWidth / 2
        
        //本次拖拽的距离 = 当前页偏移位置 - 上页偏移位置
        let dragDistance = (-CGFloat(self.index) * self.screenWidth) - self.hStackOffset
        
        var currentPage = self.index
        if dragDistance < -threshold, currentPage < self.entitys.count - 1 {
            currentPage -= 1
        } else if dragDistance > threshold, currentPage > 0 {
            currentPage += 1
        }
        if currentPage != self.index{//如果页面要切换
            self.hStackOffset = -CGFloat(currentPage) * self.screenWidth
            Task{
                await Task.sleep(200_000_000)
                await MainActor.run{
                    self.index = currentPage
                    //                                        self.updateVm()
                }
            }
        } else if dragDistance != 0{//拖拽距离达不到页面迁移的标准,则回弹
            self.hStackOffset = -CGFloat(currentPage) * self.screenWidth
        }
    }
    
    deinit{
        print("-->ImageViewerViewModel.deinit")
    }
}
