//
//  JBImage.swift
//  JBImageBrowserViewController
//
//  Created by JimBo on 16/2/19.
//  Copyright © 2016年 JimBo. All rights reserved.
//

import UIKit

public enum JBImageSourceType {
    case Image
    case URL
    case FilePath
}

public struct JBImage {
    
    var image:UIImage?
    var imageURL:NSURL?
    var filePathURL:NSURL?
    let sourceType:JBImageSourceType
    
    public init(url:NSURL!){
        self.imageURL = url
        self.sourceType = .URL
    }
    
    public init(image:UIImage!){
        self.image = image
        self.sourceType = .Image
    }
    
    public init(filePathURL:NSURL!){
        self.filePathURL = filePathURL
        self.sourceType = .FilePath
    }
    
    
}
