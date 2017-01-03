//
//  MainWindowController.swift
//  Gnosis
//
//  Created by Gennaios on 31/12/2016.
//  Copyright © 2016 Gennaios. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

	@IBOutlet weak var mainView: NSView!

	var epubViewController: EpubViewController!
	var epubTableViewController: EpubTableViewController!
	var epubCollectionViewController: EpubCollectionViewController!

	var epubFile: String?

	override func windowDidLoad() {
        super.windowDidLoad()

		self.window!.titleVisibility = .hidden // Yosemite look

		mainView.autoresizesSubviews = true

		epubFile = self.document?.fileURL??.path
		print("WindowController epubFile: \(epubFile)")

//		epubViewController = EpubViewController(file: epubFile!)
//		epubViewController.view.frame = mainView.bounds
//		epubViewController.view.autoresizingMask = NSAutoresizingMaskOptions([.viewWidthSizable, .viewMaxXMargin, .viewMinYMargin, .viewHeightSizable, .viewMaxYMargin])
//
//		mainView.addSubview(epubViewController.view)

		epubTableViewController = EpubTableViewController(file: epubFile!)
		epubTableViewController.view.frame = mainView.bounds
		epubTableViewController.view.autoresizingMask = NSAutoresizingMaskOptions([.viewWidthSizable, .viewMaxXMargin, .viewMinYMargin, .viewHeightSizable, .viewMaxYMargin])

		mainView.addSubview(epubTableViewController.view)

//		epubCollectionViewController = EpubCollectionViewController(file: epubFile!)
//		epubCollectionViewController.view.frame = mainView.bounds
//		epubCollectionViewController.view.autoresizingMask = NSAutoresizingMaskOptions([.viewWidthSizable, .viewMaxXMargin, .viewMinYMargin, .viewHeightSizable, .viewMaxYMargin])
//
//		mainView.addSubview(epubCollectionViewController.view)

	}

}
