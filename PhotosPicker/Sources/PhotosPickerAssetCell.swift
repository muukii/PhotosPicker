// PhotosPickerAssetCell.swift
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

public class PhotosPickerAssetCell: UICollectionViewCell {

    public weak var thumbnailImageView: UIImageView?
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.setup()
        self.setupSelectedOverlayView()
    }

    public required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
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
        
        self.contentView.addSubview(thumbnailImageView)
        
        self.thumbnailImageView = thumbnailImageView

        
        let views = [
            "thumbnailImageView": thumbnailImageView,
        ]
        
        self.contentView.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-(0)-[thumbnailImageView]-(0)-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views
            )
        )
        
        self.contentView.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-(0)-[thumbnailImageView]-(0)-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views
            )
        )
    }
    
    public override var selected: Bool {
        get {
            
            return super.selected
        }
        set {
            
            super.selected = newValue
            self._selectedOvarlayView?.hidden = !newValue
        }
    }
    
    public func selectedOverlayView() -> UIView {
        
        let imageView = UIImageView(image: UIImage(named: "check.png"))
        return imageView
    }
    
    private func setupSelectedOverlayView() {
        
        let view = self.selectedOverlayView()
        view.frame = self.bounds
        self.contentView.addSubview(view)
        self._selectedOvarlayView = view
    }
    
    private var _selectedOvarlayView: UIView?
}
