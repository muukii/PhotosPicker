//
//  PhotosPickerCollectionsController.swift
//  PhotosPicker
//
//  Created by Muukii on 3/23/15.
//  Copyright (c) 2015 muukii. All rights reserved.
//

import UIKit

public class PhotosPickerCollectionsController: UIViewController {

    public weak var tableView: UITableView?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.addSubview(tableView)
        self.tableView = tableView
    }
    
    public convenience init() {
        
        self.init(nibName: nil, bundle: nil)
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    

}


extension PhotosPickerCollectionsController: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 0
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        return UITableViewCell()
    }
}