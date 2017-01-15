//
//  BookLibraryTests.swift
//  Gnosis
//
//  Created by Gennaios on 08/01/2017.
//  Copyright © 2017 Gennaios. All rights reserved.
//

import XCTest

@testable import Gnosis

class BookLibraryTests: XCTestCase {

	var book: BookLibrary!
	var file: String = ""

	override func setUp() {
		super.setUp()
		
		file = Bundle.main.path(forResource: "epub-test", ofType: "epub")!
		book = BookLibrary(file: file)
	}

	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}

	func testDbConnection() {
		let path = NSSearchPathForDirectoriesInDomains(
				.applicationSupportDirectory, .userDomainMask, true
		).first! + "/" + Bundle.main.bundleIdentifier!

		XCTAssertEqual("\(path)/gnosis.sqlite3", book.db.description)
	}

	func testInitBook() {
//		guard let epub = GnosisEpub(file: file) else {
//			XCTFail("should find sample ePub")
//			return
//		}

//		let book = BookLibrary(file: epub)

		XCTAssertNotNil(book.book, "should find sample epub")
	}

	func testPerformanceExample() {
		// This is an example of a performance test case.
		self.measure {
			// Put the code you want to measure the time of here.
		}
	}

}
