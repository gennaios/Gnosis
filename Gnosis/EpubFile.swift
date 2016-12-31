//
//  EpubFile.swift
//  Gnosis
//
//  Created by Gennaios on 24/12/2016.
//  Copyright © 2016 Gennaios. All rights reserved.
//

import AppKit
import Foundation
import UnzipKit
import Ji

@objc(Epub) class EpubFile: NSObject {
	// MARK: Variables
	var filePath = String()
	var fileArchive: UZKArchive?
	var extractedPath = String()
	
	var innerBasePath: String? = nil
	
	var documentList = [String]()
	var currentDocument: Int = -1
	
	//    var author = String()
	//    var title = String()
	
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
		}
		
		if let cachePath = cachePath() {
			self.extractedPath = cachePath
		}
		print("Extracted path: \(self.extractedPath)")
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
	
}