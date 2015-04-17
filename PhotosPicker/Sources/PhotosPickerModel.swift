//
//  PhotosPickerModel.swift
//  PhotosPicker
//
//  Created by Hiroshi Kimura on 4/8/15.
//  Copyright (c) 2015 muukii. All rights reserved.
//

import Foundation
import Photos

public class PhotosPickerModel {
    
    public typealias PhotosAssets = [DayPhotoAssets]
    
    public struct DayPhotoAssets: Printable {
        var date = NSDate()
        var assets = [PhotosAsset]()
        
        public var description: String {
            var string = "\n Date:\(date) \nAssets: \(assets) \n"
            return string
        }
    }
    
    public class func divideByDay(#collection: PHAssetCollection) -> PhotosAssets {
        
            var dayAssets: PhotosAssets = PhotosAssets()
            
            let options = PHFetchOptions()
            options.sortDescriptors = [
                //            NSSortDescriptor(key: "modificationDate", ascending: false),
                NSSortDescriptor(key: "creationDate", ascending: false),
            ]
            options.includeHiddenAssets = false
            options.wantsIncrementalChangeDetails = false
            
            let assets = PHAsset.fetchAssetsInAssetCollection(collection, options: options)
            var tmpDayAsset: DayPhotoAssets!
            var processingDate: NSDate!
            assets?.enumerateObjectsUsingBlock({ (asset, index, stop) -> Void in
                
                if let asset = asset as? PHAsset {
                    
                    processingDate = self.dateWithOutTime(asset.creationDate)
                    if tmpDayAsset != nil && processingDate.isEqualToDate(tmpDayAsset!.date) == false {
                        
                        dayAssets.append(tmpDayAsset!)
                        tmpDayAsset = nil
                    }
                    
                    if tmpDayAsset == nil {
                        
                        tmpDayAsset = DayPhotoAssets()
                        tmpDayAsset.date = processingDate
                    }
                    
                    tmpDayAsset.assets.append(asset)
                    
                }
            })
        
        return dayAssets
    }
    
    public class func requestDefaultCollections(result: ([PhotosPickerCollectionsController.ItemInfo] -> Void)?) {
        
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
            
            var items: [PhotosPickerCollectionsController.ItemInfo] = []
            
            for collection in collections {
                
                let result: PhotosAssets = self.divideByDay(collection: collection)
                let item: PhotosPickerCollectionsController.ItemInfo = PhotosPickerCollectionsController.ItemInfo(title: collection.localizedTitle, numberOfAssets: collection.requestNumberOfAssets(), assets: result)
                items.append(item)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in

                result?(items)
            })
            
        })
        
        
//        let smartFolder = PHCollectionList.fetchCollectionListsWithType(.MomentList, subtype: .Any, options: nil)
//        println(smartFolder)
//        
//        
//        smartFolder.enumerateObjectsUsingBlock { (collection, index, stop) -> Void in
//            
//            if let collection = collection as? PHAssetCollection {
//                
//                let result = PHCollectionList.fetchMomentListsWithSubtype(PHCollectionListSubtype.MomentListCluster, containingMoment: collection, options: nil)
//                result.enumerateObjectsUsingBlock({ (collection, index, stop) -> Void in
//                    println(collection)
//                })
//            }
//        }

        
    }
    
    private class func dateWithOutTime(date: NSDate!) -> NSDate {
        
        let calendar = NSCalendar.currentCalendar()
        let units = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay
        let comp = calendar.components(units, fromDate: date)
        return calendar.dateFromComponents(comp)!
    }
}