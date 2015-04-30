//
//  ViewController.swift
//  PhotosPickerExample
//
//  Created by Muukii on 3/22/15.
//  Copyright (c) 2015 muukii. All rights reserved.
//

import UIKit
import PhotosPicker

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        let controller = PhotosPickerController()
        self.presentViewController(controller, animated: true) { () -> Void in
            
        }
        
        PhotosPickerController.requestDefaultCollections { assets in
            
            let section = PhotosPickerCollectionsSection(title: "カメラロール")
            section.items = assets
            controller.collectionController?.sectionInfo = [section]
            controller.collectionController?.tableView?.reloadData()            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

