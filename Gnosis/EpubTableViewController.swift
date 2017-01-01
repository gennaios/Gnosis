//
//  EpubTableViewController.swift
//  Gnosis
//
//  Created by Gennaios on 31/12/2016.
//  Copyright © 2016 Gennaios. All rights reserved.
//

import Cocoa

class EpubTableViewController: NSViewController {

	@IBOutlet weak var tableView: NSTableView!

	var epubFile: EpubFile?

	var ePubViewControllers: [EpubViewController] = []

//	override var nibName: String {
//		return "EpubTableViewController"
//	}

	convenience init() {
		self.init(file: "")
	}

	init(file: String) {
		epubFile = EpubFile(file: file)
//		print("ePub title: \(epubFile?.title!)")

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

	override func viewDidLoad() {
        super.viewDidLoad()

		tableView.delegate = self
		tableView.dataSource = self
    }

}

extension EpubTableViewController: NSTableViewDataSource {

	func numberOfRows(in tableView: NSTableView) -> Int {
		return epubFile?.documentList.count ?? 0
	}

//	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
//
//	}

}

// height: https://stackoverflow.com/questions/7504546/view-based-nstableview-with-rows-that-have-dynamic-heights?rq=1

extension EpubTableViewController: NSTableViewDelegate {

//	func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
//		guard let epubDocument = epubFile?.documentList[row] else {
//			return nil
//		}
//
//		let epubViewController = EpubViewController()
//		epubViewController.htmlForIndex(index: row)
//		return epubViewController.view
//	}

	func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
//		return ePubViewControllers[row].webView!.frame.height
		return CGFloat(500)
	}

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		var cellIdentifier: String = ""

		guard (epubFile?.documentList[row]) != nil else {
			return nil
		}

		if tableColumn == tableView.tableColumns[0] {
			cellIdentifier = "FileCell"
		}

		if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
//			print("Creating table cell")
//			cell.bounds = ePubViewControllers[row].view.frame
			cell.addSubview(ePubViewControllers[row].view)
			cell.setNeedsDisplay(ePubViewControllers[row].view.frame)
			return cell
		}
		return nil
	}

}
