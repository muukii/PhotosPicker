PhotosPicker
============

Using PhotosFramework

Features
--------

-	[ ] Like UIImagePicker
-	[ ] Compatible iCloud (PhotoStream)
-	[ ] Multiple Selection
-	[ ] Divide daily
-	[ ] Crop

Requirements
------------

iOS 8.0+

Swift 1.2

Structure
---------

-	PhotosPickerController: UINavigationController
	-	PhotosPickerCollectionsController: UIViewController
		-	UITableView
		-	(You can customize in subclass.)
	-	PhotosPickerAssetsController: UIViewController
		-	UICollectionView
		-	(You can customize in subclass.)

CocoaPods
---------

Author
------

Muukii (@muukii0803)

License
-------

Alamofire is released under the MIT license. See LICENSE for details.
