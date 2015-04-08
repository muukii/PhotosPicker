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
    
    public struct DayAssets: Printable {
        var date = NSDate()
        var assets = [PHAsset]()
        
        public var description: String {
            var string = "\n Date:\(date) \nAssets: \(assets) \n"
            return string
        }
    }
    
    public class func divideByDay(#collection: PHAssetCollection, completion: ([DayAssets] -> ())?) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            
            
            var dayAssets: [DayAssets] = []
            
            let options = PHFetchOptions()
            options.sortDescriptors = [
                //            NSSortDescriptor(key: "modificationDate", ascending: false),
                NSSortDescriptor(key: "creationDate", ascending: false),
            ]
            options.includeHiddenAssets = false
            options.wantsIncrementalChangeDetails = false
            
            let assets = PHAsset.fetchAssetsInAssetCollection(collection, options: options)
            var tmpDayAsset: DayAssets!
            var processingDate: NSDate!
            assets?.enumerateObjectsUsingBlock({ (asset, index, stop) -> Void in
                
                if let asset = asset as? PHAsset {
                    
                    processingDate = self.dateWithOutTime(asset.creationDate)
                    if tmpDayAsset != nil && processingDate.isEqualToDate(tmpDayAsset!.date) == false {
                        
                        dayAssets.append(tmpDayAsset!)
                        tmpDayAsset = nil
                    }
                    
                    if tmpDayAsset == nil {
                        
                        tmpDayAsset = DayAssets()
                        tmpDayAsset.date = processingDate
                    }
                    
                    tmpDayAsset.assets.append(asset)
                    
                }
            })
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion?(dayAssets)
                return
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