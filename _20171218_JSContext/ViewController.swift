//
//  ViewController.swift
//  _20171218_JSContext
//
//  Created by Kim Hyun-Seok on 2017. 12. 18..
//  Copyright © 2017년 Kim Hyun-Seok. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate ,WKNavigationDelegate, WKScriptMessageHandler {
    // const
    let const = CONST()
    let messageHandlerName = "callbackHandler"
    
    // IBOutlet
    @IBOutlet weak var containerView: UIView!
    
    // variables
    var wkWebView: WKWebView?
    
    // WKScriptMessageHandler protocol
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == messageHandlerName {
            print("message.body: \(message.body)") // print "hello from javascript"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setWebView()
        self.setPreviewBtn()
        
        /*
        self.setKeyboardInputAccessoryView()
        self.setKeyboardObservers()
        */
    }
    
    func setWebView() {
        let contentController: WKUserContentController = WKUserContentController()
        contentController.add(self, name: messageHandlerName)
        
        let configuration: WKWebViewConfiguration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        
        wkWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), configuration: configuration)
        wkWebView!.translatesAutoresizingMaskIntoConstraints = false
        wkWebView!.uiDelegate = self
        wkWebView!.navigationDelegate = self
        
        containerView.addSubview(wkWebView!)
        
        let horizontalVFS = NSLayoutConstraint.constraints(withVisualFormat: "|-\(0)-[wkWebView]-\(0)-|", options: [], metrics: nil, views: ["wkWebView": wkWebView!])
        containerView.addConstraints(horizontalVFS)
        
        let verticalVFS = NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(0)-[wkWebView]-\(0)-|", options: [], metrics: nil, views: ["wkWebView": wkWebView!])
        containerView.addConstraints(verticalVFS)
        
        if let url = Bundle.main.url(forResource: "main", withExtension: "html") {
            wkWebView!.load(URLRequest(url: url))
        }
    }
    
    func setKeyboardInputAccessoryView() {
        // TODO: make dummy toolbar
        let toolBarHeight: CGFloat = 60
        
        let scrollViewFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: toolBarHeight)
        let scrollView: UIScrollView = UIScrollView(frame: scrollViewFrame)
        
        let optionItemNames: [String] = ["bold", "italic", "underline", "strike", "undo", "redo"]
        let optionItemFrame: CGRect = CGRect(x: 0, y: 0, width: 60, height: 60)
        
        var optionItem: ToolBarOptionItem
        for (index, _) in optionItemNames.enumerated() {
            optionItem = ToolBarOptionItem(frame: optionItemFrame, image: UIImage(named: "btn-option-item"), title: optionItemNames[index], webView: wkWebView!)
            optionItem.frame.origin.x = CGFloat(index) * optionItemFrame.width
            
            scrollView.addSubview(optionItem)
        }
        
        scrollView.contentSize = CGSize(width: optionItemFrame.width * CGFloat(optionItemNames.count), height: toolBarHeight)
        
        wkWebView?.addRichEditorInputAccessoryView(accessoryView: scrollView)
    }
    
    func setKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        print("keyboardWillShow")
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        print("keyboardWillHide")
    }
    
    func setPreviewBtn() {
        let btnFrame = CGRect(x: 0, y: 200, width: 100, height: 50)
        
        let previewBtn = UIButton(frame: btnFrame)
        previewBtn.setTitle("preview", for: UIControlState.normal)
        previewBtn.setTitleColor(UIColor.red, for: UIControlState.normal)

        self.view.addSubview(previewBtn)
        
        previewBtn.addTarget(self, action: #selector(self.tappedPreviewBtn(_:)), for: UIControlEvents.touchUpInside)
    }
    
    @objc func tappedPreviewBtn(_ sender: AnyObject) {
        print("preview")
        self.startCaptureWebView(wkWebView: wkWebView!)
    }
    
    var wkWebViewFrame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var wkWebViewScrollContentOffset: CGPoint = CGPoint(x: 0, y: 0)
    var captureCount: UInt = 0
    
    func startCaptureWebView(wkWebView: WKWebView) {
        print("startCaptureWebView")
        
        // save webView frame, scrollContentOffset
        self.wkWebViewFrame = wkWebView.frame
        self.wkWebViewScrollContentOffset = wkWebView.scrollView.contentOffset
        
        print("when capture started, wkWebViewFrame : \(wkWebViewFrame)")
        print("when capture started, wkWebViewScrollContentOffset : \(wkWebViewScrollContentOffset)")
        
        // TODO: test instagram image size
        let scrollContentSize: CGSize = wkWebView.scrollView.contentSize
        
        let expectedHeightByRatio: CGFloat = (const.SIZE_INSTAGRAM.height / const.SIZE_INSTAGRAM.width) * scrollContentSize.width
        let contentSize: CGSize = CGSize(width: scrollContentSize.width, height: expectedHeightByRatio)
        let imageNum: UInt = UInt((scrollContentSize.height / contentSize.height).rounded(FloatingPointRoundingRule.up))
        
        print("scrollContentSize : \(scrollContentSize)")
        print("contentSize : \(contentSize)")
        print("imageNum : \(imageNum)")
        
        self.captureWebView(wkWebView: wkWebView, contentSizeToCapture: contentSize, imageNumToCapture: imageNum)
    }
    
    func captureWebView(wkWebView:WKWebView, contentSizeToCapture: CGSize, imageNumToCapture: UInt) {
        // wkWebView.frame = CGRect(x: self.wkWebViewFrame.origin.x, y: self.wkWebViewFrame.origin.y, width: contentSizeToCapture.width, height: contentSizeToCapture.height)
        // print("wkWebView.frame : \(wkWebView.frame)")
        
        let frame: CGRect = wkWebView.frame
        print("frame : \(frame)")
        
        // before capture, scroll to top.
        wkWebView.scrollView.contentOffset = CGPoint(x: 0.0, y: 0.0)
        
        // precede scroll webview for ready to capture
        var precedeScrollContentOffset: CGPoint = CGPoint(x: 0.0, y: 0.0)
        if frame.height <= contentSizeToCapture.height {
            precedeScrollContentOffset = CGPoint(x: 0.0, y: wkWebView.scrollView.contentSize.height - frame.height)
        }
        
        wkWebView.scrollView.contentOffset = precedeScrollContentOffset
        
        // start capture process
        Timer.scheduledTimer(timeInterval: 0.5, target: BlockOperation(block: {
            self.captureCount = 0
            self.repeatCaptureWebView(wkWebView: wkWebView, contentSizeToCapture: contentSizeToCapture, count: self.captureCount, imageNumToCapture: imageNumToCapture)
        }), selector: #selector(Operation.main), userInfo: nil, repeats: false)
    }
    
    func repeatCaptureWebView(wkWebView: WKWebView, contentSizeToCapture: CGSize, count: UInt, imageNumToCapture: UInt) {
        wkWebView.scrollView.contentOffset = CGPoint(x: 0, y: 0 + (CGFloat(count) * contentSizeToCapture.height))
        print("wkWebView.scrollView.contentOffset : \(wkWebView.scrollView.contentOffset)")
        
        UIGraphicsBeginImageContextWithOptions(contentSizeToCapture, true, UIScreen.main.scale)
        wkWebView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let screenshot: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(screenshot!, nil, nil, nil)
        
        self.captureCount = count + 1
        print("captureCount : \(self.captureCount)")
        
        if self.captureCount >= imageNumToCapture {
            self.endCaptureWebView(wkWebView: wkWebView)
            
        } else {
            Timer.scheduledTimer(timeInterval: 0.25, target: BlockOperation(block: {
                self.repeatCaptureWebView(wkWebView: wkWebView, contentSizeToCapture: contentSizeToCapture, count: self.captureCount, imageNumToCapture: imageNumToCapture)
            }), selector: #selector(Operation.main), userInfo: nil, repeats: false)
        }
    }
    
    func endCaptureWebView(wkWebView: WKWebView) {
        print("endCaptureWebView")
        
        wkWebView.frame = self.wkWebViewFrame
        wkWebView.scrollView.contentOffset = self.wkWebViewScrollContentOffset
        
        self.captureCount = 0
    }
    
    
    // require func for display javascript alert
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { _ in
            completionHandler()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     @IBAction func btnClicked(_ sender: Any) {
     wkWebView!.evaluateJavaScript("window.getMsg()") { (result, error) in
     if result != nil {
     print("result: \(result!)")
     } else {
     print("result is nil")
     }
     
     if error != nil {
     print("error: \(error!)")
     } else {
     print("error is nil")
     }
     }
     }
     */
}
