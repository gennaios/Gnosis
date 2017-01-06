//: Playground - noun: a place where people can play

import Cocoa
import Ji

import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct GnosisEpubContentsEntry {
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

var contentsEnties = [GnosisEpubContentsEntry]()

let tocFile = Bundle.main.path(forResource: "toc", ofType: "ncx")
let ncxXml = Ji(contentsOfURL: URL(fileURLWithPath: tocFile!), isXML: true)

var navPoints = ncxXml?.rootNode?.firstChildWithName("navMap")

let children = navPoints?.children
for child in children! {
	let entryId = child["id"]
	let entryPlayOrder = Int(child["playOrder"]!)
	let entrySrc = child.descendantsWithName("content").first?["src"]
	let entryTitle = child.descendantsWithName("text").first?.content

	guard let id = entryId, let title = entryTitle, let src = entrySrc else {
		continue
	}
	
	let playOrder = entryPlayOrder ?? nil
	let tocEntry = GnosisEpubContentsEntry(id: id, playOrder: playOrder, title: title, src: src)

	contentsEnties.append(tocEntry)
}

print("Entries: \(contentsEnties.count)")
for entry in contentsEnties {
	print("Entry: \(entry.id), \(entry.title), \(entry.src)")
}

// 2nd attempt

var contentsEntries2 = [GnosisEpubContentsEntry]()

let children2 = navPoints?.descendantsWithName("navPoint")
for child in children2! {
	let entryId = child["id"]
	let entryPlayOrder = Int(child["playOrder"]!)
	let entrySrc = child.descendantsWithName("content").first?["src"]
	let entryTitle = child.descendantsWithName("text").first?.content
	
	guard let id = entryId, let title = entryTitle, let src = entrySrc else {
		continue
	}
	
	let playOrder = entryPlayOrder ?? nil
	let tocEntry = GnosisEpubContentsEntry(id: id, playOrder: playOrder, title: title, src: src)
	
	contentsEntries2.append(tocEntry)
}

print("Entries: \(contentsEntries2.count)")
for entry in contentsEntries2 {
	print("Entry2: \(entry.id), \(entry.title), \(entry.src)")
}



