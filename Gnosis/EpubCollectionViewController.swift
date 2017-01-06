//
//  EpubCollectionViewController.swift
//  Gnosis
//
//  Created by Gennaios on 01/01/2017.
//  Copyright © 2017 Gennaios. All rights reserved.
//

import Cocoa

class EpubCollectionViewController: NSViewController {

	@IBOutlet weak var collectionView: NSCollectionView!

	let epubCollectionViewItemIdentifier = "epubCollectionViewItem"

	var epubFile: GnosisEpub?
	var ePubViewControllers: [EpubViewController] = []

	override var nibName: String {
		return "EpubCollectionViewController"
	}

	init(file: String) {
		epubFile = GnosisEpub(file: file)

		for index in 0...((epubFile?.documentCount)! - 1) {
			print("Index: \(index)")
			let epubViewController = EpubViewController(epubFile: epubFile!)
			epubViewController.htmlForIndex(index: index)

			epubViewController.view.autoresizingMask = NSAutoresizingMaskOptions([.viewWidthSizable, .viewMaxXMargin, .viewMinYMargin, .viewHeightSizable, .viewMaxYMargin])
			ePubViewControllers.append(epubViewController)
		}

		super.init(nibName: nil, bundle: nil)!
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	// MARK: Life Cycle

	override func viewDidLoad() {
        super.viewDidLoad()

		let nib = NSNib(nibNamed: "EpubCollectionViewItem", bundle: nil)
		collectionView.register(nib, forItemWithIdentifier: "epubCollectionViewItem")

		// Layout
		let layout = NSCollectionViewFlowLayout()
		// layout.sectionInset = UIEdgeInsetsZero
		layout.minimumLineSpacing = 0
		layout.minimumInteritemSpacing = 0
//		layout.scrollDirection = UICollectionViewScrollDirection.Vertical
		collectionView.collectionViewLayout = layout
		collectionView.minItemSize = NSSize(width:self.view.frame.width, height:CGFloat(200)) // double, int or CGFloat

		// CollectionView
		collectionView.dataSource = self
		collectionView.maxNumberOfColumns = 1
		collectionView.allowsMultipleSelection = false
		collectionView.allowsEmptySelection = false
		collectionView.isSelectable = false

		// new
//		collectionView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]

		collectionView.reloadData()
    }

}

// MARK: NSCollectionViewDataSource

extension EpubCollectionViewController: NSCollectionViewDataSource {
//	@available(OSX 10.11, *)
//	public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
//		// <#code#>
//	}

	func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
		return 1
	}

	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		print("CollectionView count: \(ePubViewControllers.count)")
		return (ePubViewControllers.count)
	}

	func collectionView(_ collectionView: NSCollectionView,
						itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		let item = collectionView.makeItem(withIdentifier: "epubCollectionViewItem", for: indexPath as IndexPath)

		if let epubCollectionViewItem = item as? EpubCollectionViewItem {
			epubCollectionViewItem.mainView.addSubview(ePubViewControllers[indexPath.item].view)
			epubCollectionViewItem.view.bounds = ePubViewControllers[indexPath.item].view.bounds
		}
		return item
	}

}
