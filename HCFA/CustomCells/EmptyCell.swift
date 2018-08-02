//
//  EmptyCell.swift
//  HCFA
//
//  Created by Collin Price on 1/4/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit

class EmptyCell: UITableViewCell {
    var notice: UILabel!
    
    func load(width: CGFloat, height: CGFloat, text: String) {
        backgroundColor = .clear
        
        let SIDE_MARGIN = width/40
        
        frame = CGRect(x: SIDE_MARGIN, y: height*0.85/4, width: width-SIDE_MARGIN*2, height: height*0.85)
        notice = UILabel(frame: self.frame)
        notice.text = text
        notice.textColor = .gray
        notice.textAlignment = .center
        notice.font = UIFont(name: "Baskerville", size: width/18)
        notice.adjustsFontSizeToFitWidth = true
        self.addSubview(notice)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        selectedBackgroundView = backgroundView
    }
}
