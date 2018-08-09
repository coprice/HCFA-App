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
        
        let SIDE_MARGIN = width/40
        let TOP_MARGIN = height/40
        let FULL_WIDTH = width-SIDE_MARGIN*4
        
        backgroundColor = .clear
        
        if let _ = data["image"] as? String {
            frame = CGRect(x: 0, y: 0, width: width, height: height*3.1)
            view.frame = CGRect(x: SIDE_MARGIN, y: 0, width: width-SIDE_MARGIN*2, height: height*3)
        } else {
            frame = CGRect(x: 0, y: 0, width: width, height: height*1.1)
            view.frame = CGRect(x: SIDE_MARGIN, y: 0, width: width-SIDE_MARGIN*2, height: height)
        }
        
        view.backgroundColor = .white
        view.layer.cornerRadius = SIDE_MARGIN

        let title = UILabel(frame: CGRect(x: SIDE_MARGIN, y: TOP_MARGIN, width: FULL_WIDTH*0.63, height: height*2/5))
        title.text = (data["title"] as! String)
        title.font = UIFont(name: "Baskerville", size: FULL_WIDTH*0.1)
        title.baselineAdjustment = .alignCenters
        title.adjustsFontSizeToFitWidth = true
        
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
            
            let time = UILabel(frame: CGRect(x: view.frame.width - FULL_WIDTH*0.34 - SIDE_MARGIN, y: TOP_MARGIN,
                                             width: FULL_WIDTH*0.34, height: height/5))
            time.text = "\(startTime)-\(endTime)"
            time.font = UIFont.findAdaptiveFont(withName: "Baskerville", forUILabel: time.frame.size, withMinimumSize: 8)
            time.textColor = .gray
            time.adjustsFontSizeToFitWidth = true
            
            let date = UILabel(frame:CGRect(x: time.frame.origin.x, y: TOP_MARGIN + height/6,
                                            width: time.frame.width, height: time.frame.height))
            date.text = dateFormatter.string(from: startDate)
            date.font = UIFont.findAdaptiveFont(withName: "Baskerville", forUILabel: date.frame.size, withMinimumSize: 8)
            date.adjustsFontSizeToFitWidth = true
            
            view.addSubview(time)
            view.addSubview(date)

        } else {
            
            dateFormatter.dateFormat = "M/d/YY"
            let startString = dateFormatter.string(from: startDate)
            let endString = dateFormatter.string(from: endDate)

            let start = UILabel(frame: CGRect(x: view.frame.width - FULL_WIDTH*0.34 - SIDE_MARGIN, y: TOP_MARGIN,
                                              width: FULL_WIDTH*0.34, height: height/5))
            start.text = "\(startTime), \(startString)"
            start.font = UIFont.findAdaptiveFont(withName: "Baskerville", forUILabel: start.frame.size, withMinimumSize: 8)
            start.textColor = .gray
            start.adjustsFontSizeToFitWidth = true
            
            let dash = UILabel(frame: CGRect(x: start.frame.origin.x, y: TOP_MARGIN + height*0.11,
                                             width: start.frame.width, height: start.frame.height))
            dash.text = "—"
            dash.font = UIFont(name: "Baskerville", size: dash.frame.width/10)
            dash.textAlignment = .center
            dash.textColor = .black
            
            let end = UILabel(frame:CGRect(x: start.frame.origin.x, y: TOP_MARGIN + height/6,
                                           width: start.frame.width, height: start.frame.height))
            end.text = "\(endTime), \(endString)"
            end.font = UIFont.findAdaptiveFont(withName: "Baskerville", forUILabel: start.frame.size, withMinimumSize: 8)
            end.textColor = .gray
            end.adjustsFontSizeToFitWidth = true
            
            view.addSubview(start)
            view.addSubview(dash)
            view.addSubview(end)
        }
        
        let location = UILabel(frame: CGRect(x: SIDE_MARGIN, y: height*2/5, width: FULL_WIDTH, height: height/5))
        location.text = (data["location"] as! String)
        location.font = UIFont(name: "Baskerville", size: view.frame.width/20)
        location.textColor = .gray
        location.textAlignment = .center
        
        let description = UILabel(frame: CGRect(x: SIDE_MARGIN, y: height*3/5,
                                                width: FULL_WIDTH, height: height*2/5))
        description.text = (data["description"] as! String)
        description.font = UIFont(name: "Baskerville", size: view.frame.width/20)
        description.textColor = redColor
        description.numberOfLines = 2
        description.textAlignment = .center
        
        
        if let imageString = data["image"] as? String {

            let imageView = EventImageView(frame: CGRect(x: SIDE_MARGIN*2, y: height+TOP_MARGIN,
                                                         width: FULL_WIDTH-SIDE_MARGIN*2,
                                                         height: height*2-TOP_MARGIN*2))
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
