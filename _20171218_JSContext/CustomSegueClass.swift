//
//  CustomSegueClass.swift
//  _20171218_JSContext
//
//  Created by Kim Hyun-Seok on 2017. 12. 28..
//  Copyright © 2017년 Kim Hyun-Seok. All rights reserved.
//

import Foundation
import UIKit

class SegueFromRight: UIStoryboardSegue {
    override func perform() {
        let src = self.source as UIViewController
        let dest = self.destination as UIViewController
        
        src.view.superview?.insertSubview(dest.view, aboveSubview: src.view)
        dest.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            dest.view.transform = CGAffineTransform(translationX: 0, y: 0)
            src.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width / 2, y: 0)
            
        }, completion: { (isFinished) in
            src.present(dest, animated: false, completion: nil)
        })
    }
}

class UnwindSegueFromRight: UIStoryboardSegue {
    override func perform() {
        let src = self.source as UIViewController
        let dest = self.destination as UIViewController
        
        src.view.superview?.insertSubview(dest.view, belowSubview: src.view)
        src.view.transform = CGAffineTransform(translationX: 0, y: 0)
        
        dest.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width / 2, y: 0)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            src.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
            dest.view.transform = CGAffineTransform(translationX: 0, y: 0)
            
        }, completion: { (isFinished) in
            src.dismiss(animated: false, completion: nil)
        })
    }
}
