//
//  JBImageBrowserView.swift
//  JBImageBrowserView
//
//  Created by JimBo on 16/2/17.
//  Copyright © 2016年 JimBo. All rights reserved.
//

import UIKit
import Kingfisher

enum panDirection{
    case upDirection
    case downDirection
}


public class JBImageBrowserViewController: UIViewController {

    private var imageList:[JBImage]!
    private let defaultZoomScale:CGFloat = 1.0
    private let doubleTapZoomScale:CGFloat = 2.0
    private let maxZoomScale:CGFloat = 3.0
    private var defaultAnimationDuration = 0.15
    private var transitionDirection:panDirection = .upDirection
    private var currentPageIndex = 0
    
    //加载失败占位图
    private var failedPlaceholderImage:UIImage?
    
    private var pageScrollView:UIScrollView
    
    
    //MARK: - view life cycle
    
    /**
    Initialize ImageBrowser with Images
    
    - parameter imageList: ListOfImage can be URL,Image
    
    - returns: JBImageBrowserViewController
    */
    public init(frame:CGRect,imageArray:[JBImage]!,failedPlaceholderImage:UIImage?) {
        
        self.imageList = imageArray
        self.failedPlaceholderImage = failedPlaceholderImage
        self.pageScrollView = UIScrollView()
        
        super.init(nibName: nil, bundle: nil)
        setupUserInterface()
        configureUserInterface()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    //MARK: - UI Setup
    
    func setupUserInterface(){
        
        pageScrollView.frame = CGRect(origin: CGPoint(x: 0,y: 0), size: CGSize(width: CGRectGetWidth(self.view.bounds), height: CGRectGetHeight(self.view.bounds)))
        pageScrollView.backgroundColor = UIColor.blackColor()
        pageScrollView.showsHorizontalScrollIndicator = false
        pageScrollView.showsVerticalScrollIndicator = false
        pageScrollView.pagingEnabled = true
        pageScrollView.bouncesZoom = false
        pageScrollView.delegate = self
        pageScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.pageScrollView.bounds)*CGFloat(imageList.count), CGRectGetHeight(self.pageScrollView.bounds))
        
        view.addSubview(self.pageScrollView)
        modalPresentationStyle = .OverFullScreen
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    //MARK - UI configure
    
    func configureUserInterface(){
        
        for i in 0..<imageList.count{
            let item = imageList[i]
            
            let zoomScrollView = self.zoomScrollView(i)
            
            pageScrollView.addSubview(zoomScrollView)
            
            switch(item.sourceType){
                case .FilePath:
                    if let filePathURL = item.filePathURL {
                        
                        guard filePathURL.fileURL else{
                            continue
                        }
                        
                        if let image = UIImage(contentsOfFile:filePathURL.path!) {
                            let imageView = imageViewForZoomScrollView(image)
                            zoomScrollView.addSubview(imageView)
                        }
                    }
                case .Image:
                    if let image = item.image {
                        let imageView = imageViewForZoomScrollView(image)
                        zoomScrollView.addSubview(imageView)
                    }
            
                case .URL:
                    if let url = item.imageURL{
                        //loading
                        let loadingView = UIActivityIndicatorView(activityIndicatorStyle:.White)
                        loadingView.center = CGPoint(x: CGRectGetWidth(zoomScrollView.bounds)/2, y:CGRectGetHeight(zoomScrollView.bounds)/2)
                        zoomScrollView.addSubview(loadingView)
                        loadingView.startAnimating()
                        
                        let imageView = imageViewForZoomScrollView(url, progressBlock: { (receivedSize, totalSize) -> () in
                            
                            }, completionHandler: { (image, error, cacheType, imageURL) -> () in
                                loadingView.stopAnimating()
                                loadingView.removeFromSuperview()
                            })
                        zoomScrollView.addSubview(imageView)
                    }
            }
        }

    }
    
    //MARK: - Tap gesture recognizer selector
    

    func handleZoomScrollViewDoubleTap(gestureRecognizer:UITapGestureRecognizer){
        if let scrollView = gestureRecognizer.view as? UIScrollView {
            
            if let imageView = scrollView.subviews.first as? UIImageView {

                var zoomScale:CGFloat = doubleTapZoomScale
                if scrollView.zoomScale != defaultZoomScale {
                    zoomScale = 1.0
                    scrollView.setZoomScale(zoomScale, animated: true)
                }else{

                    let xWidth = CGRectGetWidth(scrollView.bounds)/zoomScale
                    let yHeight = CGRectGetHeight(scrollView.bounds)/zoomScale
                    let x:CGFloat = gestureRecognizer.locationInView(imageView).x-xWidth/2
                    let y:CGFloat = gestureRecognizer.locationInView(imageView).y-yHeight/2
                    
                    scrollView.zoomToRect(CGRect(origin: CGPoint(x: x,y: y), size: CGSize(width: xWidth, height: yHeight)), animated: true)


                }
                
            }
            
        }
    }
    
    func handleZoomScrollViewPanGestureRecognizer(panGestureRecognizer:UIPanGestureRecognizer){
        
        
        if let scrollView = panGestureRecognizer.view as? UIScrollView {
            
            if scrollView.zoomScale == defaultZoomScale {
                
                if let imageView = scrollView.subviews.first {
                    
                    let yImageView = CGRectGetMinY(imageView.frame)
                    let heightImageView = CGRectGetHeight(imageView.frame)
                    let contentOffsetY = self.pageScrollView.contentOffset.y
                    switch panGestureRecognizer.state {
                    case .Began:break
                    case .Changed:
                        //根据imageView移动的距离，设置透明
                        let yOffset = -panGestureRecognizer.translationInView(scrollView).y
                        self.pageScrollView.contentOffset = CGPoint(x: self.pageScrollView.contentOffset.x, y: yOffset)
                        
                        
                        var alpha = 1-abs(contentOffsetY)/(heightImageView+yImageView)
                        if alpha<0.5{
                            alpha = 0.5
                        }
                        self.pageScrollView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(alpha)
                        
                    case .Ended:
                        //获取到imageView将要离开屏幕的方向，是上方消失，还是下方。然后设置相应的渐隐动画
                        var animationToContentOffsetY:CGFloat = 0
                        //如果image有一半已经移出界面，则移出界面,或者滑动的速度大于50
                        let yVelocity = abs(panGestureRecognizer.velocityInView(scrollView).y)
                        
                        if heightImageView/2+yImageView<abs(contentOffsetY) || yVelocity>1000 {
                            if contentOffsetY<0 {
                                animationToContentOffsetY = -(heightImageView+yImageView)
                            }else{
                                animationToContentOffsetY = heightImageView+yImageView
                            }
                        }
                        
                        UIView.animateWithDuration(defaultAnimationDuration, animations: { () -> Void in
                            
                            self.pageScrollView.contentOffset = CGPoint(x: self.pageScrollView.contentOffset.x, y: animationToContentOffsetY)
                            let backgroundColorAlpha:CGFloat = animationToContentOffsetY == 0 ? 1 :0
                            self.pageScrollView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(backgroundColorAlpha)
                            
                        }, completion: { (finished) -> Void in
                                
                                if animationToContentOffsetY != 0 {
                                    self.dismissViewControllerAnimated(false, completion: nil)
                                }
                        })
                        
                    default:
                        break
                    }
                }
            }
            
        }
        
    }

}

//MARK: - setup zoomScrollView and imageView

extension JBImageBrowserViewController{
    
    //生成zoomScrollView
    private func zoomScrollView(index:Int) -> UIScrollView{
        
        let frame = CGRect(origin: CGPoint(x: CGFloat(index)*CGRectGetWidth(self.pageScrollView.bounds), y: 0), size: self.pageScrollView.bounds.size)
        
        let zoomScrollView = UIScrollView(frame: frame)
        zoomScrollView.contentSize = frame.size
        zoomScrollView.showsHorizontalScrollIndicator = false
        zoomScrollView.showsVerticalScrollIndicator = false
        zoomScrollView.bouncesZoom = true
        
        zoomScrollView.minimumZoomScale = defaultZoomScale
        zoomScrollView.maximumZoomScale = maxZoomScale
        zoomScrollView.delegate = self
        
        //双击缩放
        let zoomScrollViewDoubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleZoomScrollViewDoubleTap:"))
        zoomScrollViewDoubleTapGestureRecognizer.numberOfTapsRequired = 2
        zoomScrollViewDoubleTapGestureRecognizer.numberOfTouchesRequired = 1
        zoomScrollView.addGestureRecognizer(zoomScrollViewDoubleTapGestureRecognizer)
        
        
        //pan手势，滑动消失
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handleZoomScrollViewPanGestureRecognizer:")
        panGestureRecognizer.delegate = self
        zoomScrollView.addGestureRecognizer(panGestureRecognizer)
        
        
        return zoomScrollView
        
    }
    
    //根据image，自动设置，生成UIImage，并设置好了Frame
    private func imageViewForZoomScrollView(image:UIImage) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        
        //设置imageView的frame，呈现在屏幕中间
        imageView.frame = imageViewFrameForZoomScrollView(image)
        imageView.image = image
        
        return imageView
    }
    
    private func imageViewForZoomScrollView(url:NSURL,progressBlock:DownloadProgressBlock,completionHandler:CompletionHandler) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        
        imageView.kf_setImageWithURL(url, placeholderImage: nil, optionsInfo: nil, progressBlock: progressBlock) { [weak self,weak imageView] (image, error, cacheType, imageURL) -> () in
            
            if let imageView = imageView {
                if image == nil {
                    imageView.image = self?.failedPlaceholderImage
                }
                imageView.frame = (self?.imageViewFrameForZoomScrollView(imageView.image))!
                completionHandler(image: image,error: error,cacheType: cacheType,imageURL: imageURL)
            }
            
            
        }
        
        return imageView
    }
    
    //根据image的大小，获取imageView在ZoomScrollView的适合的大小
    private func imageViewFrameForZoomScrollView(image:UIImage?)->CGRect{
        
        if let image = image {
        
            let xScale:CGFloat = CGRectGetWidth(self.pageScrollView.bounds)/image.size.width
            let yScale:CGFloat = CGRectGetHeight(self.pageScrollView.bounds)/image.size.height
            
            let minScale = min(min(1.0, xScale),yScale)
            
            //get new image size
            let imageWidth = image.size.width*minScale
            let imageHeight = image.size.height*minScale
            
            //设置imageView的frame，呈现在屏幕中间
            return CGRect(origin: CGPoint(x:(CGRectGetWidth(self.pageScrollView.bounds)-imageWidth)/2,y:(CGRectGetHeight(self.pageScrollView.bounds)-imageHeight)/2), size: CGSize(width: imageWidth, height: imageHeight))
        }else {
            return CGRectZero
        }
    }
}


//MARK: - ImageBrowserVC extesion for scrollViewDelegate
extension JBImageBrowserViewController:UIScrollViewDelegate{
    
    //返回需要缩放的View
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        if scrollView != self.pageScrollView {
            return scrollView.subviews.first
        }
        return nil
    }
    
    //缩放后，重置Frame
    public func scrollViewDidZoom(scrollView: UIScrollView) {
        
        if scrollView != self.pageScrollView {
            if let imageView = scrollView.subviews.first {
                
                let scrollBoundsSize = scrollView.bounds.size
                var imageViewFrame = imageView.frame
                
                //如果imageView的宽高小于scrollView的bounds，则继续将Frame置于中间。如果大于，在保持PointZero的位置即可。
                if imageViewFrame.size.width < scrollBoundsSize.width{
                    imageViewFrame.origin.x = CGFloat(floor((scrollBoundsSize.width-imageViewFrame.width)/2.0))
                }else {
                    imageViewFrame.origin.x = 0
                }
                
                if imageViewFrame.size.height < scrollBoundsSize.height{
                    imageViewFrame.origin.y = CGFloat(floor((scrollBoundsSize.height-imageViewFrame.height)/2.0))
                }else{
                    imageViewFrame.origin.y = 0
                }
                
                if !CGRectEqualToRect(imageView.frame, imageViewFrame){
                    imageView.frame = imageViewFrame
                }
            }
        }
    }
    
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    
        if scrollView == self.pageScrollView {
            //如果scrollView去往新的页面了，则重置scrollView的缩放
            let newPageIndex = Int(scrollView.contentOffset.x/CGRectGetWidth(scrollView.bounds))
            
            if newPageIndex != currentPageIndex {
                if let subScrollView = scrollView.subviews[currentPageIndex] as? UIScrollView {
                    subScrollView.zoomScale = defaultZoomScale
                }
            }
            currentPageIndex = newPageIndex
        }
        
    }
    
    
}


//MARK - GestureRecognizerDelegate

extension JBImageBrowserViewController:UIGestureRecognizerDelegate{
    
    //手势是否确认启动
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        //这里，我们只取Pan的手势，因为scrollView自己还有手势
        if gestureRecognizer.isMemberOfClass(UIPanGestureRecognizer){
            
            if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
                
                //只有没有缩放的情况下，才可以接收上下滑动
                if let scrollView = gestureRecognizer.view as? UIScrollView {
                    if scrollView.zoomScale == defaultZoomScale{
                        let velocity = panGestureRecognizer.velocityInView(scrollView)
                        //只接受Y轴的滑动，不接受X轴的
                        return fabs(velocity.y) > fabs(velocity.x);
                    }else{
                        return false
                    }
                }
                
            }
        }
        
        return true
    }
}


