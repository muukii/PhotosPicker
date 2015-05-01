// PhotosPicker.swift
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

import Photos
import AssetsLibrary

public class PhotosPicker {
    
    public class var authorizationStatus: PhotosPickerAuthorizationStatus {
        
        if AvailablePhotos() {
            
            return PhotosPickerAuthorizationStatus(rawValue:  PHPhotoLibrary.authorizationStatus().rawValue)!
        } else {
            
            return PhotosPickerAuthorizationStatus(rawValue: ALAssetsLibrary.authorizationStatus().rawValue)!
        }
    }
    
    @availability(iOS, introduced=8.0)
    public class func requestAuthorization(handler: ((PhotosPickerAuthorizationStatus) -> Void)?) {
        
        if AvailablePhotos() {
            
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                let status = PhotosPickerAuthorizationStatus(rawValue: status.rawValue)!
                handler?(status)
            })
        } else {
            
            // TODO:
        }
    }
    
    public class func startPreheating() {
        
        Static.observer.startObserving()
        Static.observer.didChange = {
            
            Static.defaultItems = nil
            self.requestDefaultCollections(nil)
        }
        
        self.requestDefaultCollections(nil)
    }
    
    public class func endPreheating() {
        
        Static.observer.endObserving()
    }
    
    public class func requestDefaultCollections(result: ([PhotosPickerCollectionsItem] -> Void)?) {
        
        if let cachedItems = Static.defaultItems {
            
            result?(cachedItems)
        }
        
        
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
                                                           
                    let _assets = PHAsset.fetchAssetsInAssetCollection(collection, options: Static.defaultFetchOptions)
                    
                    let item = PhotosPickerCollectionsItem(title: collection.localizedTitle, numberOfAssets: collection.requestNumberOfAssets(), assets: _assets)
                    
                    item.selectionHandler = PhotosPickerController.defaultSelectionHandler
                    items.append(item)
                    
                }
                
                Static.defaultItems = items
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    result?(items)
                })
                
            })
        } else {
            
            
        }
    }
    
    struct Static {
        
        static var defaultItems: [PhotosPickerCollectionsItem]?
        static var observer = PhotosPickerLibraryObserver()
        static var defaultFetchOptions: PHFetchOptions = {
            
            let options: PHFetchOptions = PHFetchOptions()
            options.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false),
            ]
            options.includeHiddenAssets = true
            options.includeAllBurstAssets = true
            options.wantsIncrementalChangeDetails = true
            return options
        }()
    }

}


class PhotosPickerLibraryObserver: NSObject {
    
    var didChange: (() -> Void)?
    
    private(set) var isObserving: Bool = false
    
    func startObserving() {
        
        self.isObserving = true
        
        if AvailablePhotos() {
            
            PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
        } else {
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "assetsLibraryDidChange:", name: ALAssetsLibraryChangedNotification, object: nil)
        }
    }
    
    func endObserving() {
        
        self.isObserving = false
        
        if AvailablePhotos() {
            
            PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
        } else {
            
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }
    
    private dynamic func assetsLibraryDidChange(notification: NSNotification) {
        
        self.didChange?()
    }
}

extension PhotosPickerLibraryObserver: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(changeInstance: PHChange!) {
        
        // temp
        self.didChange?()
    }
}
