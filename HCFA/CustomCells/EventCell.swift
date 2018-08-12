//
//  EventCells.swift
//  HCFA
//
//  Created by Collin Price on 1/1/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {
    
    var width: CGFloat!
    var height: CGFloat!
    let view = UIImageView()
    
    func load(data: [String:Any]) {
        
        let SIDE_MARGIN = width/20
        let TOP_MARGIN = height/20
        let FULL_WIDTH = width-SIDE_MARGIN*3
        let FULL_HEIGHT = height - TOP_MARGIN*2
        
        backgroundColor = .clear
        
        if let _ = data["image"] as? String {
            frame = CGRect(x: 0, y: 0, width: width, height: height*3.1)
            view.frame = CGRect(x: SIDE_MARGIN/2, y: 0, width: width-SIDE_MARGIN, height: height*3)
        } else {
            frame = CGRect(x: 0, y: 0, width: width, height: height*1.1)
            view.frame = CGRect(x: SIDE_MARGIN/2, y: 0, width: width-SIDE_MARGIN, height: height)
        }
        
        view.backgroundColor = .white
        view.layer.cornerRadius = SIDE_MARGIN

        let title = UILabel(frame: CGRect(x: SIDE_MARGIN, y: TOP_MARGIN, width: FULL_WIDTH,
                                          height: FULL_HEIGHT*0.4))
        title.text = (data["title"] as! String)
        title.font = titleFont
        title.baselineAdjustment = .alignBaselines
        
        let location = UILabel(frame: CGRect(x: SIDE_MARGIN, y: title.frame.height + FULL_HEIGHT*0.1,
                                             width: FULL_WIDTH, height: FULL_HEIGHT*0.25))
        location.text = (data["location"] as! String)
        location.font = cellFont
        location.baselineAdjustment = .alignCenters
        location.textColor = secondaryCellColor
        
        let date = UILabel(frame: CGRect(x: SIDE_MARGIN, y: location.frame.origin.y + location.frame.height,
                                         width: FULL_WIDTH, height: location.frame.height))
        date.font = cellFont
        date.baselineAdjustment = .alignCenters
        date.textColor = tertiaryCellColor
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let startDate = dateFormatter.date(from: (data["start"] as! String))!
        let endDate = dateFormatter.date(from: (data["end"] as! String))!
        
        dateFormatter.dateFormat = "h:mma"
        let startTime = dateFormatter.string(from: startDate).lowercased()
        let endTime = dateFormatter.string(from: endDate).lowercased()
        
        dateFormatter.dateFormat = "M/d/YY"
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        
        if startDateString == endDateString {
            dateFormatter.dateFormat = "MMM d, YYYY"
            date.text = "\(dateFormatter.string(from: startDate)) | \(startTime)-\(endTime)"

        } else {
            dateFormatter.dateFormat = "MMM d"
            let startString = dateFormatter.string(from: startDate)
            let endString = dateFormatter.string(from: endDate)
            date.text = "\(startString) (\(startTime)) - \(endString) (\(endTime))"
        }
        
        view.addSubview(date)
        
        if let imageString = data["image"] as? String {

            let imageView = EventImageView(frame: CGRect(x: SIDE_MARGIN, y: height + TOP_MARGIN/2,
                                                         width: FULL_WIDTH, height: height*2-TOP_MARGIN*2))
            imageView.isCell = true
            imageView.initializeReload()
            
            let eid = data["eid"] as! Int
            imageView.eid = eid
            imageView.imageString = imageString
            imageView.startSpinner()
            view.addSubview(imageView)
            
            DispatchQueue.main.async {
                if let eventImages = defaults.dictionary(forKey: "eventImages") as? [String:Data] {
                    if let data = eventImages[String(eid)] {
                        if let image = UIImage(data: data) {
                            imageView.image = image
                            imageView.stopSpinner()
                        } else {
                            imageView.download()
                        }
                    } else {
                        imageView.download()
                    }
                } else {
                    imageView.download()
                }
            }
            
        }
        
        view.addSubview(title)
        view.addSubview(location)
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
