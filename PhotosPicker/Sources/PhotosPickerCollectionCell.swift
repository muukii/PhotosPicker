// PhotosPickerCollectionCell.swift
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

public class PhotosPickerCollectionCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
        self.setAppearance()
    }
    
    public required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    public class func heightForRow() -> CGFloat {
        
        return 70.0
    }
    
    public weak var thumbnailImageView: UIImageView?
    public weak var collectionTitleLabel: UILabel?
    
    public var item: PhotosPickerCollectionsItem? {
        get {
            
            return _item
        }
        set {
            
            _item = newValue
            if let item = newValue {
                
                let attributedString1 = NSAttributedString(
                    string: item.title,
                    attributes: [
                        NSFontAttributeName: UIFont.boldSystemFontOfSize(16),
                        NSForegroundColorAttributeName: UIColor.blackColor(),
                    ]
                )
                
                let attributedString2 = NSAttributedString(
                    string: " (\(item.numberOfAssets))",
                    attributes: [
                        NSFontAttributeName: UIFont.systemFontOfSize(16),
                        NSForegroundColorAttributeName: UIColor.darkGrayColor(),
                    ]
                )
                
                let mutableAttributedString = NSMutableAttributedString()
                mutableAttributedString.appendAttributedString(attributedString1)
                mutableAttributedString.appendAttributedString(attributedString2)
                
                self.collectionTitleLabel?.attributedText = mutableAttributedString
                item.requestTopImage({ (image) -> Void in
                    
                    self.thumbnailImageView?.image = image
                })
            }
        }
    }
    
    public override func prepareForReuse() {
        
        super.prepareForReuse()
        self.thumbnailImageView?.image = nil
    }
    
    public func setup() {
        
        let thumbnailImageView = UIImageView()
        thumbnailImageView.contentMode = .ScaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let collectionTitleLabel = UILabel()
        collectionTitleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.contentView.addSubview(thumbnailImageView)
        self.contentView.addSubview(collectionTitleLabel)
        
        self.thumbnailImageView = thumbnailImageView
        self.collectionTitleLabel = collectionTitleLabel
    
        
        let views = [
            "thumbnailImageView": thumbnailImageView,
            "collectionTitleLabel": collectionTitleLabel
        ]
        
        self.contentView.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-(10)-[thumbnailImageView(50)]", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views
            )
        )
        
        self.contentView.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "|-(10)-[thumbnailImageView(50)]-(10)-[collectionTitleLabel]-(10)-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views
            )
        )
        
        self.contentView.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-[collectionTitleLabel]-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views
            )
        )
        
    }
    
    public func setAppearance() {
        
    }
    
    private var _item: PhotosPickerCollectionsItem?
}

