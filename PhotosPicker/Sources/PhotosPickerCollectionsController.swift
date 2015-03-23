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
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.view.addSubview(tableView)
        self.tableView = tableView
        
        let tableViewTop = NSLayoutConstraint(
            item: tableView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: .Top,
            multiplier: 1,
            constant: 0)
        
        let tableViewRight = NSLayoutConstraint(
            item: tableView,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: .Right,
            multiplier: 1,
            constant: 0)
        
        let tableViewBottom = NSLayoutConstraint(
            item: tableView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: .Bottom,
            multiplier: 1,
            constant: 0)
        
        let tableViewLeft = NSLayoutConstraint(
            item: tableView,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: .Left,
            multiplier: 1,
            constant: 0)
        
        self.view.addConstraints([
            tableViewTop,
            tableViewRight,
            tableViewBottom,
            tableViewLeft,
            ])
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