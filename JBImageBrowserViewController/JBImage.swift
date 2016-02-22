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
    
    public var image:UIImage?
    public var imageURL:NSURL?
    public var filePathURL:NSURL?
    public let sourceType:JBImageSourceType
    
    init(url:NSURL!){
        self.imageURL = url
        self.sourceType = .URL
    }
    
    init(image:UIImage!){
        self.image = image
        self.sourceType = .Image
    }
    
    init(filePathURL:NSURL!){
        self.filePathURL = filePathURL
        self.sourceType = .FilePath
    }
    
    
}
