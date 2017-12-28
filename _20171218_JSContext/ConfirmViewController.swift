//
//  ConfirmViewController.swift
//  _20171218_JSContext
//
//  Created by Kim Hyun-Seok on 2017. 12. 28..
//  Copyright © 2017년 Kim Hyun-Seok. All rights reserved.
//

import UIKit
import WebKit

class ConfirmViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    
    // variables
    var sender:AnyObject?
    var capturedImages:[UIImage] = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        self.setScrollView()
    }
    
    func setScrollView() {
        let size = scrollView.frame.size
        print("size : \(size)")
        
        print("self.sender : \(String(describing: self.sender))")
        print("capturedImages : \(self.capturedImages)")
        print("count : \(self.capturedImages.count)")
        
        var imageView: UIImageView?
        for (index, image) in self.capturedImages.enumerated() {
            imageView = UIImageView(image: image)
            imageView?.contentMode = UIViewContentMode.scaleAspectFit
            imageView?.frame = CGRect(x: size.width * CGFloat(index), y: 0, width: size.width, height: size.height)
            
            scrollView.addSubview(imageView!)
        }
        
        scrollView.contentSize = CGSize(width: size.width * CGFloat(self.capturedImages.count), height: size.height)
    }
    
    private func emptyScrollView() {
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
    }
    
    // before unwind segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "unwindSegueFromRight" {
            emptyScrollView()
            
            capturedImages.removeAll()
            
            let destination = segue.destination as! ViewController
            destination.capturedImages.removeAll()
        }
    }
    /*
    // before segue, set ConfirmViewController datas
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "segueFromRight" {
            let destination = segue.destination as! ConfirmViewController
            destination.capturedImages = self.capturedImages
            destination.sender = self
        }
    }
     */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
