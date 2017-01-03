//
//  EpubCollectionViewItem.swift
//  Gnosis
//
//  Created by Gennaios on 01/01/2017.
//  Copyright © 2017 Gennaios. All rights reserved.
//

import Cocoa

class EpubCollectionViewItem: NSCollectionViewItem {
	
	@IBOutlet weak var mainView: NSView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.wantsLayer = true
		view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }

}
