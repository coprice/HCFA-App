//
//  DisplayBibleCourseVC.swift
//  HCFA
//
//  Created by Collin Price on 1/14/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit
import EventKit

class DisplayBibleCourseVC: DisplayTemplateVC {
    
    var navBar: UINavigationBar!
    var edit: UIButton!
    var data: [String:Any]!
    var hostVC: HostVC!
    var joined = false
    var admin = false
    var firstAppearance = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = getTitle()
        
        if firstAppearance {
            firstAppearance = false
            navBar = navigationController!.navigationBar
            hostVC = navigationController!.viewControllers.first as! HostVC
            
            edit = UIButton(frame: CGRect(x: navBar.frame.width*0.75, y: 0, width: navBar.frame.width/4,
                                          height: navBar.frame.height))
            edit.setTitle("Edit", for: .normal)
            edit.titleLabel?.textColor = .white
            edit.titleLabel?.font = UIFont(name: "Baskerville", size: view.frame.width/21)
            edit.setTitleColor(barHighlightColor, for: .highlighted)
            edit.addTarget(self, action: #selector(self.editTapped), for: .touchUpInside)
            
            var offset = navBar.frame.height + UIApplication.shared.statusBarFrame.height
            let SIDE_MARGIN = view.frame.width/20
            let TOP_MARGIN = view.frame.height/60
            let FULL_WIDTH = view.frame.width-SIDE_MARGIN*2
            
            let scrollView = UIScrollView(frame: CGRect(x: 0, y: offset, width: view.frame.width,
                                                        height: view.frame.height - offset))
            scrollView.backgroundColor = .clear
            
            offset = TOP_MARGIN // keep track of total height used
            
            let categoryFont = UIFont(name: "Baskerville", size: view.frame.width/12)!
            let infoFont = UIFont(name: "Baskerville", size: view.frame.width/20)!
            let categoryHeight = calcLabelHeight(text: "Location",
                                                 frame: CGRect(x: SIDE_MARGIN, y: offset + TOP_MARGIN,
                                                               width: FULL_WIDTH, height: .greatestFiniteMagnitude),
                                                 font: categoryFont)
            
            let leader = UILabel(frame: CGRect(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, height: categoryHeight))
            leader.text = "Leader: \(data["leader_first"] as! String) \(data["leader_last"] as! String)"
            leader.textAlignment = .center
            leader.font = infoFont
            leader.textColor = .black
            leader.baselineAdjustment = .alignCenters
            offset += leader.frame.height + TOP_MARGIN
            scrollView.addSubview(leader)
            
            let abcls = (data["abcls"] as! [String])
            for abcl in abcls {
                let label = UILabel(frame: CGRect(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, height: categoryHeight))
                createListLabel(label: label, text: "ABCL: \(abcl)", font: infoFont, color: .black, view: scrollView)
                offset += label.frame.height
            }
            if !abcls.isEmpty {
                offset += TOP_MARGIN/2
            }

            addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
            offset += TOP_MARGIN/2
            
            var locationText = "\(data["location"] as! String)"
            if let day = data["day"] as? String {
                locationText += "\n\(day)s \(data["start"] as! String)-\(data["end"] as! String)"
            }
            
            let location = UITextView(frame: CGRect(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, height: 0))
            createTextView(location, font: infoFont,
                           text: locationText,
                           color: .darkGray, textAlignment: .center)
            offset += location.frame.height
            scrollView.addSubview(location)
            
            offset += TOP_MARGIN/2
            addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
            offset += TOP_MARGIN/2
            
            let material = UITextView(frame: CGRect(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, height: 0))
            createTextView(material, font: infoFont, text: (data["material"] as! String), color: .black,
                           textAlignment: .left)
            offset += material.frame.height
            scrollView.addSubview(material)
            
            offset += TOP_MARGIN/2
            addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
            
            if joined {
                offset += TOP_MARGIN
                let members = (data["members"] as! [String:Any])["info"] as! [[String?]]
                for (i, member) in members.enumerated() {
                    
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
                        offset += label.frame.height + TOP_MARGIN/2
                        addLightLine(x: SIDE_MARGIN*2, y: offset, width: FULL_WIDTH - SIDE_MARGIN*2, view: scrollView)
                        offset += TOP_MARGIN/2
                    } else {
                        offset += label.frame.height
                    }
                }
                if members.isEmpty {
                    let label = UILabel(frame: CGRect(x: SIDE_MARGIN, y: offset,
                                                      width: FULL_WIDTH, height: categoryHeight))
                    createListLabel(label: label, text: "There are no members", font: infoFont, color: .gray,
                                    view: scrollView)
                    offset += label.frame.height
                }
                offset += TOP_MARGIN/2
                addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
                offset += TOP_MARGIN/2
                
                if let _ = data["groupme"] as? String {
                    let groupmeWidth = FULL_WIDTH*0.6
                    let groupmeHeight = groupmeWidth/2
                    
                    let groupmeButton = UIButton(frame: CGRect(x: (view.frame.width - groupmeWidth)/2, y: offset,
                                                               width: groupmeWidth, height: groupmeHeight))
                    groupmeButton.setBackgroundImage(UIImage(named: "groupme"), for: .normal)
                    groupmeButton.imageView?.contentMode = .scaleAspectFit
                    groupmeButton.addTarget(self, action: #selector(self.groupmeLink), for: .touchUpInside)
                    scrollView.addSubview(groupmeButton)
                    
                    offset += groupmeHeight + TOP_MARGIN/2
                    addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
                }
                
                if let _ = data["day"] as? String {
                    
                    let calendarWidth = FULL_WIDTH*0.6
                    let calendarHeight = calendarWidth/2
                    
                    let calendarButton = UIButton(frame: CGRect(x: (view.frame.width - calendarWidth)/2, y: offset,
                                                                width: calendarWidth, height: calendarHeight))
                    calendarButton.setBackgroundImage(UIImage(named: "calendar"), for: .normal)
                    calendarButton.imageView?.contentMode = .scaleAspectFit
                    calendarButton.addTarget(self, action: #selector(self.addToCalendar), for: .touchUpInside)
                    scrollView.addSubview(calendarButton)
                    
                    offset += calendarHeight + TOP_MARGIN/2
                }
                
                if !admin {
                    addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
                    let leaveButton = UIButton(frame: CGRect(x: view.frame.width/2 - FULL_WIDTH/2, y: offset + TOP_MARGIN,
                                                             width: FULL_WIDTH, height: categoryHeight))
                    leaveButton.backgroundColor = lightColor
                    leaveButton.setBackgroundImage(squareImage(color: .lightGray, width: leaveButton.frame.width,
                                                               height: leaveButton.frame.height),
                                                   for: .highlighted)
                    leaveButton.setTitle("Leave Course", for: .normal)
                    leaveButton.setTitleColor(redColor, for: .normal)
                    leaveButton.titleLabel?.font = infoFont
                    leaveButton.addTarget(self, action: #selector(self.leaveBC), for: .touchUpInside)
                    offset += leaveButton.frame.height + TOP_MARGIN*2
                    scrollView.addSubview(leaveButton)
                }
                
            } else {
                let joinButton = UIButton(frame: CGRect(x: view.frame.width/2 - FULL_WIDTH/2, y: offset + TOP_MARGIN,
                                                        width: FULL_WIDTH, height: categoryHeight))
                joinButton.backgroundColor = lightColor
                joinButton.setBackgroundImage(squareImage(color: .lightGray, width: joinButton.frame.width,
                                                          height: joinButton.frame.height),
                                              for: .highlighted)
                joinButton.setTitle("Request to Join", for: .normal)
                joinButton.setTitleColor(redColor, for: .normal)
                joinButton.titleLabel?.font = infoFont
                joinButton.addTarget(self, action: #selector(self.joinBC), for: .touchUpInside)
                offset += joinButton.frame.height + TOP_MARGIN*3
                scrollView.addSubview(joinButton)
            }
            
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: offset)
            view.addSubview(scrollView)
        }

        if hostVC.slider.superview != nil {
            hostVC.slider.removeFromSuperview()
        }
        
        if admin {
            navBar.addSubview(edit)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        edit.removeFromSuperview()
    }
    
    func getTitle() -> String {
        let year = data["year"] as! String
        var yearPlural: String
        switch year {
            case "Freshman": yearPlural = "Freshmen"
            default: yearPlural = "\(year)s"
        }
        let firstName = (data["leader_first"] as! String)
        if firstName.suffix(1) == "s" {
            return "\(firstName)' \(yearPlural)"
        } else {
            return "\(firstName)'s \(yearPlural)"
        }
    }
    
    @objc func editTapped(sender: UIButton) {
        let editBC = CreateBibleCourseVC()
        editBC.editWith(data)
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navBar.topItem?.backBarButtonItem = backItem
        
        navigationController!.pushViewController(editBC, animated: true)
    }
    
    @objc func addToCalendar(sender: UIButton) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navBar.topItem?.backBarButtonItem = backItem
        
        let calendarVC = CalendarVC()
        calendarVC.data = data
        calendarVC.type = .Course
        navigationController!.pushViewController(calendarVC, animated: true)
    }
    
    @objc func leaveBC(sender: UIButton) {
        let alert = UIAlertController(title: "Leave Course?",
                                      message: "Are you sure you want to leave this bible course?",
                                      preferredStyle: .alert)
        let leaveAction = UIAlertAction(title: "Leave", style: .destructive) { _ in
            
            API.leaveCourse(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!, cid: self.data["cid"] as! Int, completionHandler: { response, data in
                
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
                    createAlert(title: "Bible Course Left", message: "", view: self.hostVC)
                    let courseVC = self.hostVC.contentViewControllers[Tabs.BibleCourses] as! BibleCourseVC
                    courseVC.clearTableview()
                    courseVC.startRefreshControl()
                    courseVC.refresh(sender: self)
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alert.addAction(leaveAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func joinBC(sender: UIButton) {
        let requestVC = RequestVC()
        requestVC.isCourse = true
        requestVC.id = data["cid"] as! Int
        requestVC.parentVC = self
        navigationController!.pushViewController(requestVC, animated: true)
    }
    
    @objc func groupmeLink(sender: UIButton) {
        UIApplication.shared.open(URL(string: data["groupme"] as! String)!, options: [:], completionHandler: nil)
    }
 }
