//
//  EpubViewController.swift
//  Gnosis
//
//  Created by Gennaios on 31/12/2016.
//  Copyright © 2016 Gennaios. All rights reserved.
//

import Cocoa
import WebKit

let leftArrowKey = 123
let rightArrowKey = 124

class EpubViewController: NSViewController {

    var webView: WebView?

    var epubFile: EpubFile?
    var EpubFilePath: String!

    //    var bookFile: String = ""
    var bookTitle: String = ""
    var bookAuthor: String = ""

    convenience init() {
        self.init(file: "")
    }

    init(file: String) {
        epubFile = EpubFile(file: file)
        print("ePub title: \(epubFile?.title!)")

        super.init(nibName: nil, bundle: nil)!
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WebView(frame: self.view.bounds)
        //		self.view.addSubview(webView!)
        self.view = self.webView!

        webView?.frameLoadDelegate = self
        webView?.resourceLoadDelegate = self
        webView?.policyDelegate = self

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            (aEvent) -> NSEvent? in
            self.keyDown(with: aEvent)
            return aEvent
        }
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

    func loadFile(file: String) {
        let baseURL = URL(fileURLWithPath: file).deletingLastPathComponent()
        let htmlString = prepareHtml(htmlFile: file)

        let _ = webView?.mainFrame.loadHTMLString((htmlString)!, baseURL: baseURL)
    }

    func nextPage() {
        let nextFile = epubFile?.nextFile()
        print("Next file: \(nextFile)")

        if let nextFile = nextFile {
            loadFile(file: nextFile)
        }
    }

    func previousPage() {
        let previousFile = epubFile?.previousFile()
        print("Previous file: \(previousFile)")

        if let previousFile = previousFile {
            loadFile(file: previousFile)
        }
    }

    override func keyDown(with event: NSEvent) {
        //        let eventChars = event.charactersIgnoringModifiers

        let character = Int(event.keyCode)
        switch character {
        case leftArrowKey:
            previousPage()
            break
        case rightArrowKey:
            nextPage()
            break
        default:
            break
        }

    }

}

extension EpubViewController: WebFrameLoadDelegate {

    func webView(_ sender: WebView!, didStartProvisionalLoadFor frame: WebFrame!) {
        //		webView.mainFrame.provisionalDataSource
//		print("didStartProvisionalLoadForFrame: \(frame)")
    }

}

extension EpubViewController: WebResourceLoadDelegate {

    func webView(_ sender: WebView!, resource identifier: Any!, willSend request: URLRequest!, redirectResponse: URLResponse!, from dataSource: WebDataSource!) -> URLRequest! {
        print("redirectResponse request: \(request.url!)")
//		print("redirectResponse resource: \(identifier)")

        guard let url = request.url else {
            return request
        }

        if url.scheme == "file" {
            let anchorFromURL = url.fragment
//			print("anchorFromURL: \(anchorFromURL)")

            let path = url.path
        }

        return request
    }

}

extension EpubViewController: WebPolicyDelegate {

    //	func webView(_ sender: WebView!, resource: Any!, error: Error!, from: WebDataSource!) {
    //		print("WebPolicyDelegate error: \(error)")
    //	}

    func webView(_ webView: WebView!, decidePolicyForNewWindowAction actionInformation: [AnyHashable: Any]!, request: URLRequest!, newFrameName frameName: String!, decisionListener listener: WebPolicyDecisionListener!) {
        print("decidePolicyForNewWindowAction: \(request.url)")
    }

}
