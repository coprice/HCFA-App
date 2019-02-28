//
//  DisplayBibleCourseVC.swift
//  HCFA
//
//  Created by Collin Price on 1/14/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit

class DisplayBibleCourseVC: DisplayTemplateVC {
    
    var joined = false
    var admin = false
    var loadingView: LoadingView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadingView = LoadingView(frame: CGRect(x: view.frame.width*0.375,
                                                y: view.frame.height/2 - view.frame.width*0.125,
                                                width: view.frame.width*0.25, height: view.frame.width*0.25))
        
        if firstAppearance {
            firstAppearance = false
            hostVC = (navigationController!.viewControllers.first as! HostVC)
            
            edit = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editTapped))
            
            var offset = navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height
            let SIDE_MARGIN = view.frame.width/20
            let TOP_MARGIN = view.frame.height/60
            let FULL_WIDTH = view.frame.width-SIDE_MARGIN*2
            
            let scrollView = UIScrollView(frame: CGRect(x: 0, y: offset, width: view.frame.width,
                                                        height: view.frame.height - offset))
            scrollView.backgroundColor = .clear
            
            offset = TOP_MARGIN // keep track of total height used
            
            let categoryHeight = calcLabelHeight(text: "Location",
                                                 frame: CGRect(x: SIDE_MARGIN, y: offset + TOP_MARGIN,
                                                               width: FULL_WIDTH, height: .greatestFiniteMagnitude),
                                                 font: displayFont)*1.2
            
            let leader = UILabel(frame: CGRect(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, height: categoryHeight))
            let leaderText = "LEADER  \(data["leader_first"] as! String) \(data["leader_last"] as! String)"
            leader.attributedText = createStringWithBoldRange(from: leaderText, boldRange: NSMakeRange(0, 6),
                                                              fontSize: displayFont.pointSize, color: .black)
            leader.textAlignment = .center
            leader.baselineAdjustment = .alignCenters
            offset += leader.frame.height + TOP_MARGIN
            scrollView.addSubview(leader)
            
            let abcls = (data["abcls"] as! [String])
            for abcl in abcls {
                let label = UILabel(frame: CGRect(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, height: categoryHeight))
                label.attributedText = createStringWithBoldRange(from: "ABCL  \(abcl)", boldRange: NSMakeRange(0, 4),
                                                                 fontSize: displayFont.pointSize, color: .black)
                label.textAlignment = .center
                label.baselineAdjustment = .alignCenters
                scrollView.addSubview(label)
                offset += label.frame.height
            }
            if !abcls.isEmpty {
                offset += TOP_MARGIN
            }

            addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
            offset += TOP_MARGIN/2
            
            var locationText = "\(data["location"] as! String)"
            if let day = data["day"] as? String {
                locationText += "\n\(day)s \(data["start"] as! String)-\(data["end"] as! String)"
            }
            
            let location = UITextView(frame: CGRect(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, height: 0))
            createTextView(location, font: displayFont, text: locationText,
                           color: secondaryCellColor, textAlignment: .center)
            offset += location.frame.height
            scrollView.addSubview(location)
            
            offset += TOP_MARGIN/2
            addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
            offset += TOP_MARGIN/2
            
            let material = UITextView(frame: CGRect(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, height: 0))
            createTextView(material, font: blockTextFont, text: (data["material"] as! String),
                           color: .black, textAlignment: .left)
            offset += material.frame.height + TOP_MARGIN/2
            scrollView.addSubview(material)
            
            addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
            
            if joined {
                let members = (data["members"] as! [String:Any])["info"] as! [[String?]]
                for (i, member) in members.enumerated() {
                    offset += TOP_MARGIN*0.75
                    
                    let imageView = UIImageView(image: UIImage(named: "generic"))
                    if let profile = member[2] {
                        if let url = URL(string: profile) {
                            downloadImage(url: url, view: imageView)
                        }
                    }
                    
                    imageView.frame = CGRect(x: SIDE_MARGIN + FULL_WIDTH*0.23, y: offset,
                                             width: FULL_WIDTH/8, height: FULL_WIDTH/8)
                    imageView.layer.cornerRadius = imageView.frame.width/2
                    imageView.contentMode = .scaleAspectFill
                    imageView.layer.masksToBounds = true
                    imageView.layer.borderColor = UIColor.black.cgColor
                    imageView.layer.borderWidth = 1
                    scrollView.addSubview(imageView)
                    
                    let label = UILabel(frame: CGRect(x: SIDE_MARGIN*2 + FULL_WIDTH*0.35 , y: offset,
                                                      width: FULL_WIDTH*0.65 - SIDE_MARGIN, height: FULL_WIDTH/8))
                    createListLabel(label: label, text: member[0]!, font: memberFont, color: .black, view: scrollView)
                    label.textAlignment = .left
                    
                    if i + 1 != members.count {
                        offset += label.frame.height + TOP_MARGIN*0.75
                        addLightLine(x: SIDE_MARGIN*2, y: offset, width: FULL_WIDTH - SIDE_MARGIN*2, view: scrollView)
                    } else {
                        offset += label.frame.height + TOP_MARGIN/4
                    }
                }
                
                if members.isEmpty {
                    offset += TOP_MARGIN
                    let label = UILabel(frame: CGRect(x: SIDE_MARGIN, y: offset,
                                                      width: FULL_WIDTH, height: categoryHeight))
                    createListLabel(label: label, text: "There are no members", font: displayFont, color: .gray,
                                    view: scrollView)
                    offset += label.frame.height + TOP_MARGIN/2
                }
                
                offset += TOP_MARGIN/2
                addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView)
                let buttonLength = FULL_WIDTH/4
                
                if let _ = data["groupme"] as? String, let _ = data["day"] as? String {
                    
                    offset += TOP_MARGIN*1.5
                    let groupmeButton = UIButton(frame: CGRect(x: (view.frame.width - buttonLength)*0.7, y: offset,
                                                               width: buttonLength, height: buttonLength))
                    groupmeButton.setBackgroundImage(UIImage(named: "groupme"), for: .normal)
                    groupmeButton.imageView?.contentMode = .scaleAspectFit
                    groupmeButton.addTarget(self, action: #selector(groupmeLink), for: .touchUpInside)
                    scrollView.addSubview(groupmeButton)
                    
                    let calendarButton = UIButton(frame: CGRect(x: (view.frame.width - buttonLength*0.8)*0.3,
                                                                y: offset,
                                                                width: buttonLength, height: buttonLength))
                    calendarButton.setBackgroundImage(UIImage(named: "calendar"), for: .normal)
                    calendarButton.imageView?.contentMode = .scaleAspectFit
                    calendarButton.addTarget(self, action: #selector(addToCalendar), for: .touchUpInside)
                    scrollView.addSubview(calendarButton)
                    
                    offset += buttonLength + TOP_MARGIN*1.5
                    if !admin { addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView) }
                
                } else if let _ = data["day"] as? String {
                    
                    offset += TOP_MARGIN*1.5
                    let calendarButton = UIButton(frame: CGRect(x: (view.frame.width - buttonLength*0.8)/2, y: offset,
                                                                width: buttonLength, height: buttonLength))
                    calendarButton.setBackgroundImage(UIImage(named: "calendar"), for: .normal)
                    calendarButton.imageView?.contentMode = .scaleAspectFit
                    calendarButton.addTarget(self, action: #selector(addToCalendar), for: .touchUpInside)
                    scrollView.addSubview(calendarButton)
                    
                    offset += buttonLength + TOP_MARGIN*1.5
                    if !admin { addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView) }
                    
                } else if let _ = data["groupme"] as? String {
                    
                    offset += TOP_MARGIN*1.5
                    let groupmeButton = UIButton(frame: CGRect(x: (view.frame.width - buttonLength)/2, y: offset,
                                                               width: buttonLength, height: buttonLength))
                    groupmeButton.setBackgroundImage(UIImage(named: "groupme"), for: .normal)
                    groupmeButton.imageView?.contentMode = .scaleAspectFit
                    groupmeButton.addTarget(self, action: #selector(groupmeLink), for: .touchUpInside)
                    scrollView.addSubview(groupmeButton)
                    
                    offset += buttonLength + TOP_MARGIN*1.5
                    if !admin { addLine(x: SIDE_MARGIN, y: offset, width: FULL_WIDTH, view: scrollView) }
                }
                
                if !admin {
                    offset += TOP_MARGIN/2
                    let leaveButton = UIButton(frame: CGRect(x: view.frame.width/2 - FULL_WIDTH/4,
                                                             y: offset + TOP_MARGIN,
                                                             width: FULL_WIDTH/2, height: categoryHeight))
                    leaveButton.setTitle("Leave Course", for: .normal)
                    leaveButton.setTitleColor(redColor, for: .normal)
                    leaveButton.setTitleColor(highlightColor, for: .highlighted)
                    leaveButton.titleLabel?.font = displayFont
                    leaveButton.addTarget(self, action: #selector(leaveBC), for: .touchUpInside)
                    offset += leaveButton.frame.height + TOP_MARGIN*2
                    scrollView.addSubview(leaveButton)
                }
                
            } else {
                let joinButton = UIButton(frame: CGRect(x: view.frame.width/2 - FULL_WIDTH/4, y: offset + TOP_MARGIN,
                                                        width: FULL_WIDTH/2, height: categoryHeight))
                joinButton.setTitle("Request to Join", for: .normal)
                joinButton.setTitleColor(redColor, for: .normal)
                joinButton.setTitleColor(highlightColor, for: .highlighted)
                joinButton.titleLabel?.font = displayFont
                joinButton.addTarget(self, action: #selector(joinBC), for: .touchUpInside)
                offset += joinButton.frame.height + TOP_MARGIN*3
                scrollView.addSubview(joinButton)
            }
            
            scrollView.contentSize = CGSize(width: scrollView.frame.width,
                                            height: max(offset, scrollView.frame.height*1.01))
            view.addSubview(scrollView)
        }
        
        navigationItem.title = getTitle()
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItems = nil
        
        if admin {
            navigationItem.rightBarButtonItem = edit
        }
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
    
    func createStringWithBoldRange(from string: String, boldRange: NSRange, fontSize: CGFloat, color: UIColor) -> NSAttributedString {
        let boldAttribute: [NSAttributedString.Key : Any] =
            [.font: UIFont(name: "Montserrat-Bold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize),
             .foregroundColor: color]
        let nonBoldAttribute: [NSAttributedString.Key : Any] =
            [.font: UIFont(name: "Montserrat-Regular" , size: fontSize) ?? UIFont.systemFont(ofSize: fontSize),
             .foregroundColor: color]
        let attrStr = NSMutableAttributedString(string: string, attributes: nonBoldAttribute)
        attrStr.setAttributes(boldAttribute, range: boldRange)
        return attrStr
    }
    
    @objc func editTapped() {
        let editBC = CreateBibleCourseVC()
        editBC.editWith(data)
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        navigationController!.pushViewController(editBC, animated: true)
    }
    
    @objc func addToCalendar() {
        if shouldDisplayCalendar() {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            
            let calendarVC = CalendarVC()
            calendarVC.data = data
            calendarVC.type = .Course
            navigationController!.pushViewController(calendarVC, animated: true)
        } else {
            createAlert(title: "Access not granted", message: "Go to Settings > HCFA > Turn on Calendars",
                        view: self)
        }
    }
    
    @objc func leaveBC() {
        let alert = UIAlertController(title: "Leave Course?",
                                      message: "Are you sure you want to leave this bible course?",
                                      preferredStyle: .alert)
        let leaveAction = UIAlertAction(title: "Leave", style: .destructive) { _ in
            
            self.view.addSubview(self.loadingView)
            self.view.isUserInteractionEnabled = false
            self.navigationController!.navigationBar.isUserInteractionEnabled = false
            
            API.leaveCourse(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                            cid: self.data["cid"] as! Int, completionHandler: { response, data in
                
                self.view.isUserInteractionEnabled = true
                self.navigationController!.navigationBar.isUserInteractionEnabled = true
                self.loadingView.removeFromSuperview()

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
                    courseVC.refresh()
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alert.addAction(leaveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func joinBC() {
        let requestVC = RequestVC()
        requestVC.isCourse = true
        requestVC.id = (data["cid"] as! Int)
        navigationController!.pushViewController(requestVC, animated: true)
    }
    
    @objc func groupmeLink() {
        UIApplication.shared.open(URL(string: data["groupme"] as! String)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
 }

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
