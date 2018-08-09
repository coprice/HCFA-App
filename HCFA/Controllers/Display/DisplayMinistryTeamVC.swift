//
//  DisplayMinistryTeamVC.swift
//  HCFA
//
//  Created by Collin Price on 1/22/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit

class DisplayMinistryTeamVC: DisplayTemplateVC {
    
    var joined = false
    var admin = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstAppearance {
            firstAppearance = false
            hostVC = navigationController!.viewControllers.first as! HostVC
            
            edit = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(self.editTapped))
            
            var offset = navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height
            let SIDE_MARGIN = view.frame.width/20
            let TOP_MARGIN = view.frame.height/60
            let FULL_WIDTH = view.frame.width-SIDE_MARGIN*2
            
            let scrollView = UIScrollView(frame: CGRect(x: 0, y: offset, width: view.frame.width,
                                                        height: view.frame.height - offset))
            scrollView.backgroundColor = .clear
            
            offset = TOP_MARGIN
            
            let categoryFont = UIFont(name: "Baskerville", size: view.frame.width/12)!
            let infoFont = UIFont(name: "Baskerville", size: view.frame.width/20)!
            let categoryHeight = calcLabelHeight(text: "Location",
                                                 frame: CGRect(x: SIDE_MARGIN, y: offset + TOP_MARGIN,
                                                               width: FULL_WIDTH, height: .greatestFiniteMagnitude),
                                                 font: categoryFont)
            
            let leaderList = data["leaders"] as! [String]
            
            if leaderList.count > 2 {
                let labelOne = UILabel(frame: CGRect(x: SIDE_MARGIN, y: offset + TOP_MARGIN/4,
                                                     width: FULL_WIDTH, height: categoryHeight))
                createListLabel(label: labelOne, text: "\(leaderList[0...1].joined(separator: ", ")),",
                                font: infoFont, color: .black, view: scrollView)
                scrollView.addSubview(labelOne)
                offset += labelOne.frame.height
                
                let labelTwo = UILabel(frame: CGRect(x: SIDE_MARGIN, y: offset - TOP_MARGIN/4,
                                                     width: FULL_WIDTH, height: categoryHeight))
                createListLabel(label: labelTwo, text: leaderList[2...].joined(separator: ", "), font: infoFont,
                                color: .black, view: scrollView)
                scrollView.addSubview(labelTwo)
                offset += labelTwo.frame.height
            } else {
                let label = UILabel(frame: CGRect(x: SIDE_MARGIN, y: offset,
                                                  width: FULL_WIDTH, height: categoryHeight))
                createListLabel(label: label, text: leaderList.joined(separator: ", "), font: infoFont,
                                color: .black, view: scrollView)
                scrollView.addSubview(label)
                offset += label.frame.height
            }
            
            offset += TOP_MARGIN/2
            addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
            offset += TOP_MARGIN/2
            
            let description = UITextView(frame: CGRect(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, height: 0))
            createTextView(description, font: infoFont, text: (data["description"] as! String),
                           color:  UIColor(red: 0, green: 0, blue: 0, alpha: 0.75), textAlignment: .left)
            offset += description.frame.height + TOP_MARGIN
            scrollView.addSubview(description)
            
            offset += TOP_MARGIN/2
            addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
            offset += TOP_MARGIN/2
            
            let meetingInfo = UITextView(frame: CGRect(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, height: 0))
            
            var isMeeting = false
            var text = "Meetings TBD"
            if let day = data["day"] as? String {
                isMeeting = true
                text = "Meetings are \(day)s \(data["start"] as! String)-\(data["end"] as! String)\n\(data["location"] as! String)"
            }
            createTextView(meetingInfo, font: infoFont, text: text, color: .black, textAlignment: .center)
            offset += meetingInfo.frame.height + TOP_MARGIN/2
            scrollView.addSubview(meetingInfo)
            
            addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
            
            if joined {
                let members = (data["members"] as! [String:Any])["info"] as! [[String?]]
                for (i, member) in members.enumerated() {
                    offset += TOP_MARGIN*0.75
                    
                    let imageView = UIImageView(image: UIImage(named: "generic"))
                    if let profile = member[1] {
                        if let url = URL(string: profile) {
                            downloadImage(url: url, view: imageView)
                        }
                    }
                    imageView.frame = CGRect(x: SIDE_MARGIN + FULL_WIDTH*0.25, y: offset, width: FULL_WIDTH/8, height: FULL_WIDTH/8)
                    imageView.layer.cornerRadius = imageView.frame.width/2
                    imageView.contentMode = .scaleAspectFill
                    imageView.layer.masksToBounds = true
                    imageView.layer.borderColor = UIColor.black.cgColor
                    imageView.layer.borderWidth = 1
                    scrollView.addSubview(imageView)
                    
                    let label = UILabel(frame: CGRect(x: SIDE_MARGIN*2 + FULL_WIDTH*0.375 , y: offset,
                                                      width: FULL_WIDTH*0.625 - SIDE_MARGIN*3, height: FULL_WIDTH/8))
                    createListLabel(label: label, text: member[0]!, font: infoFont, color: .black, view: scrollView)
                    label.textAlignment = .left
                    
                    if i + 1 != members.count {
                        offset += label.frame.height + TOP_MARGIN*0.75
                        addLightLine(x: SIDE_MARGIN*2, y: offset, width: FULL_WIDTH - SIDE_MARGIN*2, view: scrollView)
                    } else {
                        offset += label.frame.height + TOP_MARGIN/4
                    }
                }
                
                if members.isEmpty {
                    offset += TOP_MARGIN/2
                    let label = UILabel(frame: CGRect(x: SIDE_MARGIN, y: offset,
                                                      width: FULL_WIDTH, height: categoryHeight))
                    createListLabel(label: label, text: "There are no members", font: infoFont, color: .gray,
                                    view: scrollView)
                    offset += label.frame.height
                }
                
                offset += TOP_MARGIN/2
                addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
                let buttonLength = FULL_WIDTH/4
                
                if isMeeting {
                    if let _ = data["groupme"] as? String {
                        offset += TOP_MARGIN*1.5
                        let groupmeButton = UIButton(frame: CGRect(x: (view.frame.width - buttonLength)*0.7, y: offset,
                                                                   width: buttonLength, height: buttonLength))
                        groupmeButton.setBackgroundImage(UIImage(named: "groupme"), for: .normal)
                        groupmeButton.imageView?.contentMode = .scaleAspectFit
                        groupmeButton.addTarget(self, action: #selector(self.groupmeLink), for: .touchUpInside)
                        scrollView.addSubview(groupmeButton)
                        
                        let calendarButton = UIButton(frame: CGRect(x: (view.frame.width - buttonLength*0.8)*0.3,
                                                                    y: offset,
                                                                    width: buttonLength, height: buttonLength))
                        calendarButton.setBackgroundImage(UIImage(named: "calendar"), for: .normal)
                        calendarButton.imageView?.contentMode = .scaleAspectFit
                        calendarButton.addTarget(self, action: #selector(self.addToCalendar), for: .touchUpInside)
                        scrollView.addSubview(calendarButton)
                        
                        offset += buttonLength + TOP_MARGIN*1.5
                        
                    } else {
                        offset += TOP_MARGIN*1.5
                        let calendarButton = UIButton(frame: CGRect(x: (view.frame.width - buttonLength*0.8)/2, y: offset,
                                                                    width: buttonLength, height: buttonLength))
                        calendarButton.setBackgroundImage(UIImage(named: "calendar"), for: .normal)
                        calendarButton.imageView?.contentMode = .scaleAspectFit
                        calendarButton.addTarget(self, action: #selector(self.addToCalendar), for: .touchUpInside)
                        scrollView.addSubview(calendarButton)
                        
                        offset += buttonLength + TOP_MARGIN*1.5
                    }
                    
                    if !admin { addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView) }
                    
                } else if let _ = data["groupme"] as? String {
                    offset += TOP_MARGIN*1.5
                    let groupmeButton = UIButton(frame: CGRect(x: (view.frame.width - buttonLength)/2, y: offset,
                                                               width: buttonLength, height: buttonLength))
                    groupmeButton.setBackgroundImage(UIImage(named: "groupme"), for: .normal)
                    groupmeButton.imageView?.contentMode = .scaleAspectFit
                    groupmeButton.addTarget(self, action: #selector(self.groupmeLink), for: .touchUpInside)
                    scrollView.addSubview(groupmeButton)
                    
                    offset += buttonLength + TOP_MARGIN*1.5
                    if !admin { addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView) }
                }
                
                if !admin {
                    offset += TOP_MARGIN/2
                    
                    let leaveButton = UIButton(frame: CGRect(x: view.frame.width/2 - FULL_WIDTH/2, y: offset + TOP_MARGIN/2,
                                                             width: FULL_WIDTH, height: categoryHeight))
                    leaveButton.backgroundColor = lightColor
                    leaveButton.setBackgroundImage(squareImage(color: .lightGray, width: leaveButton.frame.width,
                                                               height: leaveButton.frame.height),
                                                   for: .highlighted)
                    leaveButton.setTitle("Leave Team", for: .normal)
                    leaveButton.setTitleColor(redColor, for: .normal)
                    leaveButton.titleLabel?.font = infoFont
                    leaveButton.addTarget(self, action: #selector(self.leaveMT), for: .touchUpInside)
                    offset += leaveButton.frame.height + TOP_MARGIN*2
                    scrollView.addSubview(leaveButton)
                }
                
            } else {
                let joinButton = UIButton(frame: CGRect(x: view.frame.width/2 - FULL_WIDTH/2, y: offset + TOP_MARGIN/2,
                                                        width: FULL_WIDTH, height: categoryHeight))
                joinButton.backgroundColor = lightColor
                joinButton.setBackgroundImage(squareImage(color: .lightGray, width: joinButton.frame.width,
                                                          height: joinButton.frame.height),
                                              for: .highlighted)
                joinButton.setTitle("Request to Join", for: .normal)
                joinButton.setTitleColor(redColor, for: .normal)
                joinButton.titleLabel?.font = infoFont
                joinButton.addTarget(self, action: #selector(self.joinMT), for: .touchUpInside)
                offset += joinButton.frame.height + TOP_MARGIN
                scrollView.addSubview(joinButton)
            }
            
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: offset)
            view.addSubview(scrollView)
        }
        
        navigationItem.title = (data["name"] as! String)
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItems = nil
        
        if admin {
            navigationItem.rightBarButtonItem = edit
        }
    }

    @objc func editTapped() {
        let editMT = CreateMinistryTeamVC()
        editMT.editWith(data)
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        navigationController!.pushViewController(editMT, animated: true)
    }
    
    @objc func addToCalendar() {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        let calendarVC = CalendarVC()
        calendarVC.data = data
        calendarVC.type = .Team
        navigationController!.pushViewController(calendarVC, animated: true)
    }
    
    @objc func leaveMT() {
        let alert = UIAlertController(title: "Leave Ministry Team?",
                                      message: "Are you sure you want to leave this ministry team?",
                                      preferredStyle: .alert)
        let leaveAction = UIAlertAction(title: "Leave", style: .destructive) { _ in
            API.leaveTeam(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                          tid: self.data["tid"] as! Int, completionHandler: { response, data in
                
                switch response {
                case .NotConnected:
                    createAlert(title: "Connection Error", message: "Unable to connect to the server",
                                view: self)
                case .Error:
                    createAlert(title: "Error", message: data as! String, view: self)
                case .InvalidSession:
                    self.backToSignIn()
                case .InternalError:
                    createAlert(title: "Internal Server Error", message: "Something went wrong", view: self)
                default:
                    self.navigationController!.popViewController(animated: true)
                    createAlert(title: "Ministry Team Left", message: "", view: self.hostVC)
                    let teamVC = self.hostVC.contentViewControllers[Tabs.MinistryTeams] as! MinistryTeamVC
                    teamVC.clearTableview()
                    teamVC.startRefreshControl()
                    teamVC.refresh()
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alert.addAction(leaveAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func joinMT() {
        let requestVC = RequestVC()
        requestVC.isCourse = false
        requestVC.id = data["tid"] as! Int
        navigationController!.pushViewController(requestVC, animated: true)
    }
    
    @objc func groupmeLink() {
        UIApplication.shared.open(URL(string: data["groupme"] as! String)!, options: [:], completionHandler: nil)
    }
}
