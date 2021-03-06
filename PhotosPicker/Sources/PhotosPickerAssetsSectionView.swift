// PhotosPickerAssetsSectionView
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

public class PhotosPickerAssetsSectionView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.setup()
        self.setAppearance()
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public class func sizeForSection(#collectionView: UICollectionView) -> CGSize {

        return CGSize(width: collectionView.bounds.width, height: 30)
    }
    
    public weak var sectionTitleLabel: UILabel?
    public var section: DayPhotosPickerAssets? {
        get {
            
            return _section
        }
        set {
            
            _section = newValue
            if let section = newValue {
                struct Static {
                    static var formatter: NSDateFormatter = {
                        let formatter = NSDateFormatter()
                        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
                        return formatter
                    }()
                }

                self.sectionTitleLabel?.text = Static.formatter.stringFromDate(section.date)
            }
        }
    }


    public func setup() {
        
        let sectionTitleLabel = UILabel()
        sectionTitleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.addSubview(sectionTitleLabel)
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.sectionTitleLabel = sectionTitleLabel
        
        let views = [
            "sectionTitleLabel": sectionTitleLabel
        ]
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "|-(10)-[sectionTitleLabel]-(10)-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views
            )
        )
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-[sectionTitleLabel]-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views
            )
        )
    }
    
    public func setAppearance() {
        
        self.backgroundColor = UIColor.whiteColor()
    }
    
    private var _section: DayPhotosPickerAssets?

}
