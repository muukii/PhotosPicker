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
    public private(set) var assets: PhotosPickerAssets
    public private(set) var dividedAssets: DividedDayPhotosPickerAssets?
    public var selectionHandler: ((collectionController: PhotosPickerCollectionsController, item: PhotosPickerCollectionsItem) -> Void)?
    
    public func requestDividedAssets() {
        
    }
    
    public func requestTopImage(result: ((image: UIImage?) -> Void)?) {
        
        if let image = self.cachedTopImage {
            
            result?(image: image)
            return
        }
        
        if let topAsset: PhotosPickerAsset = self.dividedAssets?.first?.assets.first {
            
            topAsset.requestImage(CGSize(width: 100, height: 100), result: { (image) -> Void in
                
                self.cachedTopImage = image
                result?(image: image)
                return
            })
        }
    }
    
    public init(title: String, numberOfAssets: Int, assets: PhotosPickerAssets) {
        
        self.title = title
        self.numberOfAssets = numberOfAssets
        self.assets = assets
        
    }
    
    // TODO: Cache
    private var cachedTopImage: UIImage?
}