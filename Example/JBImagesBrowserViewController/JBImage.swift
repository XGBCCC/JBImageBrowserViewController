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
    
    init(_url:NSURL!){
        imageURL = _url
        sourceType = .URL
    }
    
    init(_image:UIImage!){
        image = _image
        sourceType = .Image
    }
    
    init(_filePathURL:NSURL!){
        filePathURL = _filePathURL
        sourceType = .FilePath
    }
    
    
}
