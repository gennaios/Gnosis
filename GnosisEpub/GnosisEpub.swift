//
//  GnosisEpub.swift
//  Gnosis
//
//  Created by Gennaios on 24/12/2016.
//  Copyright © 2016 Gennaios. All rights reserved.
//

import AppKit
import Foundation
import UnzipKit
import Ji

@objc(Epub) class GnosisEpub: NSObject {
	// MARK: Variables
	var filePath = String()
	var contents = [GnosisEpubContentsEntry]()


	var fileArchive: UZKArchive?
	var extractedPath = String()

	var innerBasePath: String? = nil

	var documentList = [String]()
	var documentCount = 0

	var currentDocument: Int = -1

	// MARK: ePub metadata

	var opfNode: Ji? = nil
	var metadataNode: JiNode? = nil
	var manifestNode: JiNode? = nil
	var manifestItemsNode: JiNode? = nil
	var guideReferencesNode: JiNode? = nil
	var spineNode: JiNode? = nil

	var title: [String]? {
		get {
			if metadataNode != nil {
				let title = metadataNode?.childrenWithName("title")
				if title!.count > 0 {
					return [(title!.first?.content)!]
				}
			}
			return nil
		}
	}

	var authors: [String] {
		get {
			if metadataNode != nil {
				let creators = metadataNode?.childrenWithName("creator")
				if creators != nil {
					return creators!.map({ $0.content! })
				}
			}
			return [String]()
		}
	}

	var contributors: [String] {
		get {
			if metadataNode != nil {
				let contributors = metadataNode?.childrenWithName("contributor")
				if contributors != nil {
					return contributors!.map({ $0.content! })
				}
			}
			return [String]()
		}
	}

	var languages: [String] {
		get {
			if metadataNode != nil {
				let languages = metadataNode?.childrenWithName("language")
				if languages != nil {
					return languages!.map({ $0.content! })
				}
			} else {
			}
			return [String]()
		}
	}

	// MARK: Init

	override init() {
		self.filePath = ""
	}

	init(file: String) {
		super.init()

		self.filePath = file

		// parse container.xml

		var epubContainer: NSData? = nil
		var opfLocation: String? = nil
		var containerXml: Ji? = nil

		do {
			fileArchive = try UZKArchive.init(path: file)

		} catch let error as NSError {
			print(error.localizedDescription)
			return
		}

		do {
			epubContainer = try fileArchive?.extractData(fromFile: "META-INF/container.xml", progress: nil) as NSData?
		} catch let error as NSError {
			print(error.localizedDescription)
			return
		}

		if (epubContainer != nil) {
			containerXml = Ji(data: epubContainer as Data?, isXML: true)
		}

		if (containerXml != nil) {
			let opfPath = containerXml?.rootNode?.firstChildWithName("rootfiles")!.firstChildWithName("rootfile")!.attributes
			opfLocation = opfPath!["full-path"]
		}

		if opfLocation != nil {
			innerBasePath = NSString(string: opfLocation!).deletingLastPathComponent
		}

		if innerBasePath != nil {
			if innerBasePath != "" {
				innerBasePath = innerBasePath! + "/"
			}
		}

		// get OPF

		do {
			if opfLocation != nil {
				let opfData = try fileArchive?.extractData(fromFile: opfLocation!, progress: nil)
				opfNode = Ji(data: opfData, isXML: true)
			}
		} catch let error as NSError {
			print(error.localizedDescription)
			return
		}

		// read OPF

		if opfNode != nil {
			metadataNode = opfNode?.rootNode?.firstChildWithName("metadata")
			manifestNode = opfNode?.rootNode?.firstChildWithName("manifest")
			spineNode = opfNode?.rootNode?.firstChildWithName("spine")
			parseSpine()
			documentCount = documentList.count
		}

		if let cachePath = cachePath() {
			self.extractedPath = cachePath
		}
		print("Extracted path: \(self.extractedPath)")

		parseContents()
		extractFile()
	}

	override var objectSpecifier: NSScriptObjectSpecifier {
		let appDescription = NSApplication.shared().classDescription as! NSScriptClassDescription

		let specifier = NSUniqueIDSpecifier(containerClassDescription: appDescription,
				containerSpecifier: nil, key: "epubs", uniqueID: filePath)
		return specifier
	}


	func isValidBook() -> Bool {
		if metadataNode != nil {
			let title = metadataNode?.childrenWithName("title")
			if title!.count > 0 {
				return true
			}
		}
		return false
	}

	func cachePath() -> String? {
		let fileLib = FileLibrary()
		let uuid = fileLib.getFileUuid(filePath: filePath)
		print("File uuid: \(uuid!)")

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

	func extractFile() {
		do {
			try fileArchive?.extractFiles(to: self.extractedPath, overwrite: false)
		} catch {
			print("Error extracting file: \(error)")
		}
	}

	func parseContents() {
		let contentsNode = manifestNode?.firstChildWithAttributeName("id", attributeValue: "ncx")

		guard let contentsJiNode = contentsNode,
			let contentsHref = contentsJiNode["href"],
			let basePath = innerBasePath else {
			return
		}

		do {
			let optionalContentsData = try fileArchive?.extractData(fromFile: basePath + contentsHref, progress: nil) as Data?

			guard let contentsData = optionalContentsData else {
				return
			}

			let ncxXml = Ji(data: contentsData, isXML: true)
			let navPoints = ncxXml?.rootNode?.firstChildWithName("navMap")?.descendantsWithName("navPoint")

			for child in navPoints! {
				let entryId = child["id"]
				let entryPlayOrder = Int(child["playOrder"]!)
				let entrySrc = child.descendantsWithName("content").first?["src"]
				let entryTitle = child.descendantsWithName("text").first?.content

				guard let id = entryId, let title = entryTitle, let src = entrySrc else {
					continue
				}

				let playOrder = entryPlayOrder ?? nil
				let contentsEntry = GnosisEpubContentsEntry(id: id, playOrder: playOrder, title: title, src: src)

				contents.append(contentsEntry)
			}
		} catch let error {
			print("Error parsing contents: \(error)")
		}

//		for content in contents {
//			print("Contents: \(content.id), \(content.title), \(content.src)")
//		}
	}

	func parseSpine() {
		if spineNode != nil {
			let spineItems = spineNode?.childrenWithName("itemref")
			for item in spineItems! {
				if item["linear"] != "no" {
					let idref = item["idref"]
					//                    print("Spine item: \(idref)")

					// manifest item href with id
					let href = manifestNode?.firstChildWithAttributeName("id", attributeValue: idref!)
					if href != nil {
						let spineItem = href!["href"]
						let spineURL = innerBasePath! + spineItem!
						//                        print("Item URL: \(spineURL)")
						documentList.append(spineURL)
					}
				}
			}
		}
	}

	// MARK: Methods

	func fileForIndex(index: Int) -> String? {
		let filePath = extractedPath + documentList[index]
		return filePath
	}


	func nextFile() -> String? {
		guard currentDocument < documentList.count - 1  else {
			return nil
		}

		currentDocument = currentDocument + 1

		let filePath = extractedPath + documentList[currentDocument]
		return filePath
	}

	func previousFile() -> String? {
		guard currentDocument > 0 else {
			return nil
		}

		currentDocument = currentDocument - 1
		let filePath = extractedPath + documentList[currentDocument]
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
