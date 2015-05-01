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

public class PhotosPicker {
    
    // Customize
    public static var CollectionsControllerClass: PhotosPickerCollectionsController.Type = PhotosPickerCollectionsController.self
    public static var CollectionsSectionViewClass: PhotosPickerCollectionsSectionView.Type = PhotosPickerCollectionsSectionView.self
    public static var CollectionsCellClass: PhotosPickerCollectionCell.Type = PhotosPickerCollectionCell.self
    
    public static var AssetsControllerClass: PhotosPickerAssetsController.Type = PhotosPickerAssetsController.self
    public static var AssetsSectionViewClass: PhotosPickerAssetsSectionView.Type = PhotosPickerAssetsSectionView.self
    public static var AssetsCellClass: PhotosPickerAssetCell.Type = PhotosPickerAssetCell.self
    
    public static var PermissionDeniedControllerClass: PhotosPickerPermissionDeniedController.Type = PhotosPickerPermissionDeniedController.self
    
    public static var DefaultSectionTitle: String = "Cameraroll"
    
    
    public class var authorizationStatus: PhotosPickerAuthorizationStatus {
        
        if AvailablePhotos() {
            
            return PhotosPickerAuthorizationStatus(rawValue: PHPhotoLibrary.authorizationStatus().rawValue)!
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
            
            Static.defaultSection = nil
            self.requestDefaultSection(nil)
        }
        
        self.requestDefaultSection(nil)
    }
    
    public class func endPreheating() {
        
        Static.observer.endObserving()
    }
    
    /// For iOS8.x
    public class func visiblePhotosLibraryAssetCollection() -> [PHAssetCollection] {
        
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
        
        return collections
    }
    
    /// For iOS7.x
    public class func visibleAssetsLibraryAssetsGroup() -> [ALAssetsGroup] {
        
        return []
    }
    
    public class func requestDefaultSection(result: (PhotosPickerCollectionsSection -> Void)?) {
        
        if let cachedSection = Static.defaultSection {
            
            result?(cachedSection)
            return
        }
        
        
        if AvailablePhotos() {
            
            // PhotosLibrary
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                
                let collections = self.visiblePhotosLibraryAssetCollection()
                
                var items: [PhotosPickerCollectionsItem] = []
                
                for collection: PHAssetCollection in collections {
                                                           
                    let _assets = PHAsset.fetchAssetsInAssetCollection(collection, options: Static.defaultFetchOptions)
                    
                    let item = PhotosPickerCollectionsItem(title: collection.localizedTitle, numberOfAssets: _assets.count, assets: _assets)
                    
                    //tmp
                    item.selectionHandler = PhotosPickerController.defaultSelectionHandler
                    items.append(item)
                }
                
                let section = PhotosPickerCollectionsSection(title: self.DefaultSectionTitle)
                section.items = items
                
                Static.defaultSection = section
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    result?(section)
                })
                
            })
        } else {
            
            // AssetsLibrary
        }
    }
    
    struct Static {
        
        static var defaultSection: PhotosPickerCollectionsSection?
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
