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

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func handleButton(sender: AnyObject) {
        let controller = PhotosPickerController(collectionsControllerClass: CustomPhotosPickerCollectionsController.self)
        self.presentViewController(controller, animated: true) { () -> Void in
            
        }
        
        PhotosPicker.requestDefaultCollections { assets in
            
            let section1 = PhotosPickerCollectionsSection(title: "Muukii's Photo")
            let item1 = PhotosPickerCollectionsItem(title: "Muukii's Faces", numberOfAssets: 4, assets: PhotosPickerAssetsGroup(assets: [Photo(),Photo(),Photo(),Photo()]))
            let item2 = PhotosPickerCollectionsItem(title: "Muukii's Hands", numberOfAssets: 4, assets: PhotosPickerAssetsGroup(assets: [Photo(),Photo(),Photo(),Photo()]))
            section1.items = [item1, item2]

            let section2 = PhotosPickerCollectionsSection(title: "Cameraroll")
            section2.items = assets
            controller.collectionController?.sectionInfo = [section1, section2]
            controller.collectionController?.tableView?.reloadData()
                        
        }
        
        controller.didCancel = { picker in
            
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
    }

}

