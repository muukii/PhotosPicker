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
    public init() {
        
        let controller = PhotosPickerCollectionsController(nibName: nil, bundle: nil)
        super.init(rootViewController: controller)
        self.collectionController = controller
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public class func requestDefaultCollections(result: ([PhotosPickerCollectionsItem] -> Void)?) {
        
        if AvailablePhotos() {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                
                // TODO: Refactor
                
                var collections: [PHAssetCollection] = []
                
                let topLevelUserCollectionsResult: PHFetchResult = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
                
                topLevelUserCollectionsResult.enumerateObjectsUsingBlock { (collection, index, stop) -> Void in
                    
                    if let collection = collection as? PHAssetCollection {
                        collections.insert(collection, atIndex: 0)
                    }
                }
                
                let smartAlbumsCollectionResult: PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.Any, options: nil)
                
                smartAlbumsCollectionResult.enumerateObjectsUsingBlock { (collection, index, stop) -> Void in
                    
                    if let collection = collection as? PHAssetCollection {
                        collections.insert(collection, atIndex: 0)
                    }
                }
                
                var items: [PhotosPickerCollectionsItem] = []
                
                for collection: PHAssetCollection in collections {
                    
                    let options: PHFetchOptions = PHFetchOptions()
                    options.sortDescriptors = [
                        NSSortDescriptor(key: "creationDate", ascending: false),
                    ]
                    options.includeHiddenAssets = false
                    options.wantsIncrementalChangeDetails = false
                    
                    let _assets = PHAsset.fetchAssetsInAssetCollection(collection, options: options)
                    
                    let item = PhotosPickerCollectionsItem(title: collection.localizedTitle, numberOfAssets: collection.requestNumberOfAssets(), assets: _assets)
                    
                    item.selectionHandler = { (collectionController: PhotosPickerCollectionsController, item: PhotosPickerCollectionsItem) -> Void in
                        
                        let controller2 = PhotosPickerAssetsController()
                        controller2.item = item
                        collectionController.navigationController?.pushViewController(controller2, animated: true)
                    }
                    items.append(item)
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    result?(items)
                })
                
            })
        } else {
            
            
        }
    }
    
}


