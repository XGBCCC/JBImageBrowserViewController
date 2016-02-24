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
        
        
        let image_1 = JBImage(url: NSURL(string: "http://images.apple.com/cn/chinese-new-year/images/style_large_2x.jpg"))
        let image_2 = JBImage(filePathURL: NSBundle.mainBundle().URLForResource("IMG_5445", withExtension: "JPG"))
        let image_3 = JBImage(image: UIImage(named: "IMG_5429"))
        let failedImage = UIImage(named: "error_place_image")
        
        
        let imageBrowserVC = JBImageBrowserViewController(imageArray: [image_1,image_2,image_3],failedPlaceholderImage:failedImage)
        
        self.presentViewController(imageBrowserVC, animated: true, completion: nil)
    }


}

