//
//  ViewController.swift
//  JBImagesBrowserViewController
//
//  Created by JimBo on 16/2/17.
//  Copyright © 2016年 JimBo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func buttonDidTouched(sender: UIButton) {
        
        let imageURL_1 = NSBundle.mainBundle().URLForResource("IMG_5445", withExtension: "JPG")
        let imageURL_2 = NSBundle.mainBundle().URLForResource("IMG_5436", withExtension: "PNG")
        let imageURL_3 = NSBundle.mainBundle().URLForResource("IMG_5429", withExtension: "JPG")
        
        let failedImage = UIImage(named: "error_place_image")
        
        let imageBrowserVC = JBImageBrowserViewController(frame:CGRect(x: 0, y: 0, width: CGRectGetWidth(self.view.bounds), height: CGRectGetHeight(self.view.bounds)),imageArray: [JBImage(url: NSURL(string: "http://images.apple.com/cn/chinese-new-year/images/style_large_2x.jpg")),JBImage(url: NSURL(string: "http://images.apple.com/cn/chinese-new-year/images/hero_tvad_large_2x.jpg")),JBImage(filePathURL: imageURL_1),JBImage(filePathURL: imageURL_2),JBImage(filePathURL: imageURL_3),JBImage(url: NSURL(string: "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/logo.png")),JBImage(url:NSURL(string: "https://www.baidu.com/error.png"))],failedPlaceholderImage:failedImage)
        self.presentViewController(imageBrowserVC, animated: true, completion: nil)
    }


}

