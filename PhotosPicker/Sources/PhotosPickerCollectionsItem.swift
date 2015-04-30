//
//  PhotosPickerCollection.swift
//  PhotosPicker
//
//  Created by Hiroshi Kimura on 4/17/15.
//  Copyright (c) 2015 muukii. All rights reserved.
//

import Foundation
import Photos

public class PhotosPickerCollectionsItem {
    
    public private(set) var title: String
    public private(set) var numberOfAssets: Int
    public var assets: PhotosPickerAssets {
        didSet {
            
            self.cachedDividedAssets = nil
            self.cachedTopImage = nil
        }
    }
    
    public var selectionHandler: ((collectionController: PhotosPickerCollectionsController, item: PhotosPickerCollectionsItem) -> Void)?
    
    public func requestDividedAssets(result: ((dividedAssets: DividedDayPhotosPickerAssets) -> Void)?) {
        
        if let dividedAssets = self.cachedDividedAssets {
            
            result?(dividedAssets: dividedAssets)
            return
        }
        
        self.assets.requestDividedAssets { (dividedAssets) -> Void in
            
            self.cachedDividedAssets = dividedAssets
            result?(dividedAssets: dividedAssets)
        }
        
    }
    
    public func requestTopImage(result: ((image: UIImage?) -> Void)?) {
        
        if let image = self.cachedTopImage {
            
            result?(image: image)
            return
        }
        
        
        self.requestDividedAssets { (dividedAssets) -> Void in
            
            if let topAsset: PhotosPickerAsset = dividedAssets.first?.assets.first {
                
                topAsset.requestImage(CGSize(width: 100, height: 100), result: { (image) -> Void in
                    
                    self.cachedTopImage = image
                    result?(image: image)
                    return
                })
            }
        }
        
    }
    
    public init(title: String, numberOfAssets: Int, assets: PhotosPickerAssets) {
        
        self.title = title
        self.numberOfAssets = numberOfAssets
        self.assets = assets        
    }
    
    // TODO: Cache
    private var cachedTopImage: UIImage?
    private var cachedDividedAssets: DividedDayPhotosPickerAssets?
}