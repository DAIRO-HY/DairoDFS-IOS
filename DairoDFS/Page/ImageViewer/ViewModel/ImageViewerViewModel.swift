//
//  ImageViewerViewModel.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/05.
//

import Foundation
import UIKit

//@TODO: deinit函数尚未调用,待解决
class ImageViewerViewModel: ObservableObject{
    
    ///页面切换动画时间(秒)
    ///该时间不宜过长,过长可能导致用户快速切换时显示的图片错乱
    ///该时间也不宜过短,过短会让页面闪烁一下,看起来不爽
    static let ANIMATION_TIME: Double = 0.15
    
    //当前视图区域的尺寸
    let screenWidth = UIScreen.main.bounds.width
    
    ///预览图列表
    var entitys = [ImageViewerEntity]()
    
    ///当前选中的序号
    @Published var currentIndex = 0
    
    ///用来保存HStack显示偏移量,使其HStack准确显示当前控件位置
    @Published var hStackOffset: CGFloat = 0
    
    func setEntitys(_ entitys: [ImageViewerEntity], index: Int = 0){
        self.entitys = entitys
        self.currentIndex = index
        self.hStackOffset = -CGFloat(self.currentIndex) * self.screenWidth
    }
    
    ///得到文件预览url
    func preview(_ i: Int) -> String{
        let entity = self.entitys[i]
        let baseUrl = SettingShared.domainNotNull + "/app/files/preview/\(entity.id)/\(entity.name)?_token=" + SettingShared.token
        
        let lowerName = entity.name.lowercased()
        if lowerName.hasSuffix(".cr3"){
            return baseUrl + "&extra=preview"
        }
        return baseUrl
    }
    
    func fixPageViewPosition(){
        
        let threshold = self.screenWidth / 3
        
        //本次拖拽的距离 = 当前页偏移位置 - 上页偏移位置
        let dragDistance = (-CGFloat(self.currentIndex) * self.screenWidth) - self.hStackOffset
        
        var currentIndex = self.currentIndex
        if dragDistance < -threshold && currentIndex < self.entitys.count - 1 {
            currentIndex -= 1
        } else if dragDistance > threshold && currentIndex > 0 {
            currentIndex += 1
        }
        if currentIndex != self.currentIndex{//如果页面要切换
            self.hStackOffset = -CGFloat(currentIndex) * self.screenWidth
            
            //等待动画结束之后再切换页面,防止页面跳闪
            Task{@MainActor in
                await Task.sleep(UInt64(1_000_000_000.0 * ImageViewerViewModel.ANIMATION_TIME) + 50_000_000)
                self.currentIndex = currentIndex
            }
        } else if dragDistance != 0{//拖拽距离达不到页面迁移的标准,则回弹
            self.hStackOffset = -CGFloat(currentIndex) * self.screenWidth
        }
    }
    
    deinit{
        print("-->ImageViewerViewModel.deinit")
    }
}
