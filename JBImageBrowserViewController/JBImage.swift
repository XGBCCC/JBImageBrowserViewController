//
//  JBImage.swift
//  JBImageBrowserViewController
//
//  Created by JimBo on 16/2/19.
//  Copyright © 2016年 JimBo. All rights reserved.
//

import UIKit

public enum JBImageSourceType {
    case image
    case url
    case filePath
}

public struct JBImage {
    
    var image:UIImage?
    var imageURL:URL?
    var filePathURL:URL?
    let sourceType:JBImageSourceType
    
    public init(url:URL!){
        self.imageURL = url
        self.sourceType = .url
    }
    
    public init(image:UIImage!){
        self.image = image
        self.sourceType = .image
    }
    
    public init(filePathURL:URL!){
        self.filePathURL = filePathURL
        self.sourceType = .filePath
    }
    
    
}
