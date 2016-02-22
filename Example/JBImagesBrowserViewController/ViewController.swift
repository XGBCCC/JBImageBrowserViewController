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
        
        
        let imageBrowserVC = JBImageBrowserViewController(frame:CGRect(x: 0, y: 0, width: CGRectGetWidth(self.view.bounds), height: CGRectGetHeight(self.view.bounds)),imageArray: [JBImage(_url: NSURL(string: "https://scontent.cdninstagram.com/t51.2885-15/s640x640/sh0.08/e35/c0.134.1080.1080/12717038_1023352297739927_791033668_n.jpg?ig_cache_key=MTE4NzYzMzM5NDgyMTc5NTM5OQ%3D%3D.2.c")),JBImage(_url: NSURL(string: "https://scontent.cdninstagram.com/t51.2885-15/e15/12750120_1058587360850246_2078112053_n.jpg?ig_cache_key=MTE4NzgwNTk4MjUyNTUxNzM5Ng%3D%3D.2")),JBImage(_filePathURL: imageURL_1),JBImage(_filePathURL: imageURL_2),JBImage(_filePathURL: imageURL_3),JBImage(_url: NSURL(string: "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/logo.png"))])
        self.presentViewController(imageBrowserVC, animated: true, completion: nil)
    }


}

