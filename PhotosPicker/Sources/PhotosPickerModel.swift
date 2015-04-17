//
//  PhotosPickerModel.swift
//  PhotosPicker
//
//  Created by Hiroshi Kimura on 4/8/15.
//  Copyright (c) 2015 muukii. All rights reserved.
//

import Foundation
import Photos

public typealias PhotosPickerAssets = [DayPhotosPickerAssets]

public struct DayPhotosPickerAssets: Printable {
    var date = NSDate()
    var assets = [PhotosPickerAsset]()
    
    public var description: String {
        var string = "\n Date:\(date) \nAssets: \(assets) \n"
        return string
    }
}

public class PhotosPickerModel {
    
    public class func divideByDay(#collection: PHAssetCollection) -> PhotosPickerAssets {
        
            var dayAssets: PhotosPickerAssets = PhotosPickerAssets()
            
            let options = PHFetchOptions()
            options.sortDescriptors = [
                //            NSSortDescriptor(key: "modificationDate", ascending: false),
                NSSortDescriptor(key: "creationDate", ascending: false),
            ]
            options.includeHiddenAssets = false
            options.wantsIncrementalChangeDetails = false
            
            let assets = PHAsset.fetchAssetsInAssetCollection(collection, options: options)
            var tmpDayAsset: DayPhotosPickerAssets!
            var processingDate: NSDate!
            assets?.enumerateObjectsUsingBlock({ (asset, index, stop) -> Void in
                
                if let asset = asset as? PHAsset {
                    
                    processingDate = self.dateWithOutTime(asset.creationDate)
                    if tmpDayAsset != nil && processingDate.isEqualToDate(tmpDayAsset!.date) == false {
                        
                        dayAssets.append(tmpDayAsset!)
                        tmpDayAsset = nil
                    }
                    
                    if tmpDayAsset == nil {
                        
                        tmpDayAsset = DayPhotosPickerAssets()
                        tmpDayAsset.date = processingDate
                    }
                    
                    tmpDayAsset.assets.append(asset)
                    
                }
            })
        
        return dayAssets
    }
    
    public class func requestDefaultCollections(result: ([PhotosPickerCollectionsItem] -> Void)?) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            
            // TODO: Refactor
            
            var collections: [PHAssetCollection] = []
            
            let topLevelUserCollectionsResult = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
            
            topLevelUserCollectionsResult.enumerateObjectsUsingBlock { (collection, index, stop) -> Void in
                
                if let collection = collection as? PHAssetCollection {
                    collections.append(collection)
                }
//                else if let collectionList = collection as? PHCollectionList {
//                    
//                    let result = PHCollection.fetchCollectionsInCollectionList(collectionList, options: nil)
//                    
//                    result.enumerateObjectsUsingBlock({ (collection, index, stop) -> Void in
//                        
//                        if let collection = collection as? PHAssetCollection {
//                            collections.append(collection)
//                        }
//                    })
//                }
            }
            
            let smartAlbumsCollectionResult = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.Any, options: nil)
            
            smartAlbumsCollectionResult.enumerateObjectsUsingBlock { (collection, index, stop) -> Void in
                
                if let collection = collection as? PHAssetCollection {
                    collections.append(collection)
                }
//                else if let collectionList = collection as? PHCollectionList {
//                    let result = PHCollection.fetchCollectionsInCollectionList(collectionList, options: nil)
//                    
//                    result.enumerateObjectsUsingBlock({ (collection, index, stop) -> Void in
//                        
//                        if let collection = collection as? PHAssetCollection {
//                            collections.append(collection)
//                        }
//                    })
//                }
            }
            
            var items: [PhotosPickerCollectionsItem] = []
            
            for collection in collections {
                
                let result: PhotosPickerAssets = self.divideByDay(collection: collection)
                let item: PhotosPickerCollectionsItem = PhotosPickerCollectionsItem(title: collection.localizedTitle, numberOfAssets: collection.requestNumberOfAssets(), assets: result)
                item.selectionHandler = { (collectionController: PhotosPickerCollectionsController, assets: PhotosPickerAssets) -> Void in
                    
                    let controller2 = PhotosPickerAssetsController()
                    controller2.assets = assets
                    collectionController.navigationController?.pushViewController(controller2, animated: true)
                }
                items.append(item)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in

                result?(items)
            })
            
        })
        
        
    }
    
    private class func dateWithOutTime(date: NSDate!) -> NSDate {
        
        let calendar = NSCalendar.currentCalendar()
        let units = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay
        let comp = calendar.components(units, fromDate: date)
        return calendar.dateFromComponents(comp)!
    }
}