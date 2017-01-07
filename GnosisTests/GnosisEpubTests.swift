//
//  GnosisEpubTests.swift
//  Gnosis
//
//  Created by Gary on 07/01/2017.
//  Copyright © 2017 Gennaios. All rights reserved.
//

import XCTest

@testable import Gnosis

class GnosisEpubTests: XCTestCase {

	var epubFile = ""
	var epub: GnosisEpub!

	override func setUp() {
		super.setUp()
		let epubFile = Bundle.main.path(forResource: "epub-test", ofType: "epub")

		if let epubFile = epubFile {
			self.epubFile = epubFile
			epub = GnosisEpub(file: epubFile)
		}
	}

	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}

	func testEpubParsePerformance() {
		let epubFile = Bundle.main.path(forResource: "epub-test", ofType: "epub")

		if let epubFile = epubFile {
			self.measure() {
				let _ = GnosisEpub(file: epubFile)
			}
		}
	}

	func testValidEpub() {
		XCTAssertEqual(epub.isValid(), true, "ePub should be valid")
	}

	func testEpubTitle() {
		if let title = epub.title?.first {
			XCTAssertEqual(title, "ePub Reader Test", "should set title")
		}
	}

	func testEpubAuthors() {
			XCTAssertEqual(epub.authors, ["Jellby", "Charles King"], "should set authors")
	}

	func testEpubLanguages() {
		XCTAssertEqual(epub.languages, ["en"], "should set languages")
	}

}
