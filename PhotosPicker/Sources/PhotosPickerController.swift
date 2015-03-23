//
//  PhotosPickerController.swift
//  PhotosPicker
//
//  Created by Muukii on 3/22/15.
//  Copyright (c) 2015 muukii. All rights reserved.
//

import UIKit
import Foundation
import Photos

/**
* PhotosPickerController
*/
public class PhotosPickerController: UINavigationController {

    private(set) var collectionController: PhotosPickerCollectionsController?
    private(set) var assetsControllerClass: PhotosPickerAssetsController.Type?
    private(set) var collectionControllerClass: PhotosPickerCollectionsController.Type?
    
    public convenience init() {
        
        self.init(rootViewController: PhotosPickerCollectionsController())
    }
    
    public convenience init(collectionControllerClass: PhotosPickerCollectionsController.Type?, assetsControllerClass: PhotosPickerAssetsController.Type?) {
        
        self.init()
        self.assetsControllerClass = assetsControllerClass
        self.collectionControllerClass = collectionControllerClass
        
//        self.collectionController = self.collectionControllerClass?(nibName: nil, bundle: nil)
    }
}
