//
//  BookLibrary.swift
//  Gnosis
//
//  Created by Gennaios on 25/12/2016.
//  Copyright © 2016 Gennaios. All rights reserved.
//

import Foundation
import SQLite

class BookLibrary {
	
	// MARK: - Variables
	
	// SQLite.swift
	
	var db: Connection!
	let files = Table("files")
	
	let id = Expression<Int64>("id")
	let file = Expression<String>("file")
	let uuid = Expression<String>("uuid")
	let last_opened = Expression<Date?>("last_opened")
	let date_modified = Expression<Date?>("date_modified")

	// MARK: - Init
	
	init() {
		initConnection()
		initTables()
	}

	func initConnection() {
		let appSupportPath = NSSearchPathForDirectoriesInDomains(
			.applicationSupportDirectory, .userDomainMask, true
			).first! + "/" + Bundle.main.bundleIdentifier!
		
		// create parent directory if it doesn't exist
		let _ = try! FileManager.default.createDirectory(
			atPath: appSupportPath, withIntermediateDirectories: true, attributes: nil
		)
		
		do {
			db = try Connection("\(appSupportPath)/gnosis.sqlite3")
		} catch {
			print("Error creating db: \(error).")
		}
	}
	
	func initTables() {
		do {
			try db?.run(files.create(ifNotExists: true) { t in
				t.column(id, primaryKey: .autoincrement)
				t.column(file, unique: true)
				t.column(uuid, unique: true)
				t.column(last_opened)
				t.column(date_modified)
			})

//            t.foreignKey(file_id, references: files, id, delete: .setNull)
		} catch {
			print("Error creating db: \(error).")
		}
	}
	
	// MARK: - Methods

	func getFileUuid(filePath: String) -> String? {

		guard FileManager.default.fileExists(atPath: filePath) else {
			return nil
		}

		do {
			let query = Array(try db.prepare(files.filter(self.file == filePath)))
			guard query.count != 1 else {
				return query[0][uuid]
			}
		} catch {
			print("Error in query: \(error).")
		}

		let newUuid = NSUUID().uuidString

		do {
			let newFileId = try db?.run(files.insert(self.file <- filePath, uuid <- newUuid))
			let query = Array(try db.prepare(files.filter(self.id == newFileId!)))
			return query[0][uuid]
		} catch {
			print("Error creating new book: \(error).")
		}
		return nil
	}

}
