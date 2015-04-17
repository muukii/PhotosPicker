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
    
    public class SectionInfo {
        
        public var title: String
        public var items: [ItemInfo]?
        public init(title: String) {
            
            self.title = title
        }
    }
    
    public class ItemInfo {
        
        public private(set) var title: String
        public private(set) var numberOfAssets: Int
        public private(set) var assets: PhotosPickerModel.PhotosAssets
        public var selectionHandler: ((collectionController: PhotosPickerCollectionsController, assets: PhotosPickerModel.PhotosAssets) -> Void)?
        
        public func requestTopImage(result: ((image: UIImage?) -> Void)?) {
            
            if let image = self.cachedTopImage {
                
                result?(image: image)
                return
            }
            
            if let topAsset: PhotosAsset = self.assets.first?.assets.first {
                
                topAsset.requestImage(CGSize(width: 100, height: 100), result: { (image) -> Void in
                    
                    self.cachedTopImage = image
                    result?(image: image)
                    return
                })
            }
        }
        
        public init(title: String, numberOfAssets: Int, assets: PhotosPickerModel.PhotosAssets) {
            
            self.title = title
            self.numberOfAssets = numberOfAssets
            self.assets = assets
            
        }
        
        // TODO: Cache
        private var cachedTopImage: UIImage?
    }
    
    public weak var tableView: UITableView?

    public var sectionInfo: [SectionInfo]? {
        didSet {
            
            self.tableView?.reloadData()
        }
    }
    
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
        
    }
    
    deinit {
        
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    public func cellClass() -> PhotosPickerCollectionCell.Type {
        
        return PhotosPickerCollectionCell.self
    }
    
}

extension PhotosPickerCollectionsController: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return self.sectionInfo?.count ?? 0
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let items = self.sectionInfo?[section].items
        return items?.count ?? 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PhotosPickerCollectionCell
        
        if let item = self.sectionInfo?[indexPath.section].items?[indexPath.row] {

            cell.collectionTitleLabel?.text = item.title
            item.requestTopImage({ (image) -> Void in
                
                cell.thumbnailImageView?.image = image
            })
        }
        
        return cell
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return PhotosPickerCollectionCell.heightForRow()
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let item = self.sectionInfo?[indexPath.section].items?[indexPath.row] {
            
            item.selectionHandler?(collectionController: self, assets: item.assets)
        }
    }
}

extension PhotosPickerCollectionsController: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(changeInstance: PHChange!) {
        
    }
}

extension PhotosPickerCollectionsController: PhotosPickerProtocol {
    
}