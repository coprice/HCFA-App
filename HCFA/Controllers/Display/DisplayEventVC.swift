//
//  DisplayEventVC.swift
//  HCFA
//
//  Created by Collin Price on 1/10/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit
import EventKit

class DisplayEventVC: DisplayTemplateVC {
    
    var navBar: UINavigationBar!
    var edit: UIButton!
    var data: [String:Any]!
    var imageView: UIImageView!
    var hostVC: HostVC!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = (data["title"] as! String)
        if hostVC.slider.superview != nil {
            hostVC.slider.removeFromSuperview()
        }
        
        if defaults.bool(forKey: "admin") || defaults.bool(forKey: "leader") {
            navBar.addSubview(edit)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        edit.removeFromSuperview()
    }
    
    func load(_ givenData: [String:Any], _ givenNavBar: UINavigationBar, _ givenHostVC: HostVC) {
        data = givenData
        navBar = givenNavBar
        hostVC = givenHostVC
        
        edit = UIButton(frame: CGRect(x: navBar.frame.width*0.75, y: 0, width: navBar.frame.width/4,
                                      height: navBar.frame.height))
        edit.setTitle("Edit", for: .normal)
        edit.titleLabel?.textColor = .white
        edit.titleLabel?.font = UIFont(name: "Baskerville", size: UIScreen.main.bounds.width/21)
        edit.setTitleColor(barHighlightColor, for: .highlighted)
        edit.addTarget(self, action: #selector(self.editTapped), for: .touchUpInside)
        
        var offset = navBar.frame.height + UIApplication.shared.statusBarFrame.height
        let SIDE_MARGIN = view.frame.width/20
        let TOP_MARGIN = view.frame.height/60
        let FULL_WIDTH = view.frame.width-SIDE_MARGIN*2
        
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: offset, width: view.frame.width,
                                                    height: view.frame.height - offset))
        scrollView.backgroundColor = .clear
        
        offset = 0 // keep track of total height used
        
        let titleFont = UIFont(name: "LeagueGothic-Regular", size: view.frame.width/8)!
        let titleHeight = calcLabelHeight(text: (data["title"] as! String),
                                          frame: CGRect(x: SIDE_MARGIN, y: offset + TOP_MARGIN,
                                                        width: FULL_WIDTH, height: CGFloat.greatestFiniteMagnitude),
                                          font: titleFont)
        
        let titleLabel = UILabel(frame: CGRect(x: SIDE_MARGIN, y: TOP_MARGIN,
                                               width: FULL_WIDTH, height: titleHeight))
        titleLabel.text = (data["title"] as! String)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.font = titleFont
        titleLabel.backgroundColor = .clear
        titleLabel.adjustsFontSizeToFitWidth = true
        scrollView.addSubview(titleLabel)
        
        offset += titleLabel.frame.height + TOP_MARGIN*3/2
        addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
        offset += TOP_MARGIN/2
        
        let infoFont = UIFont(name: "Baskerville", size: view.frame.width/20)!
        
        let location = UITextView(frame: CGRect(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, height: 0))
        createTextView(location, font: infoFont, text: (data["location"] as! String), color: .darkGray,
                       textAlignment: .center)
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
        
        dateFormatter.dateFormat = "MMMM d, YYYY"
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        
        if startDateString == endDateString {
            let height = view.frame.height/12
            let dateLabel = createLabel(frame: CGRect(x: view.frame.width/20, y: offset + height*0.1,
                                                      width: view.frame.width*0.9, height: height*0.4),
                                        text: startDateString, font: infoFont, color: .black,
                                        alignment: .center, fitToWidth: true)
            scrollView.addSubview(dateLabel)
            
            let timeLabel = createLabel(frame: CGRect(x: view.frame.width/20, y: offset + height/2,
                                                      width: view.frame.width*0.9, height: height*0.4),
                                        text: ("\(startTime)-\(endTime)"), font: infoFont, color: .darkGray,
                                        alignment: .center, fitToWidth: true)
            scrollView.addSubview(timeLabel)
            offset += height

        } else {
            
            let height = view.frame.height/10
            let starts = createUnderlineLabel(frame: CGRect(x: view.frame.width*0.05, y: offset + height/8,
                                                            width: view.frame.width*0.15, height: height/4),
                                              text: "Starts:", font: infoFont, color: redColor, alignment: .right)
            scrollView.addSubview(starts)
            
            let ends = createUnderlineLabel(frame: CGRect(x: view.frame.width*0.05, y: offset + height*5/8,
                                                          width: view.frame.width*0.15, height: height/4),
                                            text: "Ends:", font: infoFont, color: redColor, alignment: .right)
            scrollView.addSubview(ends)
            
            let startStrings = startDateString.split(separator: Character(","))
            let endStrings = endDateString.split(separator: Character(","))
            
            let startingDateString =
                "\(startStrings[0])\(daySuffix(from: startDate)),\(startStrings[1]) at \(endTime)"
            
            let endingDateString = "\(endStrings[0])\(daySuffix(from: endDate)),\(endStrings[1]) at \(endTime)"
            
            let startDateLabel = createLabel(frame: CGRect(x: view.frame.width*0.25, y: offset,
                                                           width: view.frame.width*0.7, height: height/2),
                                             text: startingDateString, font: infoFont, color: .black,
                                             alignment: .left, fitToWidth: true)
            scrollView.addSubview(startDateLabel)
            
            let endDateLabel = createLabel(frame: CGRect(x: view.frame.width*0.25, y: offset + height/2,
                                                         width: view.frame.width*0.7, height: height/2),
                                           text: endingDateString, font: infoFont, color: .black,
                                           alignment: .left, fitToWidth: true)
            scrollView.addSubview(endDateLabel)
            offset += height
        }

        offset += TOP_MARGIN/2
        addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
        offset += TOP_MARGIN/2
        
        if let imageString = data["image"] as? String {
            
            imageView = UIImageView(frame: CGRect(x: SIDE_MARGIN, y: offset + TOP_MARGIN,
                                                  width: FULL_WIDTH, height: view.frame.height/3))
            imageView.image = UIImage(named: "banner")
            imageView.contentMode = .scaleAspectFit
            if let url = URL(string: imageString) {
                downloadImage(url: url, view: imageView)
            }
            scrollView.addSubview(imageView)
            offset += imageView.frame.height + TOP_MARGIN*2
            offset += TOP_MARGIN/2
            addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
            offset += TOP_MARGIN/2
        }
        
        let description = UITextView(frame: CGRect(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, height: 0))
        createTextView(description, font: infoFont, text: (data["description"] as! String), color: .black,
                       textAlignment: .left)
        offset += description.frame.height
        scrollView.addSubview(description)
        
        offset += TOP_MARGIN/2
        addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
        offset += TOP_MARGIN
        
        let calendarWidth = FULL_WIDTH*0.6
        let calendarHeight = calendarWidth/2
        
        let calendarButton = UIButton(frame: CGRect(x: (view.frame.width - calendarWidth)/2, y: offset,
                                                    width: calendarWidth, height: calendarHeight))
        calendarButton.setBackgroundImage(UIImage(named: "calendar"), for: .normal)
        calendarButton.imageView?.contentMode = .scaleAspectFit
        calendarButton.addTarget(self, action: #selector(self.addToCalendar), for: .touchUpInside)
        scrollView.addSubview(calendarButton)
        
        offset += calendarHeight + TOP_MARGIN
        scrollView.contentSize = CGSize(width: view.frame.width, height: offset)
        view.addSubview(scrollView)
    }
    
    @objc func editTapped(sender: UIButton) {
        let editEvent = CreateEventVC()
        if let view = imageView {
            editEvent.editWith(data, view.image)
        } else {
            editEvent.editWith(data, nil)
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navBar.topItem?.backBarButtonItem = backItem
        
        navigationController!.pushViewController(editEvent, animated: true)
    }
    
    @objc func addToCalendar(sender: UIButton) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navBar.topItem?.backBarButtonItem = backItem
        
        let calendarVC = CalendarVC()
        calendarVC.data = data
        calendarVC.type = .Event
        navigationController!.pushViewController(calendarVC, animated: true)
    }
}
