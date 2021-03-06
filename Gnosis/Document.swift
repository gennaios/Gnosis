//
//  Document.swift
//  Gnosis
//
//  Created by Gennaios on 30/12/2016.
//  Copyright © 2016 Gennaios. All rights reserved.
//

import Cocoa

class Document: NSDocument {

	// MARK: - Variables

	var mainWindowController: NSWindowController?
	var epubFile: BookLibrary!

	// MARK: - Init

	override init() {
		super.init()
		// Add your subclass-specific initialization here.
	}

	override class func autosavesInPlace() -> Bool {
		return false
	}

	override func makeWindowControllers() {
		//	super.makeWindowControllers()
		mainWindowController = MainWindowController(windowNibName: "MainWindowController")
		self.addWindowController(mainWindowController!)
	}

	override func data(ofType typeName: String) throws -> Data {
		// Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
		// You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

	override func read(from url: URL, ofType typeName: String) throws {
		// Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
		// You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
		// If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.

		epubFile = BookLibrary(file: url.path)

//		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

//	override var objectSpecifier: NSScriptObjectSpecifier {
//		let appDescription = NSApplication.shared().classDescription as! NSScriptClassDescription
//
//		let specifier = NSUniqueIDSpecifier(containerClassDescription: appDescription,
//				containerSpecifier: nil, key: "documents", uniqueID: filePath)
//		return specifier
//	}

}

