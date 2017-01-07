//
//  AppDelegate.swift
//  Gnosis
//
//  Created by Gennaios on 30/12/2016.
//  Copyright © 2016 Gennaios. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
		return false
	}

	func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
		return false
	}

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	override func indicesOfObjects(byEvaluatingObjectSpecifier specifier: NSScriptObjectSpecifier) -> [NSNumber]? {
		debugPrint(specifier)
		return super.indicesOfObjects(byEvaluatingObjectSpecifier: specifier)
	}

}

