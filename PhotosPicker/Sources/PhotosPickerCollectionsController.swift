// PhotosPickerCollectionsController.swift
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

public class PhotosPickerCollectionsController: UIViewController {
    
    public struct Collection {
        var collection: PHAssetCollection
        var title: String?
        var numberOfAssets: Int?
        
        struct Thumbnail {
            var asset: PHAsset
            var cachedImage: UIImage?
        }
        var top3Assets: [PHAsset]?
        var cachedTop3Images: [UIImage]?
        init(collection: PHAssetCollection) {
            
            self.collection = collection
            self.title = collection.localizedTitle
            self.numberOfAssets = collection.estimatedAssetCount
            
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            options.includeHiddenAssets = false
            options.wantsIncrementalChangeDetails = false
            
            if let assets = PHAsset.fetchAssetsInAssetCollection(self.collection, options: options) {
                
                self.numberOfAssets = assets.count
                
                self.top3Assets = []
                assets.enumerateObjectsUsingBlock({ (asset, index, stop) -> Void in
                    
                    self.top3Assets?.append((asset as! PHAsset))
                    if index == 2 {
                        
                        stop.memory = true
                    }
                })
            }

        }
        
    }

    public weak var tableView: UITableView?
    public var photoLibrary = PHPhotoLibrary.sharedPhotoLibrary()
    public var collections: [Collection]?
    var imageManager = PHImageManager.defaultManager()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public convenience init() {
        
        self.init(nibName: nil, bundle: nil)
    }

    public required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.view.addSubview(tableView)
        self.tableView = tableView
        
        let views = ["tableView": tableView]
        
        self.view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-0-[tableView]-0-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views
            )
        )
        
        self.view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-0-[tableView]-0-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views
            )
        )
        
        self.tableView?.registerClass(self.cellClass(), forCellReuseIdentifier: "Cell")
        println(self.tableView)
        
        if let collections = self.presentCollections() {
            
            self.collections = []
            for collection in collections {
                collection.enumerateObjectsUsingBlock({ (collection, index, stop) -> Void in
                    
                    if let collection = collection as? PHAssetCollection {
                        
                        self.collections?.append(Collection(collection: collection))
                    }
                })
            }
        }
    }
    
    public func cellClass() -> PhotosPickerCollectionCell.Type {
        
        return PhotosPickerCollectionCell.self
    }
    
    public func presentCollections() -> [PHFetchResult]? {
        
        let result = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)

        println(result)
        result.enumerateObjectsUsingBlock { (collection, index, stop) -> Void in
            println(collection)
        }
        let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.Any, options: nil)

        return [smartAlbums, result]
    }
    
    public class func getTopImage(collection: PHAssetCollection, result: ((image: UIImage) -> Void)?) {
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.includeHiddenAssets = false
        options.wantsIncrementalChangeDetails = false
        
        if let assets = PHAsset.fetchAssetsInAssetCollection(collection, options: options) {
                        
            if let firstAsset = assets.firstObject as? PHAsset {
                PHImageManager.defaultManager().requestImageForAsset(firstAsset, targetSize: CGSizeMake(100,100), contentMode: PHImageContentMode.AspectFill, options: nil, resultHandler: { (image, info) -> Void in
                    
                    result?(image: image)
                    return
                })
            }
        }
    }
}

extension PhotosPickerCollectionsController: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.collections?.count ?? 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PhotosPickerCollectionCell
        
        if let collection = self.collections?[indexPath.row] {
            cell.thumbnailImageView?.image = collection.top3Assets?.first
//            PhotosPickerCollectionsController.getTopImage(collection.collection, result: { [weak cell] (image) -> Void in
//                
//                cell?.thumbnailImageView?.image = image
//                return
//            })
        }
        return cell
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return PhotosPickerCollectionCell.heightForRow()
    }
}

extension PhotosPickerCollectionsController: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(changeInstance: PHChange!) {
        
    }
}

extension PhotosPickerCollectionsController: PhotosPickerProtocol {
    
}