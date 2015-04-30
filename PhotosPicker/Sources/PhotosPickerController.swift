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
import Foundation
import Photos
import CoreLocation

func AvailablePhotos() -> Bool {
    
    return NSClassFromString("PHAsset") != nil
}

public typealias DividedDayPhotosPickerAssets = [DayPhotosPickerAssets]

public struct DayPhotosPickerAssets: Printable {
    
    var date: NSDate
    var assets: PhotosPickerAssets = []
    
    init(date: NSDate, assets: PhotosPickerAssets = []) {
        
        self.date = date
        self.assets = assets
    }
    
    public var description: String {
        
        var string: String = "\n Date:\(date) \nAssets: \(assets) \n"
        return string
    }
}

public enum PhotosPickerAssetMediaType: Int {
    
    case Unknown
    case Image
    case Video
    case Audio
}

public typealias PhotosPickerAssets = [PhotosPickerAsset]
public protocol PhotosPickerAsset {
    
    var photosObjectMediaType: PhotosPickerAssetMediaType { get }
    var pixelWidth: Int { get }
    var pixelHeight: Int { get }
    
    var creationDate: NSDate! { get }
    var modificationDate: NSDate! { get }
    
    var location: CLLocation! { get }
    var duration: NSTimeInterval { get }
    
    var hidden: Bool { get }
    var favorite: Bool { get }
    
    func requestImage(targetSize: CGSize, result: ((image: UIImage?) -> Void)?)
}

extension PHAsset: PhotosPickerAsset {
    
    public var photosObjectMediaType: PhotosPickerAssetMediaType {
        
       return PhotosPickerAssetMediaType(rawValue: self.mediaType.rawValue)!
    }
    
    public func requestImage(targetSize: CGSize, result: ((image: UIImage?) -> Void)?) {
        
        PHImageManager.defaultManager().requestImageForAsset(self, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
            
            result?(image: image)
            return
        }
    }
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
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            
            // TODO: Refactor
            
            var collections: [PHAssetCollection] = []
            
            let topLevelUserCollectionsResult: PHFetchResult = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
            
            topLevelUserCollectionsResult.enumerateObjectsUsingBlock { (collection, index, stop) -> Void in
                
                if let collection = collection as? PHAssetCollection {
                    collections.append(collection)
                }
            }
            
            let smartAlbumsCollectionResult: PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.Any, options: nil)
            
            smartAlbumsCollectionResult.enumerateObjectsUsingBlock { (collection, index, stop) -> Void in
                
                if let collection = collection as? PHAssetCollection {
                    collections.append(collection)
                }
            }
            
            var items: [PhotosPickerCollectionsItem] = []
            
            for collection: PHAssetCollection in collections {
                
                let options: PHFetchOptions = PHFetchOptions()
                options.sortDescriptors = [
                    //            NSSortDescriptor(key: "modificationDate", ascending: false),
                    NSSortDescriptor(key: "creationDate", ascending: false),
                ]
                options.includeHiddenAssets = false
                options.wantsIncrementalChangeDetails = false
                
                var assets: PhotosPickerAssets = []
                let _assets = PHAsset.fetchAssetsInAssetCollection(collection, options: options)
                
                _assets?.enumerateObjectsUsingBlock({ (asset, index, stop) -> Void in
                    
                    if let asset = asset as? PHAsset {
                        assets.append(asset)
                    }
                })
                
                let item: PhotosPickerCollectionsItem = PhotosPickerCollectionsItem(title: collection.localizedTitle, numberOfAssets: collection.requestNumberOfAssets(), assets: assets)
                
                item.selectionHandler = { (collectionController: PhotosPickerCollectionsController, item: PhotosPickerCollectionsItem) -> Void in
                    
                    let controller2 = PhotosPickerAssetsController()
                    controller2.dividedAssets = item.dividedAssets
                    collectionController.navigationController?.pushViewController(controller2, animated: true)
                }
                items.append(item)
                                
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                result?(items)
            })
            
        })
        
        
    }
    
    public class func divideByDay(#assets: PhotosPickerAssets) -> DividedDayPhotosPickerAssets {
        
        func dateWithOutTime(date: NSDate!) -> NSDate {
            
            let calendar: NSCalendar = NSCalendar.currentCalendar()
            let units: NSCalendarUnit = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay
            let comp: NSDateComponents = calendar.components(units, fromDate: date)
            return calendar.dateFromComponents(comp)!
        }
        
        var dayAssets = DividedDayPhotosPickerAssets()
        
        var tmpDayAsset: DayPhotosPickerAssets!
        var processingDate: NSDate!
        
        for asset in assets {
            
            if let asset = asset as? PHAsset {
                
                processingDate = dateWithOutTime(asset.creationDate)
                if tmpDayAsset != nil && processingDate.isEqualToDate(tmpDayAsset!.date) == false {
                    
                    dayAssets.append(tmpDayAsset!)
                    tmpDayAsset = nil
                }
                
                if tmpDayAsset == nil {
                    
                    tmpDayAsset = DayPhotosPickerAssets(date: processingDate)
                }
                
                tmpDayAsset.assets.append(asset)
                
            }
        }
        
        return dayAssets
    }


}
