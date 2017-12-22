//
//  WKWebViewExtension.swift
//  _20171218_JSContext
//
//  Created by Kim Hyun-Seok on 2017. 12. 22..
//  Copyright © 2017년 Kim Hyun-Seok. All rights reserved.
//

import Foundation
import WebKit

private var accessoryViewHandle: UInt8 = 0

// reference: https://robopress.robotsandpencils.com/swift-swizzling-wkwebview-168d7e657106
extension WKWebView {
    func addRichEditorInputAccessoryView(accessoryView: UIView?) {
        guard let accessoryView = accessoryView else {
            return
        }
        
        objc_setAssociatedObject(self, &accessoryViewHandle, accessoryView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // find UIView which is "WKContentView" type
        var candidateView: UIView? = nil
        subviewsLoop: for view in self.scrollView.subviews {
            if String(describing: type(of: view)).hasPrefix("WKContent") {
                candidateView = view
                break subviewsLoop
            }
        }
        
        guard let targetView: UIView = candidateView else {
            return
        }
        
        let newClass: AnyClass? = classWithCustomAccessoryView(targetView: targetView)
        object_setClass(targetView, newClass!)
    }
    
    private func classWithCustomAccessoryView(targetView: UIView) -> AnyClass? {
        guard let targetSuperClass = targetView.superclass else {
            return nil
        }
        
        let customInputAccessoryViewClassName = "\(targetSuperClass)_CustomInputAccessoryView"
        
        var newClass: AnyClass? = NSClassFromString(customInputAccessoryViewClassName)
        if newClass != nil {
            return newClass
            
        } else {
            newClass = objc_allocateClassPair(object_getClass(targetView), customInputAccessoryViewClassName, 0)
        }
        
        let newMethod = class_getInstanceMethod(WKWebView.self, #selector(WKWebView.getCustomInputAccessoryView))
        class_addMethod(newClass.self, #selector(getter: UIResponder.inputAccessoryView), method_getImplementation(newMethod!), method_getTypeEncoding(newMethod!))
        
        objc_registerClassPair(newClass!)
        
        return newClass
    }
    
    @objc func getCustomInputAccessoryView() -> UIView? {
        var superWebView: UIView? = self
        
        while (superWebView != nil) && !(superWebView is WKWebView) {
            superWebView = superWebView?.superview
        }
        
        let customInputAccessory = objc_getAssociatedObject(superWebView!, &accessoryViewHandle)
        return customInputAccessory as? UIView
    }
}
