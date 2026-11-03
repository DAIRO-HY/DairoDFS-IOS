//
//  AlbumViewerTouchView.swift
//  DairoDFS
//
//  Created by zhoulq on 2026/11/03.
//

import SwiftUI
import UIKit
import UIKit.UIGestureRecognizerSubclass

/// 查看页面的手势操作视图
/// 使用UIKit的手势,因为iOS15的SwiftUI取不到双指的中心点,拖动也要移动一段距离才开始响应
struct AlbumViewerTouchView: UIViewRepresentable {
    
    let vm: AlbumViewerViewModel
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self.vm)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let coordinator = context.coordinator
        
        let doubleTap = UITapGestureRecognizer(target: coordinator, action: #selector(Coordinator.onDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        let tap = UITapGestureRecognizer(target: coordinator, action: #selector(Coordinator.onTap))
        tap.require(toFail: doubleTap)
        let drag = AlbumViewerDragGestureRecognizer(target: coordinator, action: #selector(Coordinator.onDrag))
        let pinch = UIPinchGestureRecognizer(target: coordinator, action: #selector(Coordinator.onPinch))
        let longPress = UILongPressGestureRecognizer(target: coordinator, action: #selector(Coordinator.onLongPress))
        longPress.minimumPressDuration = 0.4
        
        coordinator.pinch = pinch
        coordinator.longPress = longPress
        coordinator.taps = [tap, doubleTap]
        coordinator.drag = drag
        drag.onTouchDown = { [weak coordinator] in
            coordinator?.onTouchDown()
        }
        for gesture in [doubleTap, tap, drag, pinch, longPress]{
            gesture.delegate = coordinator
            view.addGestureRecognizer(gesture)
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.vm = self.vm
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        
        /// 单击时手指允许移动的距离
        private static let TAP_MAX_MOVE: CGFloat = 10
        
        var vm: AlbumViewerViewModel
        
        weak var pinch: UIPinchGestureRecognizer?
        weak var longPress: UILongPressGestureRecognizer?
        
        weak var drag: UIGestureRecognizer?
        
        /// 单击和双击手势
        var taps = [UIGestureRecognizer]()
        
        /// 拖动时是否已经取消了单击和双击
        private var isTapsCancelled = false
        
        /// 上一次拖动的位置
        private var lastDragPoint = CGPoint.zero
        
        /// 上一次双指的中心点,只剩一个手指时为nil,这时不移动图片,否则中心点变化会让图片跳动
        private var lastPinchCenter: CGPoint?
        
        init(_ vm: AlbumViewerViewModel) {
            self.vm = vm
        }
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            if gestureRecognizer === self.pinch{//视频不支持缩放
                return self.vm.isImage
            }
            if gestureRecognizer === self.longPress{//只在视频播放时生效,其他情况不影响拖动
                return self.vm.videoIsPlaying
            }
            return true
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
        /// 手指按下时停止惯性滑动,这次点击只用来停止,不算单击
        func onTouchDown(){
            if self.vm.isInertiaRunning{
                self.vm.stopInertiaByTouch()
                self.cancel(self.taps)
            }
        }
        
        @objc func onTap(){
            self.vm.showActionView.toggle()
        }
        
        @objc func onDoubleTap(_ gesture: UITapGestureRecognizer){
            guard let view = gesture.view else{
                return
            }
            let point = gesture.location(in: view)
            if self.vm.isVideo{
                let isLeft = point.x < view.bounds.width / 2
                self.vm.onVideoSeek(isLeft ? -AlbumViewerViewModel.VIDEO_SEEK_SECONDS : AlbumViewerViewModel.VIDEO_SEEK_SECONDS)
            } else {
                self.vm.doubleClick(point)
            }
        }
        
        @objc func onDrag(_ gesture: AlbumViewerDragGestureRecognizer){
            let point = gesture.location(in: gesture.view)
            switch gesture.state{
            case .began:
                self.isTapsCancelled = false
                self.vm.onImageDrag(CGSize(width: point.x - gesture.startPoint.x, height: point.y - gesture.startPoint.y))
            case .changed:
                self.vm.onImageDrag(CGSize(width: point.x - self.lastDragPoint.x, height: point.y - self.lastDragPoint.y))
                
                //单击手势允许手指移动较大的距离,这里移动一小段距离就取消,否则短距离快速滑动也会触发单击
                if !self.isTapsCancelled && hypot(point.x - gesture.startPoint.x, point.y - gesture.startPoint.y) > Coordinator.TAP_MAX_MOVE{
                    self.isTapsCancelled = true
                    self.cancel(self.taps)
                }
            case .ended, .cancelled:
                self.vm.onImageDragEnd(gesture.state == .ended ? gesture.velocity : .zero)
            default:
                break
            }
            self.lastDragPoint = point
        }
        
        @objc func onPinch(_ gesture: UIPinchGestureRecognizer){
            switch gesture.state{
            case .began, .changed:
                if gesture.numberOfTouches < 2{
                    self.lastPinchCenter = nil
                    gesture.scale = 1
                    return
                }
                let center = gesture.location(in: gesture.view)
                let last = self.lastPinchCenter ?? center
                self.vm.onImagePinch(gesture.scale, center: center, translation: CGSize(width: center.x - last.x, height: center.y - last.y))
                gesture.scale = 1
                self.lastPinchCenter = center
            case .ended, .cancelled:
                self.vm.onImagePinchEnd(self.lastPinchCenter ?? gesture.location(in: gesture.view))
                self.lastPinchCenter = nil
            default:
                break
            }
        }
        
        @objc func onLongPress(_ gesture: UILongPressGestureRecognizer){
            switch gesture.state{
            case .began:
                self.vm.onVideoSpeedUpChange(true)
                
                //否则手指移动时会切换页面,松手时会触发单击
                self.cancel(self.taps + [self.drag].compactMap{ $0 })
            case .ended, .cancelled:
                self.vm.onVideoSpeedUpChange(false)
            default:
                break
            }
        }
        
        /// 取消正在进行中的手势,先禁用再启用就会取消
        private func cancel(_ gestures: [UIGestureRecognizer]){
            for it in gestures{
                it.isEnabled = false
                it.isEnabled = true
            }
        }
    }
}

/// 单指拖动手势,移动很小的距离就开始响应,系统的UIPanGestureRecognizer要移动约10pt才开始
class AlbumViewerDragGestureRecognizer: UIGestureRecognizer {
    
    /// 开始响应的距离
    private static let THRESHOLD: CGFloat = 2
    
    /// 计算速度用的时间范围(秒),松手前停顿超过这个时间时速度为0
    private static let VELOCITY_TIME: TimeInterval = 0.1
    
    /// 手指按下的位置
    private(set) var startPoint = CGPoint.zero
    
    /// 手指按下时执行
    var onTouchDown: (() -> Void)?
    
    /// 最近的手指位置
    private var samples = [(time: TimeInterval, point: CGPoint)]()
    
    /// 松手时手指的速度(pt/秒),向右、向下为正
    var velocity: CGSize {
        guard let first = self.samples.first, let last = self.samples.last, last.time > first.time else{
            return .zero
        }
        let time = CGFloat(last.time - first.time)
        return CGSize(width: (last.point.x - first.point.x) / time, height: (last.point.y - first.point.y) / time)
    }
    
    /// 记录手指位置,只保留最近的
    private func addSample(_ touches: Set<UITouch>){
        guard let touch = touches.first else{
            return
        }
        self.samples.append((touch.timestamp, touch.location(in: self.view)))
        self.samples.removeAll{ touch.timestamp - $0.time > AlbumViewerDragGestureRecognizer.VELOCITY_TIME }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        self.onTouchDown?()
        if self.numberOfTouches > 1 || touches.count > 1{//多个手指时是缩放,不是拖动
            self.state = (self.state == .possible) ? .failed : .ended
            return
        }
        self.startPoint = self.location(in: self.view)
        self.samples.removeAll()
        self.addSample(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        self.addSample(touches)
        if self.state == .possible{
            let point = self.location(in: self.view)
            if hypot(point.x - self.startPoint.x, point.y - self.startPoint.y) >= AlbumViewerDragGestureRecognizer.THRESHOLD{
                self.state = .began
            }
        } else {
            self.state = .changed
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        self.addSample(touches)
        self.state = (self.state == .possible) ? .failed : .ended
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = (self.state == .possible) ? .failed : .cancelled
    }
}
