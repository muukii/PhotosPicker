//
//  Photo.swift
//  PhotosPickerExample
//
//  Created by Hiroshi Kimura on 4/30/15.
//  Copyright (c) 2015 muukii. All rights reserved.
//

import Foundation
import CoreLocation
import PhotosPicker

class Photo: NSObject, PhotosPickerAsset {
    
    var photosObjectMediaType: PhotosPickerAssetMediaType {
        
        return .Unknown
    }
    
    var pixelWidth: Int {
        
        return 300
    }
    
    var pixelHeight: Int {
        
        return 300
    }
    
    var creationDate: NSDate! {
        
        return NSDate()
    }
    
    var modificationDate: NSDate! {
     
        return NSDate()
    }
    
    var location: CLLocation! {
        
        return CLLocation()
    }
    
    var duration: NSTimeInterval {
        
        return 0
    }
    
    var hidden: Bool {
        
        return false
    }
    
    var favorite: Bool {
        
        return false
    }
    
    func requestImage(targetSize: CGSize, result: ((image: UIImage?) -> Void)?) {
        
        result?(image: nil)
    }
}
