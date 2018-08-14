//
//  SideMenuCell.swift
//  HCFA
//
//  Created by Collin Price on 1/5/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit

class SideMenuCell: UITableViewCell {
    
    var cellWidth: CGFloat!
    var cellHeight: CGFloat!
    
    func load(tab: Int) {
        frame = CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight)
        backgroundColor = .clear
        layoutMargins = UIEdgeInsets.zero
        
        let colorView = UIView(frame: frame)
        colorView.backgroundColor = sideMenuHighlightColor
        selectedBackgroundView = colorView
        
        switch tab {
            case Tabs.Events:
                createDisplayWith(text: "Events", image: UIImage(named: "event")!)
            case Tabs.BibleCourses:
                createDisplayWith(text: "Bible Courses", image: UIImage(named: "book")!)
            case Tabs.MinistryTeams:
                createDisplayWith(text: "Ministry Teams", image: UIImage(named: "team")!)
            default:
                createDisplayWith(text: "Settings", image: UIImage(named: "gear")!)
        }
    }
    
    private func createDisplayWith(text: String, image: UIImage) {
        
        let IMAGE_LENGTH = frame.height*0.5
        let SIDE_MARGIN = frame.width/20
        
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: SIDE_MARGIN, y: (cellHeight-IMAGE_LENGTH)/2,
                                 width: IMAGE_LENGTH, height: IMAGE_LENGTH)
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel(frame: CGRect(x: SIDE_MARGIN*2 + IMAGE_LENGTH, y: (cellHeight-IMAGE_LENGTH)/2,
                                          width: frame.width - SIDE_MARGIN*3 - IMAGE_LENGTH, height: IMAGE_LENGTH))
        label.text = text
        label.font = UIFont(name: "Montserrat-Light", size: cellWidth*0.0625) ??
            UIFont.systemFont(ofSize: cellWidth*0.0625)
        label.adjustsFontSizeToFitWidth = true
        
        addSubview(imageView)
        addSubview(label)
    }
}
