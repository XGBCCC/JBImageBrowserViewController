//
//  JBImageBrowserView.swift
//  JBImageBrowserView
//
//  Created by JimBo on 16/2/17.
//  Copyright © 2016年 JimBo. All rights reserved.
//

import UIKit
import Kingfisher


open class JBImageBrowserViewController: UIViewController {

    fileprivate var imageList:[JBImage]!
    fileprivate let defaultZoomScale:CGFloat = 1.0
    fileprivate let doubleTapZoomScale:CGFloat = 2.0
    fileprivate let maxZoomScale:CGFloat = 3.0
    fileprivate var defaultAnimationDuration = 0.15
    fileprivate var currentPageIndex = 0
    
    //加载失败占位图
    fileprivate var failedPlaceholderImage:UIImage?
    
    fileprivate var pageScrollView:UIScrollView
    
    //pan手势移动最大距离
    fileprivate var translationMaxValue:CGFloat = 0
    
    //关闭按钮
    fileprivate var activeButton:UIButton?
    fileprivate var activeButtonSize = CGSize(width: 50, height: 50)
    fileprivate let activeButtonPadding:CGFloat = 10.0
    
    
    /**
     创建图片浏览器
     
     - parameter imageArray:             JBImage Array
     - parameter failedPlaceholderImage: 加载失败后的占位图
     
     - returns: 图片浏览器实例
     */
    public init(imageArray:[JBImage]!,failedPlaceholderImage:UIImage?) {
        
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
    
    
    override open var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    //MARK: - UI Setup
    
    func setupUserInterface(){
        
        pageScrollView.frame = CGRect(origin: CGPoint(x: 0,y: 0), size: CGSize(width: self.view.bounds.width, height: self.view.bounds.height))
        pageScrollView.backgroundColor = UIColor.black
        pageScrollView.showsHorizontalScrollIndicator = false
        pageScrollView.showsVerticalScrollIndicator = false
        pageScrollView.isPagingEnabled = true
        pageScrollView.bouncesZoom = false
        pageScrollView.delegate = self
        pageScrollView.contentSize = CGSize(width: self.pageScrollView.bounds.width*CGFloat(imageList.count), height: self.pageScrollView.bounds.height)
        
        view.addSubview(self.pageScrollView)
        modalPresentationStyle = .overFullScreen
        modalPresentationCapturesStatusBarAppearance = true
        
        let activeImage = (UIImage(named: "JBImagesBrowserVC.bundle/imagesbrowser_item") != nil) ? UIImage(named: "JBImagesBrowserVC.bundle/imagesbrowser_item") : UIImage(named:"Frameworks/JBImageBrowserViewController.framework/JBImagesBrowserVC.bundle/imagesbrowser_item");
        activeButton = UIButton(frame: CGRect(origin: CGPoint(x: view.bounds.size.width - CGFloat(activeButtonPadding) - activeButtonSize.width, y: view.bounds.size.height - CGFloat(activeButtonPadding) - activeButtonSize.height), size: activeButtonSize))
        activeButton?.setImage(activeImage, for: UIControlState())
        activeButton?.addTarget(self, action: #selector(JBImageBrowserViewController.activeButtonClicked), for: .touchUpInside)
        
        view.addSubview(activeButton!)
        
    }
    
    //MARK - UI configure
    
    func configureUserInterface(){
        
        for i in 0..<imageList.count{
            let item = imageList[i]
            
            let zoomScrollView = self.zoomScrollView(i)
            
            pageScrollView.addSubview(zoomScrollView)
            
            switch(item.sourceType){
                case .filePath:
                    if let filePathURL = item.filePathURL {
                        
                        guard filePathURL.isFileURL else{
                            continue
                        }
                        
                        if let image = UIImage(contentsOfFile:filePathURL.path) {
                            let imageView = imageViewForZoomScrollView(image)
                            zoomScrollView.addSubview(imageView)
                        }
                    }
                case .image:
                    if let image = item.image {
                        let imageView = imageViewForZoomScrollView(image)
                        zoomScrollView.addSubview(imageView)
                    }
            
                case .url:
                    if let url = item.imageURL{
                        //loading
                        let loadingView = UIActivityIndicatorView(activityIndicatorStyle:.white)
                        loadingView.center = CGPoint(x: zoomScrollView.bounds.width/2, y:zoomScrollView.bounds.height/2)
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
    
    func handleZoomScrollViewTap(_ gestureRecognizer:UITapGestureRecognizer){
        
        self.dismiss(animated: true, completion: nil)
        
    }

    func handleZoomScrollViewDoubleTap(_ gestureRecognizer:UITapGestureRecognizer){
        if let scrollView = gestureRecognizer.view as? UIScrollView {
            
            if let imageView = scrollView.subviews.first as? UIImageView {

                var zoomScale:CGFloat = doubleTapZoomScale
                if scrollView.zoomScale != defaultZoomScale {
                    zoomScale = 1.0
                    scrollView.setZoomScale(zoomScale, animated: true)
                }else{

                    let xWidth = scrollView.bounds.width/zoomScale
                    let yHeight = scrollView.bounds.height/zoomScale
                    let x:CGFloat = gestureRecognizer.location(in: imageView).x-xWidth/2
                    let y:CGFloat = gestureRecognizer.location(in: imageView).y-yHeight/2
                    
                    scrollView.zoom(to: CGRect(origin: CGPoint(x: x,y: y), size: CGSize(width: xWidth, height: yHeight)), animated: true)


                }
                
            }
            
        }
    }
    
    func handleZoomScrollViewPanGestureRecognizer(_ panGestureRecognizer:UIPanGestureRecognizer){
        
        
        if let scrollView = panGestureRecognizer.view as? UIScrollView {
            
            if scrollView.zoomScale == defaultZoomScale {
                
                if let imageView = scrollView.subviews.first {
                    
                    let yImageView = imageView.frame.minY
                    let heightImageView = imageView.frame.height
                    let contentOffsetY = scrollView.contentOffset.y
                    switch panGestureRecognizer.state {
                    case .began:break
                    case .changed:
                        //根据imageView移动的距离，设置透明
                        let yOffset = -panGestureRecognizer.translation(in: scrollView).y
                        scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: yOffset)
                        
                        
                        var alpha = 1-abs(contentOffsetY)/(heightImageView+yImageView)
                        if alpha<0.5{
                            alpha = 0.5
                        }
                        self.pageScrollView.backgroundColor = UIColor.black.withAlphaComponent(alpha)
                        
                        //获取移动的最大值。记录最大值的目的是判断，移动结束后的offset跟最大值相比，如果小于最大值，则表示是当前要重置回原位
                        if abs(yOffset) > self.translationMaxValue{
                            self.translationMaxValue = abs(yOffset)
                        }
                        
                    case .ended:
                        //获取到imageView将要离开屏幕的方向，是上方消失，还是下方。然后设置相应的渐隐动画
                        var animationToContentOffsetY:CGFloat = 0
                        //如果image有一半已经移出界面，则移出界面,或者滑动的速度大于50
                        let yVelocity = panGestureRecognizer.velocity(in: scrollView).y
                        
                        
                        //需要判断，移动结束后的offset跟最大值相比，如果小于最大值，则表示是当前要重置回原位
                        if heightImageView/2+yImageView<abs(contentOffsetY) || abs(yVelocity)>100&&self.translationMaxValue<=abs(contentOffsetY) {
                            if contentOffsetY<0 {
                                animationToContentOffsetY = -(heightImageView+yImageView)
                            }else{
                                animationToContentOffsetY = heightImageView+yImageView
                            }
                        }
                        
                        UIView.animate(withDuration: defaultAnimationDuration, animations: { () -> Void in
                            
                            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: animationToContentOffsetY)
                            let backgroundColorAlpha:CGFloat = animationToContentOffsetY == 0 ? 1 :0
                            self.pageScrollView.backgroundColor = UIColor.black.withAlphaComponent(backgroundColorAlpha)
                            
                        }, completion: { [weak self] (finished) -> Void in
                                if animationToContentOffsetY != 0 {
                                    self?.dismiss(animated: false, completion: nil)
                                }
                        })
                        
                    default:
                        break
                    }
                }
            }
            
        }
        
    }
    
    //MARK: - Target - Action
    func activeButtonClicked(){
    
        if let image = self.currentScollViewImage() {
            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
        
    }
    
    //MARK: - Func
    fileprivate func currentScollViewImage() -> UIImage?{
        if let currentScrollView = pageScrollView.subviews[currentPageIndex] as? UIScrollView {
            if let currentImageView = currentScrollView.subviews[0] as? UIImageView {
                if let currentImage = currentImageView.image {
                    return currentImage
                }
            }
        }
        return nil
    }
    

}

//MARK: - setup zoomScrollView and imageView

extension JBImageBrowserViewController{
    
    //生成zoomScrollView
    fileprivate func zoomScrollView(_ index:Int) -> UIScrollView{
        
        let frame = CGRect(origin: CGPoint(x: CGFloat(index)*self.pageScrollView.bounds.width, y: 0), size: self.pageScrollView.bounds.size)
        
        let zoomScrollView = UIScrollView(frame: frame)
        zoomScrollView.contentSize = frame.size
        zoomScrollView.showsHorizontalScrollIndicator = false
        zoomScrollView.showsVerticalScrollIndicator = false
        zoomScrollView.bouncesZoom = true
        
        zoomScrollView.minimumZoomScale = defaultZoomScale
        zoomScrollView.maximumZoomScale = maxZoomScale
        zoomScrollView.delegate = self
        
        //点击，显示，隐藏close按钮
        let zoomScrollViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(JBImageBrowserViewController.handleZoomScrollViewTap(_:)))
        zoomScrollView.addGestureRecognizer(zoomScrollViewTapGestureRecognizer)
        
        //双击缩放
        let zoomScrollViewDoubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(JBImageBrowserViewController.handleZoomScrollViewDoubleTap(_:)))
        zoomScrollViewDoubleTapGestureRecognizer.numberOfTapsRequired = 2
        zoomScrollViewDoubleTapGestureRecognizer.numberOfTouchesRequired = 1
        zoomScrollView.addGestureRecognizer(zoomScrollViewDoubleTapGestureRecognizer)
        
        
        //pan手势，滑动消失
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(JBImageBrowserViewController.handleZoomScrollViewPanGestureRecognizer(_:)))
        panGestureRecognizer.delegate = self
        panGestureRecognizer.maximumNumberOfTouches = 1
        zoomScrollView.addGestureRecognizer(panGestureRecognizer)
        
        zoomScrollViewTapGestureRecognizer.require(toFail: zoomScrollViewDoubleTapGestureRecognizer)
        zoomScrollViewTapGestureRecognizer.require(toFail: panGestureRecognizer)
        
        return zoomScrollView
        
    }
    
    //根据image，自动设置，生成UIImage，并设置好了Frame
    fileprivate func imageViewForZoomScrollView(_ image:UIImage) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        //设置imageView的frame，呈现在屏幕中间
        imageView.frame = imageViewFrameForZoomScrollView(image)
        imageView.image = image
        
        return imageView
    }
    
    fileprivate func imageViewForZoomScrollView(_ url:URL,progressBlock:DownloadProgressBlock,completionHandler:@escaping CompletionHandler) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        imageView.kf.setImage(with: ImageResource.init(downloadURL: url), placeholder: nil, options: nil, progressBlock: nil) { [weak self,weak imageView] (image, error, cacheType, imageURL) in
            
            if let imageView = imageView {
                if image == nil {
                    imageView.image = self?.failedPlaceholderImage
                }
                imageView.frame = (self?.imageViewFrameForZoomScrollView(imageView.image))!
                completionHandler(image,error,cacheType,imageURL)
            }
        }
        
        return imageView
    }
    
    //根据image的大小，获取imageView在ZoomScrollView的适合的大小
    fileprivate func imageViewFrameForZoomScrollView(_ image:UIImage?)->CGRect{
        
        if let image = image {
        
            let xScale:CGFloat = self.pageScrollView.bounds.width/image.size.width
            let yScale:CGFloat = self.pageScrollView.bounds.height/image.size.height
            
            let minScale = min(min(1.0, xScale),yScale)
            
            //get new image size
            let imageWidth = image.size.width*minScale
            let imageHeight = image.size.height*minScale
            
            //设置imageView的frame，呈现在屏幕中间
            return CGRect(origin: CGPoint(x:(self.pageScrollView.bounds.width-imageWidth)/2,y:(self.pageScrollView.bounds.height-imageHeight)/2), size: CGSize(width: imageWidth, height: imageHeight))
        }else {
            return CGRect.zero
        }
    }
}


//MARK: - ImageBrowserVC extesion for scrollViewDelegate
extension JBImageBrowserViewController:UIScrollViewDelegate{
    
    //返回需要缩放的View
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView != self.pageScrollView {
            return scrollView.subviews.first
        }
        return nil
    }
    
    //缩放后，重置Frame
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        //获取到当前页面的图片
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
                
                if !imageView.frame.equalTo(imageViewFrame){
                    imageView.frame = imageViewFrame
                }
            }
        }else{
            //如果是pageScrollView，则判断当前页面的Image是否已加载，已加载，则允许进行分享
            activeButton?.isEnabled = false
            if let _ = self.currentScollViewImage() {
                activeButton?.isEnabled = true
            }
        }
    }
    
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    
        if scrollView == self.pageScrollView {
            //如果scrollView去往新的页面了，则重置scrollView的缩放
            let newPageIndex = Int(scrollView.contentOffset.x/scrollView.bounds.width)
            
            if newPageIndex != currentPageIndex {
                if let subScrollView = scrollView.subviews[currentPageIndex] as? UIScrollView {
                    if subScrollView.zoomScale != defaultZoomScale {
                        subScrollView.zoomScale = defaultZoomScale
                    }
                }
            }
            currentPageIndex = newPageIndex
            
        }
        
    }
    
    
}


//MARK - GestureRecognizerDelegate

extension JBImageBrowserViewController:UIGestureRecognizerDelegate{
    
    //手势是否确认启动
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        //这里，我们只取Pan的手势，因为scrollView自己还有手势
        if gestureRecognizer.isMember(of: UIPanGestureRecognizer.self){
            
            if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
                
                //只有没有缩放的情况下，才可以接收上下滑动
                if let scrollView = gestureRecognizer.view as? UIScrollView {

                    if scrollView.zoomScale == defaultZoomScale{
                        let velocity = panGestureRecognizer.velocity(in: scrollView)
                        //只接受Y轴的滑动，不接受X轴的
                        return fabs(velocity.y) > fabs(velocity.x)
                    }else{
                        return false
                    }
                }
                
            }
        }
        
        return true
    }
    

}


