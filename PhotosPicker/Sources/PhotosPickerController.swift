// PhotosPickerController.swift
//
// Copyright (c) 2015 muukii
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Photos
import AssetsLibrary
import CoreLocation

func AvailablePhotos() -> Bool {
    
    return NSClassFromString("PHAsset") != nil
}

public enum PhotosPickerAssetMediaType: Int {
    
    case Unknown
    case Image
    case Video
    case Audio
}

extension PHAssetCollection {
    
    func requestNumberOfAssets() -> Int {
       
        let assets = PHAsset.fetchAssetsInAssetCollection(self, options: nil)
        return assets.count
    }
}

public enum PhotosPickerAuthorizationStatus : Int {
    
    case NotDetermined // User has not yet made a choice with regards to this application
    case Restricted // This application is not authorized to access photo data.
    // The user cannot change this application’s status, possibly due to active restrictions
    //   such as parental controls being in place.
    case Denied // User has explicitly denied this application access to photos data.
    case Authorized // User has authorized this application to access photos data.
}

struct CustomClasses {
    
}

/**
* PhotosPickerController
*/
public class PhotosPickerController: UINavigationController {
        
    
    public private(set) var collectionController: PhotosPickerCollectionsController?
    
    ///
    public var allowsEditing: Bool = false
    public var didFinishPickingAssets: ((controller: PhotosPickerController, assets: [PhotosPickerAsset]) -> Void)?
    public var didCancel: ((controller: PhotosPickerController) -> Void)?
    
    /**
    
    :returns:
    */
    public init<T: PhotosPickerCollectionsController>(collectionsControllerClass: T.Type) {

        let controller = T(nibName: nil, bundle: nil)
        super.init(rootViewController: controller)
        self.collectionController = controller
    }
    
    public convenience init() {
        
        self.init(collectionsControllerClass: PhotosPickerCollectionsController.self)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    public static var defaultSelectionHandler = { (collectionsController: PhotosPickerCollectionsController, item: PhotosPickerCollectionsItem) -> Void in
        
        let controller = PhotosPickerAssetsController()
        controller.item = item
        collectionsController.navigationController?.pushViewController(controller, animated: true)
    }
    
}
