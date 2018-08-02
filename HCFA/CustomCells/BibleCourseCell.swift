//
//  BibleCourseCell.swift
//  HCFA
//
//  Created by Collin Price on 1/13/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit

class BibleCourseCell: UITableViewCell {
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
        
        let title = UILabel(frame: CGRect(x: SIDE_MARGIN, y: TOP_MARGIN, width: FULL_WIDTH*0.64, height: height*2/5))
        title.text = (data["leader_first"] as! String) + " " + (data["leader_last"] as! String)
        title.font = UIFont(name: "Baskerville", size: FULL_WIDTH*0.08)
        title.baselineAdjustment = .alignCenters
        title.adjustsFontSizeToFitWidth = true
        view.addSubview(title)
        
        if let dayString = data["day"] as? String {
            
            let day = UILabel(frame: CGRect(x: view.frame.width - FULL_WIDTH*0.34 - SIDE_MARGIN, y: TOP_MARGIN,
                                            width: FULL_WIDTH*0.34, height: height/5))
            day.text = "\(dayString)s"
            day.font = UIFont.findAdaptiveFont(withName: "Baskerville", forUILabel: day.frame.size,
                                               withMinimumSize: 10)
            day.textColor = .black
            day.textAlignment = .center
            day.adjustsFontSizeToFitWidth = true
            view.addSubview(day)
            
            let time = UILabel(frame: CGRect(x: day.frame.origin.x, y: TOP_MARGIN + height/6,
                                             width: FULL_WIDTH*0.34, height: height/5))
            time.text = "\(data["start"] as! String)-\(data["end"] as! String)"
            time.font = day.font
            time.textColor = .gray
            time.textAlignment = .center
            time.adjustsFontSizeToFitWidth = true
            view.addSubview(time)
        } else {
            
            let tbd = UILabel(frame: CGRect(x: view.frame.width - FULL_WIDTH*0.34 - SIDE_MARGIN, y: TOP_MARGIN + height/12,
                                            width: FULL_WIDTH*0.34, height: height*1/5))
            tbd.text = "TBD"
            tbd.font = UIFont.findAdaptiveFont(withName: "Baskerville", forUILabel: tbd.frame.size,
                                               withMinimumSize: 10)
            tbd.textColor = .black
            tbd.textAlignment = .center
            tbd.adjustsFontSizeToFitWidth = true
            view.addSubview(tbd)
        }
        
        
        let location = UILabel(frame: CGRect(x: SIDE_MARGIN, y: height*2/5, width: FULL_WIDTH, height: height/5))
        location.text = (data["location"] as! String)
        location.font = UIFont(name: "Baskerville", size: view.frame.width/20)
        location.textColor = .gray
        location.textAlignment = .center
        view.addSubview(location)
        
        let material = UILabel(frame: CGRect(x: SIDE_MARGIN, y: height*3/5, width: FULL_WIDTH, height: height*2/5))
        material.text = (data["material"] as! String)
        material.font = UIFont(name: "Baskerville", size: view.frame.width/20)
        material.textColor = redColor
        material.numberOfLines = 2
        material.textAlignment = .center
        view.addSubview(material)
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
