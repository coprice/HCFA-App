//
//  CreateMinistryTeamVC.swift
//  HCFA
//
//  Created by Collin Price on 1/6/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import Eureka

class CreateMinistryTeamVC: CreateTemplateVC {
    
    var data: [String:Any]!
    var editingMT = false
    var teamVC: MinistryTeamVC!
    var isMeeting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        done.addTarget(self, action: #selector(self.doneTapped), for: .touchUpInside)
        teamVC = hostVC.contentViewControllers[Tabs.MinistryTeams] as! MinistryTeamVC
        
        form +++ Section("Team Name")
        <<< NameRow() { row in
            row.placeholder = "Team Name"
            row.tag = "name"
            if editingMT {
                row.value = (data["name"] as! String)
            }
            row.cellUpdate { cell, row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            }
            row.onCellHighlightChanged { cell, row in
                cell.textLabel?.textColor = redColor
            }
        }
        
        +++ Section("Team Description")
        <<< TextAreaRow() { row in
            row.placeholder = "Description"
            row.tag = "description"
            if editingMT {
                row.value = (data["description"] as! String)
            }
            row.cellUpdate { cell, row in
                cell.placeholderLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textView.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            }
        }
            
        +++ Section("Weekly Meetings")
        
        <<< PushRow<String>() { row in
            row.title = "Meeting Day"
            row.options = ["TBD", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
            row.tag = "day"
            
            if isMeeting {
                row.value = (data["day"] as! String)
            } else {
                row.value = "TBD"
            }
        }
        .onPresent({(from, to) in
            to.enableDeselection = false
        })
        .cellUpdate({cell, row in
            cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            cell.detailTextLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            cell.detailTextLabel?.textColor = .black
            self.form.rowBy(tag: "start")?.evaluateHidden()
            self.form.rowBy(tag: "end")?.evaluateHidden()
            self.form.rowBy(tag: "location")?.evaluateHidden()
        })
            
        <<< TimeInlineRow() { row in
            row.title = "Start Time"
            row.tag = "start"
            row.hidden = Condition.function(["day"], { form in
                return (form.rowBy(tag: "day")?.value == "TBD")})
            
            if isMeeting {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mma"
                row.value = dateFormatter.date(from: (data["start"] as! String))
            } else {
                row.value = Calendar(identifier: .gregorian).date(from: DateComponents(year: 0, month: 0, day: 0,
                                                                                       hour: 12, minute: 0,
                                                                                       second: 0))
            }
            row.cellUpdate { cell, row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.detailTextLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.detailTextLabel?.textColor = .black
            }
            row.onExpandInlineRow { cell, row, _ in
                cell.detailTextLabel?.textColor = redColor
                row.updateCell()
            }
            row.onCollapseInlineRow { cell, row, _ in
                cell.detailTextLabel?.textColor = .gray
                row.updateCell()
            }
        }
            
        <<< TimeInlineRow() { row in
            row.title = "End Time"
            row.tag = "end"
            row.hidden = Condition.function(["day"], { form in
                return (form.rowBy(tag: "day")?.value == "TBD")})
            
            if isMeeting {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mma"
                row.value = dateFormatter.date(from: (data["end"] as! String))
            } else {
                row.value = Calendar(identifier: .gregorian).date(from: DateComponents(year: 0, month: 0, day: 0,
                                                                                       hour: 13, minute: 0,
                                                                                       second: 0))
            }
            row.cellUpdate { cell, row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.detailTextLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.detailTextLabel?.textColor = .black
            }
            row.onExpandInlineRow { cell, row, _ in
                cell.detailTextLabel?.textColor = redColor
                row.updateCell()
            }
            row.onCollapseInlineRow { cell, row, _ in
                cell.detailTextLabel?.textColor = .gray
                row.updateCell()
            }
        }
            
        <<< TextRow() { row in
            row.title = "Location"
            row.tag = "location"
            row.hidden = Condition.function(["day"], { form in
                return (form.rowBy(tag: "day")?.value == "TBD")})
            
            if isMeeting {
                row.value = (data["location"] as! String)
            }
            row.cellUpdate { cell, row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            }
            row.onCellHighlightChanged { cell, row in
                cell.textLabel?.textColor = redColor
            }
        }
            
        +++ Section("GroupMe")
        <<< EmailRow() { row in
            row.placeholder = "GroupMe Link"
            row.tag = "link"
            if editingMT {
                if let link = data["groupme"] as? String {
                    row.value = link
                } else {
                    row.value = "https://groupme.com/join_group/"
                }
            } else {
                row.value = "https://groupme.com/join_group/"
            }
            row.cellUpdate { cell, row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            }
            row.onCellHighlightChanged { cell, row in
                cell.textLabel?.textColor = redColor
            }
        }
        
        +++ MultivaluedSection(multivaluedOptions: [.Insert, .Delete], header: "Leader Names", footer: "") {
            $0.addButtonProvider = { section in
                return ButtonRow() { row in
                    row.title = "Add Leader"
                    row.cellUpdate { cell, _ in
                        cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                        cell.textLabel?.textColor = redColor
                    }
                }
            }
            $0.multivaluedRowToInsertAt = { index in
                return EmailRow() { row in
                    row.placeholder = "Leader's Name"
                    row.tag = "leaderName\(index)"
                    row.cellUpdate { cell, _ in
                        cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                    }
                }
            }
            if editingMT {
                var idx = 0
                for leader in (data["leaders"] as! [String]) {
                    $0 <<< EmailRow() { row in
                        row.placeholder = "Leader's Name"
                        row.value = leader
                        row.tag = "leaderName\(idx)"
                        idx += 1
                        row.cellUpdate { cell, _ in
                            cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                        }
                    }
                }
            } else {
                $0 <<< EmailRow() { row in
                    row.placeholder = "Leader's Name"
                    row.tag = "leaderName0"
                    row.cellUpdate { cell, _ in
                        cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                    }
                }
            }
        }
            
        +++ MultivaluedSection(multivaluedOptions: [.Insert, .Delete], header: "Members", footer: "") {
            $0.addButtonProvider = { section in
                return ButtonRow() { row in
                    row.title = "Add Member"
                    row.cellUpdate { cell, _ in
                        cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                        cell.textLabel?.textColor = redColor
                    }
                }
            }
            $0.multivaluedRowToInsertAt = { index in
                return EmailRow() { row in
                    row.placeholder = "Member's Email"
                    row.tag = "memberEmail\(index)"
                    row.cellUpdate { cell, _ in
                        cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                    }
                }
            }
            if editingMT {
                var idx = 0
                for member in (data["members"] as! [String:Any])["emails"] as! [String] {
                    $0 <<< EmailRow() { row in
                        row.placeholder = "Member's Email"
                        row.value = member
                        row.tag = "memberEmail\(idx)"
                        idx += 1
                        row.cellUpdate { cell, _ in
                            cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                        }
                    }
                }
            }
        }
        
        +++ MultivaluedSection(multivaluedOptions: [.Insert, .Delete], header: "Team Admins", footer: "") {
            $0.addButtonProvider = { section in
                return ButtonRow() { row in
                    row.title = "Add Team Admin"
                    row.cellUpdate { cell, _ in
                        cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                        cell.textLabel?.textColor = redColor
                    }
                }
            }
            $0.multivaluedRowToInsertAt = { index in
                return EmailRow() { row in
                    row.placeholder = "Admin's Email"
                    row.tag = "adminEmail\(index)"
                    row.cellUpdate { cell, _ in
                        cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                    }
                }
            }
            if editingMT {
                var idx = 0
                for admin in (data["admins"] as! [String:Any])["emails"] as! [String] {
                    $0 <<< EmailRow() { row in
                        row.placeholder = "Admin's Email"
                        row.value = admin
                        row.tag = "adminEmail\(idx)"
                        idx += 1
                        row.cellUpdate { cell, _ in
                            cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                        }
                    }
                }
            } else {
                $0 <<< EmailRow() { row in
                    row.placeholder = "Admin's Email"
                    row.tag = "adminEmail0"
                    row.cellUpdate { cell, _ in
                        cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                    }
                }
            }
        }
        
        if editingMT {
            form +++ Section()
            <<< ButtonRow() { row in
                row.title = "Delete Team"
            }
            .cellUpdate { cell, _row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textLabel?.textColor = .red
            }
            .onCellSelection { _, _ in
                
                let alert = UIAlertController(title: "Delete Team?",
                                              message: "Are you sure you want to delete this team?",
                                              preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                    
                    self.startLoading()
                    
                    API.deleteTeam(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                                   tid: self.data["tid"] as! Int, completionHandler: { response, data in
                                
                        self.stopLoading()
                        
                        switch response {
                        case .NotConnected:
                            createAlert(title: "Connection Error", message: "Unable to connect to the server",
                                        view: self)
                        case .Error:
                            createAlert(title: "Error", message: data as! String, view: self)
                        case .InvalidSession:
                            self.backToSignIn()
                        default:
                            self.backToTeams(title: "Team Deleted", message: "")
                        }
                    })
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
                
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        animateScroll = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if editingMT {
            navigationItem.title = "Edit Ministry Team"
        } else {
            navigationItem.title = "New Ministry Team"
        }
        
        if hostVC.slider.superview != nil {
            hostVC.slider.removeFromSuperview()
        }
        navBar.addSubview(done)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        done.removeFromSuperview()
    }
    
    func editWith(_ loadedData: [String:Any]) {
        editingMT = true
        data = loadedData
        if let _ = data["day"] as? String {
            isMeeting = true
        }
    }
    
    func backToTeams(title: String, message: String) {
        navigationController!.popToViewController(hostVC, animated: true)
        createAlert(title: title, message: message, view: hostVC)
        teamVC.clearTableview()
        teamVC.startRefreshControl()
        teamVC.refresh(sender: self)
    }
    
    @objc func doneTapped(sender: UIButton) {
        let values = form.values()

        if values["name"]! == nil {
            createAlert(title: "Name Empty", message: "Enter a team name", view: self)
            
        } else if values["description"]! == nil {
            createAlert(title: "Description Empty", message: "Enter a team description", view: self)
            
        } else {
            let name = values["name"] as! String
            let description = values["description"] as! String
            let day = values["day"] as! String
            
            var link = values["link"] as? String
            if link == "https://groupme.com/join_group/" {
                link = nil
            }

            var meetings: [String:String]? = nil
            if day != "TBD" {
                meetings = [:]

                let startTime = values["start"] as! Date
                let endTime = values["end"] as! Date
                let location = values["location"] as! String
                
                if day.isEmpty {
                    return createAlert(title: "Day Empty", message: "Enter a day the team meets", view: self)
                    
                } else if endTime < startTime {
                    return createAlert(title: "Invalid times", message: "A meeting cannot end before it starts",
                                       view: self)
                    
                } else if startTime == endTime {
                    return createAlert(title: "Invalid times", message: "A meeting cannot end when it starts",
                                       view: self)
                    
                } else if location.isEmpty {
                    return createAlert(title: "Location Empty", message: "Enter a location", view: self)
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mma"
                let start = dateFormatter.string(from: startTime).lowercased()
                let end = dateFormatter.string(from: endTime).lowercased()
                
                meetings!["day"] = day
                meetings!["start"] = start
                meetings!["end"] = end
                meetings!["location"] = location
            }
            
            let leaderNames = getMultivaluedSectionValues("leaderName")
            let memberEmails = getMultivaluedSectionValues("memberEmail")
            let adminEmails = getMultivaluedSectionValues("adminEmail")
            
            if leaderNames.isEmpty {
                return createAlert(title: "Missing Leaders", message: "Enter the names of the team leaders",
                                   view: self)
            } else if !leaderNames.filter({ $0.contains("|") }).isEmpty {
                return createAlert(title: "Invalid Leader Name", message: "Don't be a troll. Remove the |.",
                                   view: self)
            
            } else if adminEmails.isEmpty {
                return createAlert(title: "Missing an Admin", message: "Ministry team needs at least one admin",
                                   view: self)
            
            } else if !memberEmails.filter({ adminEmails.contains($0) }).isEmpty {
                createAlert(title: "Member/Admin Duplicate", message: "Ministry team members cannot be admins",
                            view: self)
            }
            
            startLoading()
            
            if editingMT {
                API.updateTeam(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                               tid: data["tid"] as! Int, name: name, description: description, leaders: leaderNames,
                               meetings: meetings, groupme: link, members: memberEmails, admins: adminEmails) {
                    response, data in
                    
                    self.stopLoading()
                    
                    switch response {
                    case .NotConnected:
                        createAlert(title: "Connection Error", message: "Unable to connect to the server",
                                    view: self)
                    case .Error:
                        createAlert(title: "Error", message: data as! String, view: self)
                    case .InvalidSession:
                        self.backToSignIn()
                    default:
                        self.backToTeams(title: "Team Updated", message: "")
                    }
                }
                
            } else {
                API.createTeam(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                               name: name, description: description, leaders: leaderNames, meetings: meetings,
                               groupme: link, members: memberEmails, admins: adminEmails) { response, data in
                    
                    self.stopLoading()
                    
                    switch response {
                    case .NotConnected:
                        createAlert(title: "Connection Error", message: "Unable to connect to the server", view: self)
                    case .Error:
                        createAlert(title: "Error", message: data as! String, view: self)
                    case .InvalidSession:
                        self.backToSignIn()
                    default:
                        self.backToTeams(title: "Team Created", message: "")
                    }
                }
            }
        }
    }
}
