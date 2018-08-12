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
        let SIDE_MARGIN = width/20
        let TOP_MARGIN = height/20
        let FULL_WIDTH = width-SIDE_MARGIN*2
        let FULL_HEIGHT = height - TOP_MARGIN*2
        
        backgroundColor = .clear
        frame = CGRect(x: 0, y: 0, width: width, height: height*1.1)
        
        view.frame = CGRect(x: SIDE_MARGIN/2, y: 0, width: width-SIDE_MARGIN, height: height)
        view.backgroundColor = .white
        view.layer.cornerRadius = SIDE_MARGIN
        
        let title = UILabel(frame: CGRect(x: SIDE_MARGIN, y: TOP_MARGIN,
                                          width: FULL_WIDTH, height: FULL_HEIGHT*0.32))
        title.text = (data["name"] as! String)
        title.font = UIFont(name: "Montserrat-Medium", size: FULL_WIDTH*0.08)
        title.baselineAdjustment = .alignCenters
        title.textAlignment = .center
        view.addSubview(title)
        
        let leaders = UILabel(frame: CGRect(x: SIDE_MARGIN, y: title.frame.height + FULL_HEIGHT*0.1,
                                            width: FULL_WIDTH, height: FULL_HEIGHT*0.35))
        let leadersList = data["leaders"] as! [String]
        var text = "MTL \(leadersList[0]),\n"
        
        if leadersList.count > 1 {
            text += leadersList[1...].joined(separator: ", ")
        }

        leaders.lineBreakMode = .byWordWrapping
        leaders.numberOfLines = 2
        leaders.attributedText = createLeaderString(from: text, fontSize: view.frame.width/22,
                                                    color: UIColor(red: 43/255, green: 50/255, blue: 53/255,
                                                                   alpha: 1.0))
        leaders.textAlignment = .center
        leaders.baselineAdjustment = .alignCenters
        view.addSubview(leaders)
        
        let meeting =  UILabel(frame: CGRect(x: SIDE_MARGIN, y: leaders.frame.origin.y + leaders.frame.height,
                                             width: FULL_WIDTH, height: FULL_HEIGHT*0.35))
        meeting.font = UIFont(name: "Montserrat-Light", size: view.frame.width/22)
        meeting.baselineAdjustment = .alignCenters
        meeting.textColor = UIColor(red: 128/255, green: 130/255, blue: 133/255, alpha: 1.0)
        meeting.textAlignment = .center
        
        if let day = data["day"] as? String {
             meeting.text = "\(day)s \(data["start"] as! String)-\(data["end"] as! String)"
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

    func createLeaderString(from string: String, fontSize: CGFloat, color: UIColor) -> NSAttributedString {
        let boldAttribute: [NSAttributedStringKey : Any] =
            [.font: UIFont(name: "Montserrat-Bold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize),
             .foregroundColor: color]
        let nonBoldAttribute: [NSAttributedStringKey : Any] =
            [.font: UIFont(name: "Montserrat-Light" , size: fontSize) ?? UIFont.systemFont(ofSize: fontSize),
             .foregroundColor: color]
        let attrStr = NSMutableAttributedString(string: string, attributes: nonBoldAttribute)
        attrStr.setAttributes(boldAttribute, range: NSMakeRange(0, 3))
        return attrStr
    }
}
