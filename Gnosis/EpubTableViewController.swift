//
//  EpubTableViewController.swift
//  Gnosis
//
//  Created by Gennaios on 31/12/2016.
//  Copyright © 2016 Gennaios. All rights reserved.
//

import Cocoa
import WebKit

class EpubTableViewController: NSViewController {

	@IBOutlet weak var tableView: NSTableView!

	var epubFile: EpubFile?

	var ePubViews: [WebView] = []
	var epubViewHeights: [Int] = []

//	override var nibName: String {
//		return "EpubTableViewController"
//	}

	convenience init() {
		self.init(file: "")
	}

	init(file: String) {
		super.init(nibName: nil, bundle: nil)!

		epubFile = EpubFile(file: file)
//		print("ePub title: \(epubFile?.title!)")

		initWebViews()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.delegate = self
		tableView.dataSource = self
	}

	func initWebViews() {
		for index in 0 ... ((epubFile?.documentCount)! - 1) {
			print("Index: \(index)")

			let html = epubFile?.htmlForIndex(index: index)

			let webView = WebView(frame: self.view.bounds)
			let baseURL = URL(fileURLWithPath: (epubFile?.fileForIndex(index: index))!).deletingLastPathComponent()
			webView.mainFrame.loadHTMLString(html, baseURL: baseURL)

			webView.mainFrame.frameView.allowsScrolling = false
			webView.wantsLayer = true

			webView.frameLoadDelegate = self
			webView.resourceLoadDelegate = self
			webView.policyDelegate = self

			webView.autoresizingMask = NSAutoresizingMaskOptions([.viewWidthSizable, .viewMaxXMargin, .viewMinYMargin, .viewHeightSizable, .viewMaxYMargin])
			ePubViews.append(webView)

			epubViewHeights.append(200)
		}

	}
}

extension EpubTableViewController: NSTableViewDataSource {

	func numberOfRows(in tableView: NSTableView) -> Int {
		return epubFile?.documentList.count ?? 0
	}

}

// height: https://stackoverflow.com/questions/7504546/view-based-nstableview-with-rows-that-have-dynamic-heights?rq=1

extension EpubTableViewController: NSTableViewDelegate {

	func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		if epubViewHeights.count == (epubFile?.documentCount)! {
			return CGFloat(epubViewHeights[row])
		} else {
			return CGFloat(300)
		}
	}

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard (epubFile?.documentList[row]) != nil else {
			return nil
		}
		return ePubViews[row]
	}

}

// https://stackoverflow.com/questions/2675244/how-to-resize-webview-according-to-its-content
// https://stackoverflow.com/questions/3936041/how-to-determine-the-content-size-of-a-uiwebview
// https://stackoverflow.com/questions/19885771/resizing-a-webview-instance
// https://stackoverflow.com/questions/8307776/resizing-uiwebview-height-to-fit-content
// https://stackoverflow.com/questions/10294164/webview-dynamic-resize-to-content-size?noredirect=1&lq=1

extension EpubTableViewController: WebFrameLoadDelegate {

	func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {

		for ePubView in ePubViews {
			if sender == ePubView {
				let heightString = sender.stringByEvaluatingJavaScript(from: "document.body.scrollHeight")
//				let heightString = sender.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].offsetHeight")
//				let heightString = sender.stringByEvaluatingJavaScript(from: "document.documentElement.scrollHeight")

				let index = ePubViews.index(of: ePubView)
				print("webView \(index) height: \(heightString)")
				epubViewHeights[index!] = Int(heightString!)!

				tableView.reloadData()
			}
		}

	}

	func webView(_ sender: WebView!, didStartProvisionalLoadFor frame: WebFrame!) {
		//		webView.mainFrame.provisionalDataSource
//		print("didStartProvisionalLoadForFrame: \(frame)")
	}

}

extension EpubTableViewController: WebResourceLoadDelegate {

	func webView(_ sender: WebView!, resource identifier: Any!, willSend request: URLRequest!, redirectResponse: URLResponse!, from dataSource: WebDataSource!) -> URLRequest! {
//        print("redirectResponse request: \(request.url!)")
//		print("redirectResponse resource: \(identifier)")

		guard let url = request.url else {
			return request
		}

		if url.scheme == "file" {
			let anchorFromURL = url.fragment
			let path = url.path
			print("willSend request: path \(path) anchorFromURL: \(anchorFromURL)")
		}

		return request
//		return nil
	}

}

extension EpubTableViewController: WebPolicyDelegate {

	//	func webView(_ sender: WebView!, resource: Any!, error: Error!, from: WebDataSource!) {
	//		print("WebPolicyDelegate error: \(error)")
	//	}

	func webView(_ webView: WebView!, decidePolicyForNewWindowAction actionInformation: [AnyHashable: Any]!, request: URLRequest!, newFrameName frameName: String!, decisionListener listener: WebPolicyDecisionListener!) {
//        print("decidePolicyForNewWindowAction: \(request.url)")
	}

}
