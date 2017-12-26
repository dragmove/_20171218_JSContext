//
//  Utils.swift
//  _20171218_JSContext
//
//  Created by Kim Hyun-Seok on 2017. 12. 26..
//  Copyright © 2017년 Kim Hyun-Seok. All rights reserved.
//

import Foundation
import UIKit

class Utils {
    static func getSizeAspectFit(_ srcWidth: Float, srcHeight: Float, maxWidth: Float, maxHeight: Float) -> CGSize {
        let ratio: Float = min(maxWidth / srcWidth, maxHeight / srcHeight)
        let modifiedSizeW: Float = ceilf(srcWidth * ratio)
        let modifiedSizeH: Float = ceilf(srcHeight * ratio)
        print("ratio, modifiedSizeW, modifiedSizeH : \(ratio), \(modifiedSizeW), \(modifiedSizeH)")
        
        let size: CGSize = CGSize(width: CGFloat(modifiedSizeW), height: CGFloat(modifiedSizeH))
        return size
    }
}
