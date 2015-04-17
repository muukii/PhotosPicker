//
//  PhotosPickerCollectionsSection.swift
//  PhotosPicker
//
//  Created by Hiroshi Kimura on 4/17/15.
//  Copyright (c) 2015 muukii. All rights reserved.
//

import Foundation
import Photos

public class PhotosPickerCollectionsSection {

    public var title: String
    public var items: [PhotosPickerCollectionsItem]?
    public init(title: String) {
        
        self.title = title
    }
}
