//
//  ImageViewerDragViewModel.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/07.
//


import SwiftUI
import DairoUI_IOS

class ImageViewerDragViewModel: ObservableObject{
    
    /**
     * 正在缩放比例
     */
    @Published var zoomingAmount: CGFloat = 1
    
    /**
     * 缩放比例
     */
    @Published var zoomAmount: CGFloat = 1.0
    
    /**
     * 正在移动中的偏移位置
     */
    @Published var currentOffsetPosition: CGSize = .zero
    
    /**
     * 记录上一次移动的位置
     */
    @Published var preOffsetPosition: CGSize = .zero
    
    /**
     * 当前图片
     */
    @Published var uiImage: UIImage? = nil
    
    /**
     * 图片宽高比
     */
    var uiImageWHRate: CGFloat
    
    /**
     * 屏幕宽高比
     */
    var screenWHRate: CGFloat
    
    //当前视图区域的尺寸
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    //没有缩放状态下的显示宽与高
    var displayW1: CGFloat
    var displayH1: CGFloat
    
    var pageVM: ImageViewerViewModel
    
    init(_ pageVM: ImageViewerViewModel) {
        self.pageVM = pageVM
        
        //屏幕宽高比
        self.screenWHRate = self.screenWidth / self.screenHeight
        
        
        //为了保证图片未加载时也能正常切换,默认将屏幕大小作为图片大小
        self.displayW1 = self.screenWidth
        self.displayH1 = self.screenHeight
        
        //图片宽高比
        self.uiImageWHRate = self.screenWidth / self.screenHeight
    }
    
    private func initVlaue(){
        self.zoomAmount = 1.0
    }
    
    /**
     双击事件
     */
    func doubleClick(){
        if self.zoomAmount > 1{
            withAnimation{
                self.zoomAmount = 1
            }
        } else {
            withAnimation{
                self.zoomAmount = self.screenHeight / self.displayH1
            }
        }
    }
    
    func setImage(_ uiImage: UIImage){
        self.uiImage = uiImage
        
        //图片宽高比
        self.uiImageWHRate = uiImage.size.width / uiImage.size.height
        
        if self.uiImageWHRate > self.screenWHRate {//图片的宽高比大于屏幕的宽高比,则没有放大缩小的状态下,显示的宽度为屏幕宽度
            self.displayW1 = self.screenWidth
            self.displayH1 = self.displayW1 / self.uiImageWHRate
        } else {//图片的宽高比小于屏幕的宽高比,则没有放大缩小的状态下,显示的高度为屏幕的高度
            self.displayH1 = self.screenHeight
            self.displayW1 = self.displayH1 * self.uiImageWHRate
        }
    }
    
    func setUrl(_ url: String){
        self.initVlaue()
        if let imagePath = CacheImageHelper.getDownloadedPath(url: url, folder: CacheImage.mCacheFolder){
            if let uiImage = UIImage(contentsOfFile: imagePath){
                self.setImage(uiImage)
            }
            return
        }
        CacheImageHelper.add(url: url, folder: CacheImage.mCacheFolder)
    }
    
    
    /**
     计算拖拽偏移位置
     */
    func computeDragPosition(_ value: DragGesture.Value) -> CGSize{
        //        var width: Double
        //        if self.displayW1 * self.zoomAmount < self.screenWidth{//如果缩放后的高小于屏幕高度,则Y轴方向不要偏移
        //            width = self.preOffsetPosition.width
        //        }else{
        //            width = value.translation.width + self.preOffsetPosition.width
        //        }
        
        
        
        let height: Double
        if self.displayH1 * self.zoomAmount < self.screenHeight{//如果缩放后的高小于屏幕高度,则Y轴方向不要偏移
            height = self.preOffsetPosition.height
        }else{
            height = value.translation.height + self.preOffsetPosition.height
        }
        
        //加上self.newPosition的目的是让图片从上次的位置开始移动
        var offset = CGSize(width: value.translation.width + self.preOffsetPosition.width, height: height)
        
        let offsetMinWidth = (self.displayW1 * self.zoomAmount - self.screenWidth) / 2
        if offset.width < -offsetMinWidth{//X轴右边越界
            self.pageVM.hStackOffset = -CGFloat(self.pageVM.currentIndex) * self.screenWidth + (offset.width - offsetMinWidth)
//            print("-->X轴左边越界")
            
            //X轴左边越界之后,禁止仅需拖拽,此时应该响应父控件的拖拽
            offset.width = -offsetMinWidth
        } else if offset.width > offsetMinWidth{//X轴左边越界
            self.pageVM.hStackOffset = -CGFloat(self.pageVM.currentIndex) * self.screenWidth + (offset.width - offsetMinWidth)
//            print("-->X轴右边越界:\(offset.width - offsetMinWidth)")
            
            //X轴左边越界之后,禁止仅需拖拽,此时应该响应父控件的拖拽
            offset.width = offsetMinWidth
        }
        return offset
        //        return CGSize(width: value.translation.width + self.preOffsetPosition.width, height: value.translation.height + self.preOffsetPosition.height)
    }
    
    /**
     * 修复裁剪范围
     */
    func fixCropImage() {
        if self.zoomAmount < 1{//手动缩小比例不能小于最小缩小比例
            self.zoomAmount = 1
        }
        
        //当前偏移
        var offset = self.currentOffsetPosition
        if self.displayW1 * self.zoomAmount < self.screenWidth{//如果缩放后的高小于屏幕宽度,则将图片屏幕水平居中(x轴偏移0)
            offset = CGSize(width: 0, height: offset.height)
        } else {
            let offsetMinWidth = (self.displayW1 * self.zoomAmount - self.screenWidth)/2
            if offset.width < -offsetMinWidth{//X轴左方越界
                offset = CGSize(width: -offsetMinWidth, height: offset.height)
            }else if offset.width > offsetMinWidth{//X轴右方越界
                offset = CGSize(width: offsetMinWidth, height: offset.height)
            }
        }
        
        
        if self.displayH1 * self.zoomAmount < self.screenHeight{//如果缩放后的高小于屏幕高度,则将图片屏幕垂直居中(y轴偏移0)
            offset = CGSize(width: offset.width, height: 0)
        } else {
            
            //拖动到边界计算
            let offsetMinHeight = (self.displayH1 * self.zoomAmount - self.screenHeight)/2
            if offset.height < -offsetMinHeight{//y轴上方越界
                offset = CGSize(width: offset.width, height: -offsetMinHeight)
            } else if offset.height > offsetMinHeight{//y轴下方越界
                offset = CGSize(width: offset.width, height: offsetMinHeight)
            }
        }
        self.currentOffsetPosition = offset
        self.preOffsetPosition = offset
        
        self.pageVM.fixPageViewPosition()
    }
    
    func recycle(){
        self.uiImage = nil
    }
    
    deinit{
        print("-->ImageViewerDragViewModel.deinit")
    }
}
