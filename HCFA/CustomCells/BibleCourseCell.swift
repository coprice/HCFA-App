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
        let SIDE_MARGIN = width/20
        let TOP_MARGIN = height/20
        let FULL_WIDTH = width-SIDE_MARGIN*2
        let FULL_HEIGHT = height - TOP_MARGIN*2
        
        backgroundColor = .clear
        frame = CGRect(x: 0, y: 0, width: width, height: height*1.1)
        
        view.frame = CGRect(x: SIDE_MARGIN/2, y: 0, width: width-SIDE_MARGIN, height: height)
        view.backgroundColor = .white
        view.layer.cornerRadius = SIDE_MARGIN
        
        let title = UILabel(frame: CGRect(x: SIDE_MARGIN, y: TOP_MARGIN, width: FULL_WIDTH, height: FULL_HEIGHT*0.4))
        title.text = "\(data["leader_first"] as! String) \(data["leader_last"] as! String)"
        title.font = UIFont(name: "Montserrat-Medium", size: FULL_WIDTH*0.08)
        title.baselineAdjustment = .alignCenters
        view.addSubview(title)
        
        let location = UILabel(frame: CGRect(x: SIDE_MARGIN, y: title.frame.height + FULL_HEIGHT*0.1,
                                             width: FULL_WIDTH, height: FULL_HEIGHT*0.25))
        location.text = (data["location"] as! String)
        location.font = UIFont(name: "Montserrat-Light", size: view.frame.width/22)
        location.baselineAdjustment = .alignCenters
        location.textColor = UIColor(red: 43/255, green: 50/255, blue: 53/255, alpha: 1.0)
        view.addSubview(location)
        
        let meeting =  UILabel(frame: CGRect(x: SIDE_MARGIN,
                                             y: location.frame.origin.y + location.frame.height,
                                             width: FULL_WIDTH, height: location.frame.height))
        meeting.font = UIFont(name: "Montserrat-Light", size: view.frame.width/22)
        meeting.baselineAdjustment = .alignCenters
        meeting.textColor = UIColor(red: 128/255, green: 130/255, blue: 133/255, alpha: 1.0)

        if let dayString = data["day"] as? String {
            meeting.text = "\(dayString)s | \(data["start"] as! String)-\(data["end"] as! String)"
            
        } else {
            meeting.text = "Meetings TBD"
        }
        
        view.addSubview(meeting)
        view.highlightedImage = roundedImage(color: .lightGray, width: view.frame.width,
                                             height: view.frame.height, cornerRadius: SIDE_MARGIN)
        addSubview(view)
        
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
