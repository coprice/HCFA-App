//
//  CreateMinistryTeamVC.swift
//  HCFA
//
//  Created by Collin Price on 1/6/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import Eureka

class CreateMinistryTeamVC: CreateTemplateVC {
    
    var done: UIBarButtonItem!
    var teamVC: MinistryTeamVC!
    var data: [String:Any]!
    var editingMT = false
    var isMeeting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        teamVC = (hostVC.contentViewControllers[Tabs.MinistryTeams] as! MinistryTeamVC)
        
        let today = Calendar.current.date(bySetting: .minute, value: 0, of: Date())
        
        form +++ Section("Team Name")
        <<< NameRow() { row in
            row.placeholder = "Team Name"
            row.tag = "name"
            if editingMT {
                row.value = (data["name"] as! String)
            }
            row.cellUpdate { cell, row in
                cell.textLabel?.font = formFont
                cell.textField.font = formFont
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
                cell.placeholderLabel?.font = formFont
                cell.textView.font = formFont
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
        .onPresent({ from, to in
            to.enableDeselection = false
            to.selectableRowCellSetup = { cell, row in
                cell.textLabel?.font = formFont
            }
        })
        .cellSetup({ cell, _ in
            cell.textLabel?.font = formFont
            cell.detailTextLabel?.font = formFont
            cell.detailTextLabel?.textColor = .black
            cell.update()
        })
        .cellUpdate({ _, _ in
            self.form.rowBy(tag: "start")?.evaluateHidden()
            self.form.rowBy(tag: "end")?.evaluateHidden()
            self.form.rowBy(tag: "location")?.evaluateHidden()
        })
            
        <<< TimeInlineRow() { row in
            row.title = "Start Time"
            row.tag = "start"
            row.minuteInterval = 5
            row.hidden = Condition.function(["day"], { form in
                return (form.rowBy(tag: "day")?.value == "TBD")})
            
            if isMeeting {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mma"
                row.value = dateFormatter.date(from: (data["start"] as! String))
            } else {
                row.value = today
            }
            row.cellSetup { cell, row in
                cell.textLabel?.font = formFont
                cell.detailTextLabel?.font = formFont
                cell.detailTextLabel?.textColor = .black
            }
            row.onExpandInlineRow { cell, row, _ in
                cell.detailTextLabel?.textColor = redColor
                row.updateCell()
            }
            row.onCollapseInlineRow { cell, row, _ in
                cell.detailTextLabel?.textColor = .black
                row.updateCell()
                
                let endRow = (self.form.rowBy(tag: "end") as! TimeInlineRow).baseCell.baseRow
                if let endDate = endRow?.baseValue as? Date {
                    if let startDate = row.value {
                        if startDate > endDate {
                            endRow?.baseValue = startDate
                            endRow?.updateCell()
                        }
                    }
                }
            }
        }
            
        <<< TimeInlineRow() { row in
            row.title = "End Time"
            row.tag = "end"
            row.minuteInterval = 5
            row.hidden = Condition.function(["day"], { form in
                return (form.rowBy(tag: "day")?.value == "TBD")})
            
            if isMeeting {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mma"
                row.value = dateFormatter.date(from: (data["end"] as! String))
            } else {
                row.value = today
            }
            row.cellSetup { cell, row in
                cell.textLabel?.font = formFont
                cell.detailTextLabel?.font = formFont
                cell.detailTextLabel?.textColor = .black
            }
            row.onExpandInlineRow { cell, row, _ in
                cell.detailTextLabel?.textColor = redColor
                row.updateCell()
            }
            row.onCollapseInlineRow { cell, row, _ in
                cell.detailTextLabel?.textColor = .black
                row.updateCell()
                
                let startRow = (self.form.rowBy(tag: "start") as! TimeInlineRow).baseCell.baseRow
                if let startDate = startRow?.baseValue as? Date {
                    if let endDate = row.value {
                        if endDate < startDate {
                            startRow?.baseValue = endDate
                            startRow?.updateCell()
                        }
                    }
                }
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
            row.cellUpdate { cell, _ in
                cell.textLabel?.font = formFont
                cell.textField.font = formFont
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
            row.cellUpdate { cell, _ in
                cell.textLabel?.font = formFont
                cell.textField.font = formFont
            }
        }
        
        +++ MultivaluedSection(multivaluedOptions: [.Insert, .Delete], header: "Leader Names", footer: "") {
            $0.addButtonProvider = { section in
                return ButtonRow() { row in
                    row.title = "Add Leader"
                    row.cellUpdate { cell, _ in
                        cell.textLabel?.font = formFont
                        cell.textLabel?.textColor = redColor
                    }
                }
            }
            $0.multivaluedRowToInsertAt = { index in
                return NameRow() { row in
                    row.placeholder = "Leader's Name"
                    row.tag = "leader\(index)"
                    row.cellUpdate { cell, _ in
                        cell.textField.font = formFont
                    }
                }
            }
            if editingMT {
                var idx = 0
                for leader in (data["leaders"] as! [String]) {
                    $0 <<< NameRow() { row in
                        row.placeholder = "Leader's Name"
                        row.value = leader
                        row.tag = "leader\(idx)"
                        idx += 1
                        row.cellUpdate { cell, _ in
                            cell.textField.font = formFont
                        }
                    }
                }
            } else {
                $0 <<< NameRow() { row in
                    row.placeholder = "Leader's Name"
                    row.tag = "leader0"
                    row.cellUpdate { cell, _ in
                        cell.textField.font = formFont
                    }
                }
            }
        }
            
        +++ MultivaluedSection(multivaluedOptions: [.Insert, .Delete], header: "Members", footer: "") {
            $0.addButtonProvider = { section in
                return ButtonRow() { row in
                    row.title = "Add Member"
                    row.cellUpdate { cell, _ in
                        cell.textLabel?.font = formFont
                        cell.textLabel?.textColor = redColor
                    }
                }
            }
            $0.multivaluedRowToInsertAt = { index in
                return SearchPushRow<String>() { row in
                    row.tag = "member\(index)"
                    if let users = defaults.array(forKey: "users") as? [[String]] {
                        row.options = users.map({ "\($0[0]) \($0[1]) (\($0[2]))" })
                    } else {
                        API.getUsers(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!, completionHandler: { (response, data) in
                            
                            if response == .Success {
                                if let data = data as? [String:Any] {
                                    if let users = data["users"] as? [[String]] {
                                        defaults.set(users, forKey: "users")
                                        row.options = users.map({ "\($0[0]) \($0[1]) (\($0[2]))" })
                                    }
                                }
                            }
                        })
                    }
                }
                .onPresent({(from, to) in
                    to.enableDeselection = false
                    to.selectableRowCellSetup = { cell, _ in
                        cell.textLabel?.font = formFont
                    }
                })
                .cellSetup({cell, _ in
                    cell.textLabel?.font = formFont
                    cell.detailTextLabel?.font = formFont
                    cell.detailTextLabel?.textColor = .black
                    cell.update()
                })
            }
            if editingMT {
                var idx = 0
                for member in (data["members"] as! [String:Any])["info"] as! [[Any]] {
                    $0 <<< SearchPushRow<String>() { row in
                        row.value = "\(member[0] as! String) (\(member[1] as! String))"
                        row.tag = "member\(idx)"
                        idx += 1
                        if let users = defaults.array(forKey: "users") as? [[String]] {
                            row.options = users.map({ "\($0[0]) \($0[1]) (\($0[2]))" })
                        } else {
                            API.getUsers(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!, completionHandler: { (response, data) in
                                
                                if response == .Success {
                                    if let data = data as? [String:Any] {
                                        if let users = data["users"] as? [[String]] {
                                            defaults.set(users, forKey: "users")
                                            row.options = users.map({ "\($0[0]) \($0[1]) (\($0[2]))" })
                                        }
                                    }
                                }
                            })
                        }
                    }
                    .onPresent({(from, to) in
                        to.enableDeselection = false
                        to.selectableRowCellSetup = { cell, _ in
                            cell.textLabel?.font = formFont
                        }
                    })
                    .cellSetup({cell, _ in
                        cell.textLabel?.font = formFont
                        cell.detailTextLabel?.font = formFont
                        cell.detailTextLabel?.textColor = .black
                        cell.update()
                    })
                }
            }
        }
        
        +++ MultivaluedSection(multivaluedOptions: [.Insert, .Delete], header: "Team Admins", footer: "") {
            $0.addButtonProvider = { section in
                return ButtonRow() { row in
                    row.title = "Add Team Admin"
                    row.cellUpdate { cell, _ in
                        cell.textLabel?.font = formFont
                        cell.textLabel?.textColor = redColor
                    }
                }
            }
            $0.multivaluedRowToInsertAt = { index in
                return SearchPushRow<String>() { row in
                    row.tag = "admin\(index)"
                    if let users = defaults.array(forKey: "users") as? [[String]] {
                        row.options = users.map({ "\($0[0]) \($0[1]) (\($0[2]))" })
                    } else {
                        API.getUsers(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!, completionHandler: { (response, data) in
                            
                            if response == .Success {
                                if let data = data as? [String:Any] {
                                    if let users = data["users"] as? [[String]] {
                                        defaults.set(users, forKey: "users")
                                        row.options = users.map({ "\($0[0]) \($0[1]) (\($0[2]))" })
                                    }
                                }
                            }
                        })
                    }
                }
                .onPresent({(from, to) in
                    to.enableDeselection = false
                    to.selectableRowCellSetup = { cell, _ in
                        cell.textLabel?.font = formFont
                    }
                })
                .cellSetup({cell, _ in
                    cell.textLabel?.font = formFont
                    cell.detailTextLabel?.font = formFont
                    cell.detailTextLabel?.textColor = .black
                    cell.update()
                })
            }
            
            if editingMT {
                var idx = 0
                for admin in (data["admins"] as! [String:Any])["info"] as! [[String]] {
                    $0 <<< SearchPushRow<String>() { row in
                        row.value = "\(admin[0]) (\(admin[1]))"
                        row.tag = "admin\(idx)"
                        idx += 1
                        if let users = defaults.array(forKey: "users") as? [[String]] {
                            row.options = users.map({ "\($0[0]) \($0[1]) (\($0[2]))" })
                        } else {
                            API.getUsers(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!, completionHandler: { (response, data) in
                                
                                if response == .Success {
                                    if let data = data as? [String:Any] {
                                        if let users = data["users"] as? [[String]] {
                                            defaults.set(users, forKey: "users")
                                            row.options = users.map({ "\($0[0]) \($0[1]) (\($0[2]))" })
                                        }
                                    }
                                }
                            })
                        }
                    }
                    .onPresent({(from, to) in
                        to.enableDeselection = false
                        to.selectableRowCellSetup = { cell, _ in
                            cell.textLabel?.font = formFont
                        }
                    })
                    .cellSetup({cell, _ in
                        cell.textLabel?.font = formFont
                        cell.detailTextLabel?.font = formFont
                        cell.detailTextLabel?.textColor = .black
                        cell.update()
                    })
                }
            } else {
                $0 <<< SearchPushRow<String>() { row in
                    row.tag = "admin0"
                    if let users = defaults.array(forKey: "users") as? [[String]] {
                        row.options = users.map({ "\($0[0]) \($0[1]) (\($0[2]))" })
                    } else {
                        API.getUsers(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!, completionHandler: { (response, data) in
                            
                            if response == .Success {
                                if let data = data as? [String:Any] {
                                    if let users = data["users"] as? [[String]] {
                                        defaults.set(users, forKey: "users")
                                        row.options = users.map({ "\($0[0]) \($0[1]) (\($0[2]))" })
                                    }
                                }
                            }
                        })
                    }
                }
                .onPresent({(from, to) in
                    to.enableDeselection = false
                    to.selectableRowCellSetup = { cell, _ in
                        cell.textLabel?.font = formFont
                    }
                })
                .cellSetup({cell, _ in
                    cell.textLabel?.font = formFont
                    cell.detailTextLabel?.font = formFont
                    cell.detailTextLabel?.textColor = .black
                    cell.update()
                })
            }
        }
        
        if editingMT {
            form +++ Section()
            <<< ButtonRow() { row in
                row.title = "Delete Team"
            }
            .cellUpdate { cell, _ in
                cell.textLabel?.font = formFont
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
                        case .InternalError:
                            createAlert(title: "Internal Server Error", message: "Something went wrong", view: self)
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
    
    func tableView(_: UITableView, willDisplayHeaderView view: UIView, forSection: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.font = formHeaderFont
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if editingMT {
            navigationItem.title = "Edit Ministry Team"
        } else {
            navigationItem.title = "New Ministry Team"
        }
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = done
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
        teamVC.refresh()
    }
    
    @objc func doneTapped() {
        tableView.endEditing(true)
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
            
            let leaders = getMultivaluedSectionValues("leader")
            let members = getMultivaluedSectionValues("member").map({ $0.slice(from: "(", to: ")")! })
            let admins = getMultivaluedSectionValues("admin").map({ $0.slice(from: "(", to: ")")! })
            
            if leaders.isEmpty {
                return createAlert(title: "Missing Leaders", message: "Enter the names of the team leaders",
                                   view: self)
            } else if !leaders.filter({ $0.contains("|") }).isEmpty {
                return createAlert(title: "Invalid Leader Name", message: "Don't be a troll. Remove the |.",
                                   view: self)
            
            } else if admins.isEmpty {
                return createAlert(title: "Missing an Admin", message: "Ministry team needs at least one admin",
                                   view: self)
            
            } else if !members.filter({ admins.contains($0) }).isEmpty {
                createAlert(title: "Member/Admin Duplicate", message: "Ministry team members cannot be admins",
                            view: self)
            }
            
            startLoading()
            
            if editingMT {
                API.updateTeam(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                               tid: data["tid"] as! Int, name: name, description: description, leaders: leaders,
                               meetings: meetings, groupme: link, members: members, admins: admins) {
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
                    case .InternalError:
                        createAlert(title: "Internal Server Error", message: "Something went wrong", view: self)
                    default:
                        self.backToTeams(title: "Team Updated", message: "")
                    }
                }
                
            } else {
                API.createTeam(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                               name: name, description: description, leaders: leaders, meetings: meetings,
                               groupme: link, members: members, admins: admins) { response, data in
                    
                    self.stopLoading()
                    
                    switch response {
                    case .NotConnected:
                        createAlert(title: "Connection Error", message: "Unable to connect to the server", view: self)
                    case .Error:
                        createAlert(title: "Error", message: data as! String, view: self)
                    case .InvalidSession:
                        self.backToSignIn()
                    case .InternalError:
                        createAlert(title: "Internal Server Error", message: "Something went wrong", view: self)
                    default:
                        self.backToTeams(title: "Team Created", message: "")
                    }
                }
            }
        }
    }
}
