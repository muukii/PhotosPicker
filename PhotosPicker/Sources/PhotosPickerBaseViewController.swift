//
//  PhotosPickerBaseViewController.swift
//  PhotosPicker
//
//  Created by Hiroshi Kimura on 4/27/15.
//  Copyright (c) 2015 muukii. All rights reserved.
//

import UIKit

public class PhotosPickerBaseViewController: UIViewController {
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setupCloseBarButtonItem()        
    }
    
    public func closeBarButtonItem() -> UIBarButtonItem {
        
        let barButtonItem = UIBarButtonItem(title: "Close", style: .Done, target: self, action: "")
        return barButtonItem
    }
    
    private func setupCloseBarButtonItem() {
        
        let barButtonItem = self.closeBarButtonItem()
        barButtonItem.action = "handleCloseBarButtonItem:"
        barButtonItem.target = self
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private dynamic func handleCloseBarButtonItem(sender: UIBarButtonItem) {
        
        if let photosPickerController = self.parentViewController as? PhotosPickerController {
            
            photosPickerController.didCancel?(controller: photosPickerController)
        }
    }

}
