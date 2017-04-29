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
    
    @IBAction func buttonDidTouched(_ sender: UIButton) {
        
        
        let image_1 = JBImage(url: URL.init(string: "http://images.apple.com/v/home/cj/images/promos/accessories_large_2x.jpg"))
        
        let image_2 = JBImage(filePathURL: Bundle.main.url(forResource: "IMG_5445", withExtension: "JPG"))
        let image_3 = JBImage(image: UIImage(named: "IMG_5429"))
        let failedImage = UIImage(named: "error_place_image")
        
        
        let imageBrowserVC = JBImageBrowserViewController(imageArray: [image_1,image_2,image_3],failedPlaceholderImage:failedImage)
        
        self.present(imageBrowserVC, animated: true, completion: nil)
    }


}

