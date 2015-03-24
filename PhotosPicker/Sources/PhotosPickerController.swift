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

public protocol PhotosPickerProtocol: class {
    
}

/**
* PhotosPickerController
*/
public class PhotosPickerController<T where T: PhotosPickerCollectionsController, T: PhotosPickerProtocol/*, U where U: PhotosPickerProtocol, U: PhotosPickerAssetsController*/>: UINavigationController {

    private(set) var collectionController: T?
//    private(set) var assetsControllerClass: U.Type?
    private(set) var collectionControllerClass: T.Type?
    
}
