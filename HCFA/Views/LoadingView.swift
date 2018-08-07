//
//  LoadingView.swift
//  HCFA
//
//  Created by Collin Price on 7/28/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        layer.cornerRadius = frame.width*0.25
        layer.borderColor = redColor.cgColor
        layer.borderWidth = 1
        
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0,
                                                            width: frame.width, height: frame.height))
        spinner.activityIndicatorViewStyle = .whiteLarge
        spinner.tintColor = redColor
        spinner.color = redColor
        spinner.startAnimating()
        addSubview(spinner)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
}
