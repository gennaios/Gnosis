//
//  BookLibrary.swift
//  Gnosis
//
//  Created by Gennaios on 25/12/2016.
//  Copyright © 2016 Gennaios. All rights reserved.
//

import Foundation
import SQLite
import UnzipKit

class BookLibrary {

	// MARK: - Variables

	var book: GnosisEpub!

	var documentList = [String]()
	var documentCount = 0
	var extractedPath = String()

	var contents = [GnosisEpubContentsEntry]()

	// SQLite.swift

	var db: Connection!
	let files = Table("files")

	let id = Expression<Int64>("id")
	let file = Expression<String>("file")
	let uuid = Expression<String>("uuid")
	let last_opened = Expression<Date>("last_opened")
	let last_modified = Expression<Date>("last_modified")

	// MARK: - Init

	/// Connects to SQLite, creates book entry with UUID for unzipped cache folder path, update last_opened date, re-unzip if ePub last_updated > ….
	///
	/// - Parameter book: string to ePub file
	init(file: String) {
		guard initConnection() == true else {
			return
		}

		initTables()

		// unzip, TODO: if last_modified changed, re-unzip
		let _ = getFileUuid(filePath: file)

//		do {
			extractedPath = cachePath(file: file)!

//			if foundBook2[0][last_modified] != fileModDate {
//				try db.run(foundBook.update(last_modified <- fileModDate))
//				extractFile(file: file, path: extractedPath, overwrite: true)
//			} else {
				extractFile(file: file, path: extractedPath, overwrite: false)
//			}
//		} catch {
//			print("Init error getting file attributes or extracting file")
//		}

		book = GnosisEpub(file: file)
		parseSpine()
		contents = (book.parseContents())!
	}

	func initConnection() -> Bool {
		let appSupportPath = NSSearchPathForDirectoriesInDomains(
				.applicationSupportDirectory, .userDomainMask, true
		).first! + "/" + Bundle.main.bundleIdentifier!

		// create parent directory if it doesn't exist
		let _ = try! FileManager.default.createDirectory(
				atPath: appSupportPath, withIntermediateDirectories: true, attributes: nil
		)

		do {
			db = try Connection("\(appSupportPath)/gnosis.sqlite3")
			if db.description == "\(appSupportPath)/gnosis.sqlite3" {
				return true
			}
		} catch {
			print("Error creating db: \(error).")
		}
		return false
	}

	func initTables() {
		do {
			try db?.run(files.create(ifNotExists: true) { t in
				t.column(id, primaryKey: .autoincrement)
				t.column(file, unique: true)
				t.column(uuid, unique: true)
				t.column(last_opened)
				t.column(last_modified)
			})

//            t.foreignKey(file_id, references: files, id, delete: .setNull)
		} catch {
			print("Error creating db: \(error).")
		}
	}

	// MARK: - Methods

	func cachePath(file: String) -> String? {
		let uuid = getFileUuid(filePath: file)
		print("File uuid: \(uuid)")

		let path = NSSearchPathForDirectoriesInDomains(
				.cachesDirectory, .userDomainMask, true
		).first! + "/" + Bundle.main.bundleIdentifier!

		// create parent directory if it doesn't exist
		let _ = try! FileManager.default.createDirectory(
				atPath: path, withIntermediateDirectories: true, attributes: nil
		)
		if let uuid = uuid {
			return path + "/" + uuid + "/"
		} else {
			return nil
		}
	}

	func extractFile(file: String, path: String, overwrite: Bool) {
		do {
			let fileArchive = try UZKArchive.init(path: file)
			try fileArchive.extractFiles(to: path, overwrite: overwrite)
		} catch {
			print("Error extracting file: \(error)")
		}
	}

	func getFileUuid(filePath: String) -> String? {
		guard FileManager.default.fileExists(atPath: filePath) else {
			return nil
		}

		do {
			let query = Array(try db.prepare(files.filter(self.file == filePath)))
			// TODO: update last_opened
			guard query.count != 1 else {
				return query[0][uuid]
			}
		} catch {
			print("Error in query: \(error).")
		}

		let newUuid = NSUUID().uuidString

		do {
			let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
			let fileModDate = fileAttributes[FileAttributeKey.modificationDate] as! Date

			let newFileId = try db?.run(files.insert(self.file <- filePath, uuid <- newUuid, last_modified <- fileModDate, last_opened <- Date()))
			let query = Array(try db.prepare(files.filter(self.id == newFileId!)))
			return query[0][uuid]
		} catch {
			print("Error creating new book: \(error).")
		}
		return nil
	}

	func parseSpine() {
		guard let spineNode = book?.spineNode, let manifestNode = book?.manifestNode else {
			return
		}

			let spineItems = spineNode.childrenWithName("itemref")
			for item in spineItems {
				if item["linear"] != "no" {
					let idref = item["idref"]
					//                    print("Spine item: \(idref)")

					// manifest item href with id
					let href = manifestNode.firstChildWithAttributeName("id", attributeValue: idref!)
					if href != nil {
						let spineItem = href!["href"]
						let spineURL = (book?.innerBasePath!)! + spineItem!
						documentList.append(spineURL)
					}
				}
			}
	}


	func fileForIndex(index: Int) -> String? {
		let filePath = extractedPath + documentList[index]
		return filePath
	}

	func dataForIndex(index: Int) -> Data {
		let rawHtml = fileForIndex(index: index)
		let html = prepareHtml(htmlFile: rawHtml!)!
		let base64String = Data(html.utf8).base64EncodedString()
		//		let data = Data(base64Encoded: base64String, options: Data.Base64DecodingOptions)
		return base64String.data(using: String.Encoding.utf8)!
	}

	func htmlForIndex(index: Int) -> String {
		let html = fileForIndex(index: index)
		return prepareHtml(htmlFile: html!)!
	}

	func prepareHtml(htmlFile: String) -> String? {
		let fileContents = try? String(contentsOfFile: htmlFile, encoding: String.Encoding.utf8)
		let cssFile = Bundle.main.path(forResource: "style", ofType: "css")
		let cssFile2 = Bundle.main.path(forResource: "style2", ofType: "css")

		//        print("CSS file path: \(cssFile)")

		let cssTag = "<link href=\"\(cssFile!)\" rel=\"stylesheet\" type=\"text/css\"/>"
		let cssTag2 = "<link href=\"\(cssFile2!)\" rel=\"stylesheet\" type=\"text/css\"/>"
		let toInject = "\n\(cssTag)\n\(cssTag2)\n</head>"

		let newContents = fileContents?.replacingOccurrences(of: "</head>", with: toInject)

		// let path = NSBundle.mainBundle().pathForResource("jsFileName", ofType: "js")
		//        if let content = String.stringWithContentsOfFile(path, encoding: NSUTF8StringEncoding, error: nil) {
		//            println("js content is \(content)")
		//        }

		return newContents
	}

}
