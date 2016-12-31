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

	var epubFile: String?

	override func windowDidLoad() {
        super.windowDidLoad()

		self.window!.titleVisibility = .hidden // Yosemite look

		mainView.autoresizesSubviews = true

		epubFile = self.document?.fileURL??.path
		print("WindowController epubFile: \(epubFile)")
		
		epubViewController = EpubViewController(file: epubFile!)
		epubViewController.view.frame = mainView.bounds
		epubViewController.view.autoresizingMask = NSAutoresizingMaskOptions([.viewWidthSizable, .viewMaxXMargin, .viewMinYMargin, .viewHeightSizable, .viewMaxYMargin])

		mainView.addSubview(epubViewController.view)

	}

}
