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
        
        let contentController: WKUserContentController = WKUserContentController()
        contentController.add(self, name: messageHandlerName)
        
        let configuration: WKWebViewConfiguration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        
        wkWebView = WKWebView(frame: self.view.bounds, configuration: configuration)
        wkWebView!.uiDelegate = self
        wkWebView!.navigationDelegate = self
        
        self.view = wkWebView
        
        // Do any additional setup after loading the view, typically from a nib.
        if let url = Bundle.main.url(forResource: "main", withExtension: "html") {
            wkWebView!.load(URLRequest(url: url))
        }
    }
    
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
}
