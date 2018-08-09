//
//  UpButton.swift
//  HCFA
//
//  Created by Collin Price on 8/8/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit

class UpButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        layer.cornerRadius = frame.width/2
        let arrow = UIImage(named: "arrow")
        setImage(arrow, for: .normal)
        setImage(arrow, for: .highlighted)
        contentMode = .scaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
}
