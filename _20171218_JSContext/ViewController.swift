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
        self.setKeyboardInputAccessoryView()
        self.setKeyboardObservers()
        
        self.setPreviewBtn()
    }
    
    func setWebView() {
        let contentController: WKUserContentController = WKUserContentController()
        contentController.add(self, name: messageHandlerName)
        
        let configuration: WKWebViewConfiguration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        
        wkWebView = WKWebView(frame: self.view.frame, configuration: configuration)
        wkWebView!.uiDelegate = self
        wkWebView!.navigationDelegate = self
        
        self.view.addSubview(wkWebView!)
        
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
    
    // require func for display javascript alert
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { _ in
            completionHandler()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    
    var wkWebViewFrame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var count: UInt = 0
    
    
    func startCaptureWebView(wkWebView: WKWebView) {
        self.wkWebViewFrame = wkWebView.frame
        
        
        // save current content offset
        
        let webViewScrollContentOffset: CGPoint = wkWebView.scrollView.contentOffset
        print("webViewScrollContentOffset : \(webViewScrollContentOffset)")
        
        let contentSize: CGSize = wkWebView.scrollView.contentSize
        print("contentSize : \(contentSize)")
        
        // TODO: test instagram image size
        let heightByRatio: CGFloat = (const.SIZE_INSTAGRAM.height / const.SIZE_INSTAGRAM.width) * contentSize.width
        let size: CGSize = CGSize(width: contentSize.width, height: heightByRatio)
        print("size : \(size)")
        
        let imageNumToCapture: UInt = UInt((contentSize.height / size.height).rounded(FloatingPointRoundingRule.up))
        print("imageNumToCapture : \(imageNumToCapture)")
        
        // before capture, scroll to top.
        wkWebView.scrollView.contentOffset = CGPoint(x: 0.0, y: 0.0)
        
        self.captureWebView(wkWebView: wkWebView, contentSizeToCapture: size, imageNumToCapture: imageNumToCapture)
    }
    
    func captureWebView(wkWebView:WKWebView, contentSizeToCapture: CGSize, imageNumToCapture: UInt) {
        print("captureWebView")
        
        wkWebView.frame = CGRect(x: self.wkWebViewFrame.origin.x, y: self.wkWebViewFrame.origin.y, width: contentSizeToCapture.width, height: contentSizeToCapture.height)
        print("wkWebView.frame : \(wkWebView.frame)")
        
        self.count = 0
        self.repeatCaptureWebView(wkWebView: wkWebView, contentSizeToCapture: contentSizeToCapture, count: self.count, imageNumToCapture: imageNumToCapture)
        
        /*
        if self.timer != nil { timer!.invalidate() }
        self.timer = Timer.scheduledTimer(timeInterval: 5, target: BlockOperation(block: {
            wkWebView.scrollView.contentOffset = CGPoint(x: 0, y: 0 + (CGFloat(self.count) * contentSizeToCapture.height))
            print("wkWebView.scrollView.contentOffset : \(wkWebView.scrollView.contentOffset)")
            
            UIGraphicsBeginImageContextWithOptions(contentSizeToCapture, true , UIScreen.main.scale)
            wkWebView.layer.render(in: UIGraphicsGetCurrentContext()!)
            
            let screenshot: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            UIImageWriteToSavedPhotosAlbum(screenshot!, nil, nil, nil)
            
            self.count += 1
            
            if self.count >= imageNumToCapture {
                self.timer!.invalidate()
                
                self.count = 0
                
                wkWebView.frame = frame
                
                wkWebView.scrollView.contentOffset = CGPoint(x: 0.0, y: 0.0)
                
                self.endCaptureWebView()
            }
            
        }), selector: #selector(Operation.main), userInfo: nil, repeats: true)
        */
    }
    
    func repeatCaptureWebView(wkWebView: WKWebView, contentSizeToCapture: CGSize, count: UInt, imageNumToCapture: UInt) {
        wkWebView.scrollView.contentOffset = CGPoint(x: 0, y: 0 + (CGFloat(count) * contentSizeToCapture.height))
        print("wkWebView.scrollView.contentOffset : \(wkWebView.scrollView.contentOffset)")
        
        UIGraphicsBeginImageContextWithOptions(contentSizeToCapture, true , UIScreen.main.scale)
        wkWebView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let screenshot: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(screenshot!, nil, nil, nil)
        
        self.count = count + 1
        print("self.count : \(self.count)")
        
        if self.count >= imageNumToCapture {
            self.endCaptureWebView(wkWebView: wkWebView)
            
        } else {
            self.repeatCaptureWebView(wkWebView: wkWebView, contentSizeToCapture: contentSizeToCapture, count: self.count, imageNumToCapture: imageNumToCapture)
        }
    }
    
    func endCaptureWebView(wkWebView: WKWebView) {
        print("end")
        
        self.count = 0
        
        wkWebView.frame = self.wkWebViewFrame
        
        wkWebView.scrollView.contentOffset = CGPoint(x: 0.0, y: 0.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
