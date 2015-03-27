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
    public var assets: [PHAsset]? {
        willSet {
          
            self.imageManger.stopCachingImagesForAllAssets()
        }
        didSet {
            
             self.imageManger.startCachingImagesForAssets(self.assets, targetSize: CGSizeMake(10, 10), contentMode: PHImageContentMode.AspectFill, options: nil)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        let collectionViewLayout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: CGRect.zeroRect, collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
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
}

extension PhotosPickerAssetsController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 0
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     
        return 0
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        return UICollectionViewCell()
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