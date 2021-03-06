//
//  DisplayEventVC.swift
//  HCFA
//
//  Created by Collin Price on 1/10/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit

class DisplayEventVC: DisplayTemplateVC {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstAppearance {
            hostVC = (navigationController!.viewControllers.first as! HostVC)
            firstAppearance = false
            
            edit = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editTapped))
            
            var offset = navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height
            let SIDE_MARGIN = view.frame.width/20
            let TOP_MARGIN = view.frame.height/60
            let FULL_WIDTH = view.frame.width-SIDE_MARGIN*2
            
            let scrollView = UIScrollView(frame: CGRect(x: 0, y: offset, width: view.frame.width,
                                                        height: view.frame.height - offset))
            scrollView.backgroundColor = .clear
            
            offset = TOP_MARGIN
            
            let location = UITextView(frame: CGRect(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, height: 0))
            createTextView(location, font: displayFont, text: (data["location"] as! String),
                           color: secondaryCellColor, textAlignment: .center)
            offset += location.frame.height
            scrollView.addSubview(location)
            
            offset += TOP_MARGIN/2
            addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
            offset += TOP_MARGIN/2
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let startDate = dateFormatter.date(from: (data["start"] as! String))!
            let endDate = dateFormatter.date(from: (data["end"] as! String))!
            
            dateFormatter.dateFormat = "h:mma"
            let startTime = dateFormatter.string(from: startDate).lowercased()
            let endTime = dateFormatter.string(from: endDate).lowercased()
            
            dateFormatter.dateFormat = "MMMM d"
            let startDateString = dateFormatter.string(from: startDate)
            let endDateString = dateFormatter.string(from: endDate)
            
            if startDateString == endDateString {
                let height = view.frame.height/12
                let dateLabel = createLabel(frame: CGRect(x: SIDE_MARGIN, y: offset + height*0.1,
                                                          width: view.frame.width*0.9, height: height*0.4),
                                            text: startDateString, font: displayFont,
                                            color: .black, alignment: .center, fitToWidth: true)
                scrollView.addSubview(dateLabel)
                
                let timeLabel = createLabel(frame: CGRect(x: SIDE_MARGIN, y: offset + height/2,
                                                          width: view.frame.width*0.9, height: height*0.4),
                                            text: ("\(startTime)-\(endTime)"),
                                            font: displayFont,
                                            color: .darkGray, alignment: .center, fitToWidth: true)
                scrollView.addSubview(timeLabel)
                offset += height
                
            } else {
                
                let underlineFont = UIFont(name: "Montserrat-Regular", size: view.frame.width*0.045) ??
                    UIFont.systemFont(ofSize: view.frame.width*0.045)
                let height = view.frame.height/10
                let starts = createUnderlineLabel(frame: CGRect(x: SIDE_MARGIN, y: offset + height/8,
                                                                width: SIDE_MARGIN*4, height: height/4),
                                                  text: "START", font: underlineFont,
                                                  color: redColor, alignment: .left)
                scrollView.addSubview(starts)
                
                let ends = createUnderlineLabel(frame: CGRect(x: SIDE_MARGIN, y: offset + height*5/8,
                                                              width: SIDE_MARGIN*4, height: height/4),
                                                text: "END", font: underlineFont,
                                                color: redColor, alignment: .left)
                scrollView.addSubview(ends)
                
                let startText = "\(startDateString)\(daySuffix(from: startDate)) at \(startTime)"
                let startDateLabel = createLabel(frame: CGRect(x: SIDE_MARGIN*5, y: offset,
                                                               width: view.frame.width*0.7, height: height/2),
                                                 text: startText, font: displayFont, color: .black,
                                                 alignment: .left, fitToWidth: true)
                scrollView.addSubview(startDateLabel)
                
                let endText = "\(endDateString)\(daySuffix(from: endDate)) at \(endTime)"
                let endDateLabel = createLabel(frame: CGRect(x: SIDE_MARGIN*5, y: offset + height/2,
                                                             width: view.frame.width*0.7, height: height/2),
                                               text: endText, font: displayFont, color: .black,
                                               alignment: .left, fitToWidth: true)
                scrollView.addSubview(endDateLabel)
                offset += height
            }
            
            offset += TOP_MARGIN/2
            addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
            offset += TOP_MARGIN/2
            
            if let imageString = data["image"] as? String {
                
                let imageView = EventImageView(frame: CGRect(x: SIDE_MARGIN, y: offset + TOP_MARGIN,
                                                             width: FULL_WIDTH,
                                                             height: view.frame.height*0.35))
                imageView.isCell = false
                imageView.initializeReload()
                
                let eid = data["eid"] as! Int
                imageView.eid = eid
                imageView.imageString = imageString
                imageView.startSpinner()
                scrollView.addSubview(imageView)
                
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
                
                offset += imageView.frame.height + TOP_MARGIN*2.5
                addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
                offset += TOP_MARGIN/2
            }
            
            let description = UITextView(frame: CGRect(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, height: 0))
            createTextView(description, font: blockTextFont, text: (data["description"] as! String),
                           color: .black, textAlignment: .left)
            offset += description.frame.height
            scrollView.addSubview(description)
            
            offset += TOP_MARGIN/2
            addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
            offset += TOP_MARGIN*1.5
            
            let calendarLength = FULL_WIDTH*0.25
            let calendarButton = UIButton(frame: CGRect(x: (view.frame.width - calendarLength*0.8)/2, y: offset,
                                                        width: calendarLength, height: calendarLength))
            calendarButton.setBackgroundImage(UIImage(named: "calendar"), for: .normal)
            calendarButton.imageView?.contentMode = .scaleAspectFit
            calendarButton.addTarget(self, action: #selector(addToCalendar), for: .touchUpInside)
            scrollView.addSubview(calendarButton)
            
            offset += calendarLength + TOP_MARGIN
            scrollView.contentSize = CGSize(width: view.frame.width,
                                            height: max(offset, scrollView.frame.height+1))
            view.addSubview(scrollView)
        }
        
        navigationItem.title = (data["title"] as! String)
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItems = nil
        
        if defaults.bool(forKey: "admin") || defaults.bool(forKey: "leader") {
            navigationItem.rightBarButtonItem = edit
        }
    }
    
    @objc func editTapped() {
        let editEvent = CreateEventVC()
        editEvent.editWith(data)
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        navigationController!.pushViewController(editEvent, animated: true)
    }
    
    @objc func addToCalendar() {
        
        if shouldDisplayCalendar() {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            
            let calendarVC = CalendarVC()
            calendarVC.data = data
            calendarVC.type = .Event
            navigationController!.pushViewController(calendarVC, animated: true)
        } else {
            createAlert(title: "Access not granted", message: "Go to Settings > HCFA > Turn on Calendars",
                        view: self)
        }
    }
}
