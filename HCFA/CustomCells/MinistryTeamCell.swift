//
//  MinistryTeamCell.swift
//  HCFA
//
//  Created by Collin Price on 1/22/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit

class MinistryTeamCell: UITableViewCell {
    var width: CGFloat!
    var height: CGFloat!
    let view = UIImageView()
    
    func load(data: [String:Any]) {
        let SIDE_MARGIN = width/40
        let TOP_MARGIN = height/40
        let FULL_WIDTH = width-SIDE_MARGIN*4
        
        backgroundColor = .clear
        frame = CGRect(x: 0, y: 0, width: width, height: height*1.1)
        
        view.frame = CGRect(x: SIDE_MARGIN, y: 0, width: width-SIDE_MARGIN*2, height: height)
        view.backgroundColor = .white
        view.layer.cornerRadius = SIDE_MARGIN
        
        let title = UILabel(frame: CGRect(x: SIDE_MARGIN, y: TOP_MARGIN, width: FULL_WIDTH, height: height*3/10))
        title.text = (data["name"] as! String)
        title.font = UIFont(name: "Baskerville", size: FULL_WIDTH*0.09)
        title.baselineAdjustment = .alignCenters
        title.textAlignment = .center
        title.adjustsFontSizeToFitWidth = true
        view.addSubview(title)
        
        let leaders = UILabel(frame: CGRect(x: SIDE_MARGIN, y: height*3/10, width: FULL_WIDTH, height: height/5))
        var text = ""
        for leader in (data["leaders"] as! [String]) {
            text += leader + ", "
        }
        if text.isEmpty { text = "Leaders TBD" } else {
            let endIndex = text.index(text.endIndex, offsetBy: -2)
            text = String(text[text.startIndex..<endIndex])
        }
        leaders.text = text
        leaders.font = UIFont(name: "Baskerville", size: view.frame.width/20)
        leaders.textColor = .darkGray
        leaders.adjustsFontSizeToFitWidth = true
        leaders.textAlignment = .center
        leaders.baselineAdjustment = .alignCenters
        view.addSubview(leaders)
        
        let description = UILabel(frame: CGRect(x: SIDE_MARGIN, y: height/2, width: FULL_WIDTH, height: height/2))
        description.text = (data["description"] as! String)
        description.font = UIFont(name: "Baskerville", size: view.frame.width/20)
        description.textColor = redColor
        description.numberOfLines = 3
        description.textAlignment = .center
        description.baselineAdjustment = .alignCenters
        view.addSubview(description)
        addSubview(view)
        
        view.highlightedImage = roundedImage(color: .lightGray, width: view.frame.width,
                                             height: view.frame.height, cornerRadius: SIDE_MARGIN)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        selectedBackgroundView = backgroundView
    }
    
    func highlightView() {
        view.isHighlighted = true
    }
    
    func unhighlightView() {
        view.isHighlighted = false
    }
}
