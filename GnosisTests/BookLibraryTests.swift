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

	var books = BookLibrary()

	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}

	func testDbConnection() {
		let path = NSSearchPathForDirectoriesInDomains(
				.applicationSupportDirectory, .userDomainMask, true
		).first! + "/" + Bundle.main.bundleIdentifier!

		XCTAssertEqual("\(path)/gnosis.sqlite3", books.db.description)
	}

	func testPerformanceExample() {
		// This is an example of a performance test case.
		self.measure {
			// Put the code you want to measure the time of here.
		}
	}

}
