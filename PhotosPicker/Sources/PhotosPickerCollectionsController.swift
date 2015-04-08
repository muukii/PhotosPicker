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
    
    public struct CollectionInfo {
        var collection: PHAssetCollection
        var title: String?
        var numberOfAssets: Int?
        var didSelectHandler: (() -> Void)?
        
        struct Thumbnail {
            var asset: PHAsset
            var cachedImage: UIImage?
            init(asset: PHAsset) {
                
                self.asset = asset
            }
            mutating func requestImage(result: ((image: UIImage) -> Void)?) {

                if let cachedImage = self.cachedImage {
                    
                    result?(image: cachedImage)
                } else {
                    PHImageManager.defaultManager().requestImageForAsset(
                        self.asset,
                        targetSize: CGSizeMake(100,100),
                        contentMode: PHImageContentMode.AspectFill,
                        options: nil,
                        resultHandler: { (image, info) -> Void in
                        
                        self.cachedImage = image
                        result?(image: image)
                    })
                }
                
            }
        }

        var top3Thumbnails: [Thumbnail]?
        
        init(collection: PHAssetCollection, didSelectHandler: (() -> Void)? = nil) {
            
            self.collection = collection
            self.title = collection.localizedTitle
            self.didSelectHandler = didSelectHandler
            
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            options.includeHiddenAssets = false
            options.wantsIncrementalChangeDetails = false
            
            if let assets = PHAsset.fetchAssetsInAssetCollection(self.collection, options: options) {
                
                self.numberOfAssets = assets.count
                
                self.top3Thumbnails = []
                assets.enumerateObjectsUsingBlock({ (asset, index, stop) -> Void in
                    
                    self.top3Thumbnails?.append(Thumbnail(asset: (asset as! PHAsset)))
                    if index == 2 {
                        
                        stop.memory = true
                    }
                })
            }
        }
    
    }

    public weak var tableView: UITableView?
    public var photoLibrary = PHPhotoLibrary.sharedPhotoLibrary()
    public var collectionInfos: [CollectionInfo]?
    
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
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
        
        if let collections = self.presentCollections() {
            
            self.collectionInfos = []
            for collection in collections {
                collection.enumerateObjectsUsingBlock({ (collection, index, stop) -> Void in
                    
                    if let collection = collection as? PHAssetCollection {
                        
                        let collectionInfo = CollectionInfo(collection: collection, didSelectHandler: { [weak self, weak collection] in
                            
                            let options = PHFetchOptions()
                            options.includeHiddenAssets = false
                            options.wantsIncrementalChangeDetails = false
                            
                            if let collection = collection {
                                self?.pushAssetsController(collection)
                            }
                        })
                        self.collectionInfos?.append(collectionInfo)
                    }
                })
            }
        }
    }
    
    deinit {
        
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
        self.collectionInfos = nil
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

        
        let smartFolder = PHCollectionList.fetchCollectionListsWithType(.MomentList, subtype: .Any, options: nil)
        println(smartFolder)
        
        
        smartFolder.enumerateObjectsUsingBlock { (collection, index, stop) -> Void in
            
            if let collection = collection as? PHAssetCollection {
                
                let result = PHCollectionList.fetchMomentListsWithSubtype(PHCollectionListSubtype.MomentListCluster, containingMoment: collection, options: nil)
                result.enumerateObjectsUsingBlock({ (collection, index, stop) -> Void in
                    println(collection)
                })
            }
        }

        return [smartAlbums, result]
    }
    
    /**
    :param: collection
    */
    func pushAssetsController(let collection: PHAssetCollection) {
        
        let controller = PhotosPickerAssetsController(nibName: nil, bundle: nil)
        
        PhotosPickerModel.divideByDay(collection: collection) { [weak controller] assets in
            
            controller?.dayAssets = assets
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension PhotosPickerCollectionsController: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.collectionInfos?.count ?? 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PhotosPickerCollectionCell
        
        if let collection = self.collectionInfos?[indexPath.row] {
            var thumbnail = collection.top3Thumbnails?.first
           
            thumbnail?.requestImage({ (image) -> Void in
                
                cell.thumbnailImageView?.image = image
                return
            })
        }
        return cell
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return PhotosPickerCollectionCell.heightForRow()
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let collection = self.collectionInfos?[indexPath.row] {

            collection.didSelectHandler?()
        }
    }
}

extension PhotosPickerCollectionsController: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(changeInstance: PHChange!) {
        
    }
}

extension PhotosPickerCollectionsController: PhotosPickerProtocol {
    
}