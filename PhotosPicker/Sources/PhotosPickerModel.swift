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
    
    public var photoLibrary = PHPhotoLibrary.sharedPhotoLibrary()
    
    static var sharedInstance = PhotosPickerModel()
    
    init() {
        
    }
    
    public class func divideByDay(#collection: PHAssetCollection, completion: ([DayPhotoAssets] -> ())?) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            
            var dayAssets: [DayPhotoAssets] = []
            
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