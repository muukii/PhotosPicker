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

public class PhotosPickerCollectionsController: PhotosPickerBaseViewController {
    
    public weak var tableView: UITableView?

    public var sectionInfo: [PhotosPickerCollectionsSection]? {
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
        tableView.tableFooterView = UIView()
        
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
        
        if AvailablePhotos() {
            PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
        }
        
    }
    
    public override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if let selectedIndexPath = self.tableView?.indexPathForSelectedRow() {
            
            self.tableView?.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
    
    deinit {
        
        if AvailablePhotos() {
            
            PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
        }
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
        
        cell.item = self.sectionInfo?[indexPath.section].items?[indexPath.row]
        
        return cell
    }
    
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if cell.respondsToSelector("preservesSuperviewLayoutMargins") {
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsetsZero
        }
        cell.separatorInset = UIEdgeInsetsZero
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return PhotosPickerCollectionCell.heightForRow()
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let item = self.sectionInfo?[indexPath.section].items?[indexPath.row] {
            
            item.selectionHandler?(collectionController: self, item: item)
        }
    }
}

extension PhotosPickerCollectionsController: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(changeInstance: PHChange!) {
        
    }
}
