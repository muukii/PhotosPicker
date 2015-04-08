// PhotsPickerAssetsController.swift
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

public class PhotosPickerAssetsController: UIViewController {

    public var collectionView: UICollectionView?
    public var dayAssets: [PhotosPickerModel.DayAssets]? {
        didSet {
         
            self.collectionView?.reloadData()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        let collectionViewLayout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: CGRect.zeroRect, collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        collectionView.registerClass(PhotosPickerAssetCell.self, forCellWithReuseIdentifier: "Cell")
        
        self.view.addSubview(collectionView)
        self.collectionView = collectionView
        
        let views = ["collectionView": collectionView]
        
        self.view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views
            )
        )
        
        self.view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views
            )
        )
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    deinit {
        
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    private var imageManger = PHCachingImageManager()
    
    
    private func dateWithOutTime(date: NSDate) -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        let units: NSCalendarUnit = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay
        let comp: NSDateComponents = calendar.components(units, fromDate: date)
        return calendar.dateFromComponents(comp)
    }
}

extension PhotosPickerAssetsController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return self.dayAssets?.count ?? 0
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dayAssets = self.dayAssets?[section]
        return dayAssets?.assets.count ?? 0
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PhotosPickerAssetCell
        let asset = self.dayAssets?[indexPath.section].assets[indexPath.item]
        self.imageManger.requestImageForAsset(
            asset,
            targetSize: CGSizeMake(100,100),
            contentMode: PHImageContentMode.AspectFill,
            options: nil,
            resultHandler: { (image, info) -> Void in
                cell.thumbnailImageView?.image = image
        })
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
}

extension PhotosPickerAssetsController: UICollectionViewDelegateFlowLayout {
    

}

extension PhotosPickerAssetsController: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(changeInstance: PHChange!) {
        
    }
}

extension PhotosPickerAssetsController: PhotosPickerProtocol {
    
}