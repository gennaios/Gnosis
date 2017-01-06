//
// Created by Gennaios on 06/01/2017.
// Copyright (c) 2017 Gennaios. All rights reserved.
//

import Foundation

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
