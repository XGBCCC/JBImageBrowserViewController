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
        
        
        let imageBrowserVC = JBImageBrowserViewController(frame:CGRect(x: 0, y: 0, width: CGRectGetWidth(self.view.bounds), height: CGRectGetHeight(self.view.bounds)),imageArray: [JBImage(_url: NSURL(string: "http://images.apple.com/cn/chinese-new-year/images/style_large_2x.jpg")),JBImage(_url: NSURL(string: "http://images.apple.com/cn/chinese-new-year/images/hero_tvad_large_2x.jpg")),JBImage(_filePathURL: imageURL_1),JBImage(_filePathURL: imageURL_2),JBImage(_filePathURL: imageURL_3),JBImage(_url: NSURL(string: "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/logo.png"))])
        self.presentViewController(imageBrowserVC, animated: true, completion: nil)
    }


}

