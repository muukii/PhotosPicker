// PhotosPickerController.swift
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
import Photos
import AssetsLibrary
import CoreLocation

/**
* PhotosPickerController
*/
public class PhotosPickerController: UINavigationController {
    
    public private(set) var collectionController: PhotosPickerCollectionsController?
    
    ///
    public var allowsEditing: Bool = false
    public var didFinishPickingAssets: ((controller: PhotosPickerController, assets: [PhotosPickerAsset]) -> Void)?
    public var didCancel: ((controller: PhotosPickerController) -> Void)?
    
    public var setupSections: ((defaultSection: PhotosPickerCollectionsSection) -> [PhotosPickerCollectionsSection])?
    /**
    
    :returns:
    */
    public init() {
        
        let controller = PhotosPicker.CollectionsControllerClass(nibName: nil, bundle: nil)
        super.init(rootViewController: controller)
        self.collectionController = controller
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.setup()
    }
    
    private func setup() {
                        
        if PhotosPicker.authorizationStatus != .Authorized {
            
            if AvailablePhotos() {
                
                PhotosPicker.requestAuthorization({ (status) -> Void in
                    
                    self.setup()
                })
                
            }
            
            return
        }
        
        PhotosPicker.requestDefaultSection { section in
            
            self.collectionController?.sectionInfo = self.setupSections?(defaultSection: section)
        }
    }
    
    public static var defaultSelectionHandler = { (collectionsController: PhotosPickerCollectionsController, item: PhotosPickerCollectionsItem) -> Void in
        
        let controller = PhotosPicker.AssetsControllerClass()
        controller.item = item
        collectionsController.navigationController?.pushViewController(controller, animated: true)
    }
    
}
