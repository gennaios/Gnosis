//: Playground - noun: a place where people can play

import Cocoa
import Ji

import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct GnosisEpubTocEntry {
	var id: String = ""
	var playOrder: Int?
	var title: String = ""
	var src: String = ""
	
	init (id: String, playOrder: Int?, title: String, src: String)
	{
		self.id = id
		self.playOrder = playOrder
		self.title = title
		self.src = src
	}
	
}

var tocEntries = [GnosisEpubTocEntry]()

let tocFile = Bundle.main.path(forResource: "toc", ofType: "ncx")
let ncxXml = Ji(contentsOfURL: URL(fileURLWithPath: tocFile!), isXML: true)

var navPoints = ncxXml?.rootNode?.firstChildWithName("navMap")

let children = navPoints?.children
for child in children! {
	let entryId = child["id"]
	let entryPlayOrder = Int(child["playOrder"]!)
	let entrySrc = children![0].descendantsWithName("content").first?["src"]
	let entryTitle = children![0].descendantsWithName("text").first?.content

	guard let id = entryId, let title = entryTitle, let src = entrySrc else {
		continue
	}
	
	let playOrder = entryPlayOrder ?? nil
	let tocEntry = GnosisEpubTocEntry(id: id, playOrder: playOrder, title: title, src: src)

	tocEntries.append(tocEntry)
}

// let id = tocEntries[0].id

