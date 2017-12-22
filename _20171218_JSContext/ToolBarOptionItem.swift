//
//  ToolBarOptionItem.swift
//  _20171218_JSContext
//
//  Created by Kim Hyun-Seok on 2017. 12. 22..
//  Copyright © 2017년 Kim Hyun-Seok. All rights reserved.
//

import Foundation
import UIKit
import WebKit

protocol ToolBarOptionItemProtocol {
    var image: UIImage? { get }
    var title: String { get }
}

class ToolBarOptionItem: UIView, ToolBarOptionItemProtocol {
    var button: UIButton?
    
    var image: UIImage?
    var title: String
    var webView: WKWebView
    
    init(frame: CGRect, image: UIImage?, title: String, webView: WKWebView) {
        self.image = image
        self.title = title
        self.webView = webView
        
        super.init(frame: frame)
        
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialize() {
        self.button = UIButton(frame: self.frame)
        self.button?.setBackgroundImage(self.image, for: UIControlState.normal)
        
        self.addSubview(self.button!)
        
        self.button?.addTarget(self, action: #selector(self.tappedBtn(_:)), for: UIControlEvents.touchUpInside)
    }
    
    @objc private func tappedBtn(_ sender: AnyObject) {
        // print("self.title : \(self.title)")
        
        self.webView.evaluateJavaScript("setEditorCommand()") { (result, error) in
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
}
