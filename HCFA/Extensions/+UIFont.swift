//
//  +UIFont.swift
//  HCFA
//
//  Created by Collin Price on 1/5/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit

extension UIFont {
    // finds largest possible font that fits height of frame
    class func findAdaptiveFont(withName fontName: String, forUILabel labelSize: CGSize, withMinimumSize minSize: Int) -> UIFont {
        let testString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var tempMin: Int = minSize
        var tempMax: Int = 256
        var mid: Int = 0
        var difference: Int = 0
        while tempMin <= tempMax {
            mid = tempMin + (tempMax - tempMin) / 2
            
            difference = Int((labelSize.height - testString.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(mid))]).height))
            if mid == tempMin || mid == tempMax {
                if difference < 0 {
                    return (UIFont(name: fontName, size: CGFloat((mid - 1))))!
                }
                return UIFont(name: fontName, size: CGFloat(mid))!
            }
            
            if difference < 0 {
                tempMax = mid - 1
            } else if difference > 0 {
                tempMin = mid + 1
            } else {
                return UIFont(name: fontName, size: CGFloat(mid))!
            }
        }
        return UIFont(name: fontName, size: CGFloat(mid))!
    }
}
