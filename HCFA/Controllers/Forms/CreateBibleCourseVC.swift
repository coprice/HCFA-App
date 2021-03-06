//
//  CreateBibleCourseVC.swift
//  HCFA
//
//  Created by Collin Price on 1/6/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import ImageRow
import Eureka


class CreateBibleCourseVC: CreateTemplateVC {
    
    var done: UIBarButtonItem!
    var courseVC: BibleCourseVC!
    var data: [String:Any]!
    var editingBC = false
    var isTime = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        courseVC = (hostVC.contentViewControllers[Tabs.BibleCourses] as! BibleCourseVC)
        
        let today = Calendar.current.date(bySetting: .minute, value: 0, of: Date())
        
        form +++ Section("Leader")
        <<< NameRow() { row in
            row.title = "First Name"
            row.placeholder = "First Name"
            row.tag = "leader_first"
            if editingBC {
                row.value = data["leader_first"] as? String
            }
            row.cellUpdate { cell, row in
                cell.textLabel?.font = formFont
                cell.textField.font = formFont
            }
            row.onCellHighlightChanged { cell, row in
                cell.textLabel?.textColor = redColor
            }
        }
        <<< NameRow() { row in
            row.title = "Last Name"
            row.placeholder = "Last Name"
            row.tag = "leader_last"
            if editingBC {
                row.value = data["leader_last"] as? String
            }
            row.cellUpdate { cell, row in
                cell.textLabel?.font = formFont
                cell.textField.font = formFont
            }
            row.onCellHighlightChanged { cell, row in
                cell.textLabel?.textColor = redColor
            }
        }
        
        +++ Section("General")
        <<< PushRow<String>() { row in
            row.title = "Year"
            row.options = ["Freshman", "Sophomore", "Junior", "Senior"]
            row.tag = "year"
            if editingBC {
                row.value = data["year"] as? String
            } else {
                row.value = ""
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
            
        <<< PushRow<String>() { row in
            row.title = "Gender"
            row.options = ["Men", "Women"]
            row.tag = "gender"
            if editingBC {
                row.value = data["gender"] as? String
            } else {
                row.value = ""
            }
        }
        .onPresent({(from, to) in
            to.enableDeselection = false
            to.selectableRowCellSetup = { cell, row in
                cell.textLabel?.font = formFont
            }
        })
        .cellSetup({cell, _ in
            cell.textLabel?.font = formFont
            cell.detailTextLabel?.font = formFont
            cell.detailTextLabel?.textColor = .black
            cell.update()
        })
            
        <<< NameRow() { row in
            row.title = "Location"
            row.placeholder = "Location"
            row.tag = "location"
            if editingBC {
                row.value = data["location"] as? String
            }
            row.cellUpdate { cell, row in
                cell.textLabel?.font = formFont
                cell.textField.font = formFont
            }
            row.onCellHighlightChanged { cell, row in
                cell.textLabel?.textColor = redColor
            }
        }
        <<< TextAreaRow() { row in
            row.title = "Material"
            row.placeholder = "Course material"
            row.tag = "material"
            if editingBC {
                row.value = data["material"] as? String
            }
            row.cellUpdate { cell, row in
                cell.placeholderLabel?.font = formFont
                cell.textView.font = formFont
            }
        }
    
        +++ Section("Meeting Day and Time")
        <<< PushRow<String>() { row in
            row.title = "Day"
            row.options = ["TBD", "Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
            row.tag = "day"
            if editingBC && isTime {
                row.value = data["day"] as? String
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
            
        <<< TimeInlineRow { row in
            row.title = "Start Time"
            row.tag = "start"
            row.minuteInterval = 5
            if editingBC && isTime {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mma"
                row.value = dateFormatter.date(from: data["start"] as! String)
            } else {
                row.value = today
            }
            row.hidden = Condition.function(["day"], { form in
                return (form.rowBy(tag: "day")?.value == "TBD")})
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
        <<< TimeInlineRow { row in
            row.title = "End Time"
            row.tag = "end"
            row.minuteInterval = 5
            if editingBC && isTime {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mma"
                row.value = dateFormatter.date(from: data["end"] as! String)
            } else {
                row.value = today
            }
            row.hidden = Condition.function(["day"], { form in
                return (form.rowBy(tag: "day")?.value == "TBD")})
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
            
        +++ Section("GroupMe")
        <<< EmailRow() { row in
            row.placeholder = "GroupMe Link"
            row.tag = "link"
            if editingBC {
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
        
        +++ MultivaluedSection(multivaluedOptions: [.Insert, .Delete], header: "ABCL Names", footer: "") {
            $0.addButtonProvider = { section in
                return ButtonRow() { row in
                    row.title = "Add ABCL"
                    row.cellUpdate { cell, _ in
                        cell.textLabel?.font = formFont
                        cell.textLabel?.textColor = redColor
                    }
                }
            }
            $0.multivaluedRowToInsertAt = { index in
                return NameRow() { row in
                    row.placeholder = "ABCL's Name"
                    row.tag = "abcl\(index)"
                    row.cellUpdate { cell, _ in
                        cell.textField.font = formFont
                    }
                }
            }
            if editingBC {
                var idx = 0
                for abcl in (data["abcls"] as! [String]) {
                    $0 <<< NameRow() { row in
                        row.placeholder = "ABCL's Name"
                        row.value = abcl
                        row.tag = "abcl\(idx)"
                        idx += 1
                        row.cellUpdate { cell, _ in
                            cell.textField.font = formFont
                        }
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
            if editingBC {
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
            
        +++ MultivaluedSection(multivaluedOptions: [.Insert, .Delete], header: "Course Admins", footer: "") {
            $0.addButtonProvider = { section in
                return ButtonRow() { row in
                    row.title = "Add Course Admin"
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
        
            if editingBC {
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
        
        if editingBC {
            form +++ Section()
            <<< ButtonRow() { row in
                row.title = "Delete Course"
            }
            .cellUpdate { cell, _row in
                cell.textLabel?.font = formFont
                cell.textLabel?.textColor = .red
            }
            .onCellSelection { _cell, _row in
                let alert = UIAlertController(title: "Delete Course?",
                                              message: "Are you sure you want to delete this course?",
                                              preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                    
                    self.startLoading()
                    
                    API.deleteCourse(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                                     cid: self.data["cid"] as! Int, completionHandler: { response, data in
                                        
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
                            self.backToCourses(title: "Course Deleted", message: "")
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
        if editingBC {
            navigationItem.title = "Edit Bible Course"
            navigationItem.backBarButtonItem?.title = "Back"
        } else {
            navigationItem.title = "New Bible Course"
        }
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItems = nil
        navigationItem.rightBarButtonItem = done
    }
    
    func editWith(_ loadedData: [String:Any]) {
        editingBC = true
        data = loadedData
        if let _ = data["day"] as? String {
            isTime = true
        }
    }
    
    func backToCourses(title: String, message: String) {
        navigationController!.popToViewController(hostVC, animated: true)
        createAlert(title: title, message: message, view: hostVC)
        courseVC.clearTableview()
        courseVC.startRefreshControl()
        courseVC.refresh()
    }
    
    @objc func doneTapped() {
        tableView.endEditing(true)
        let values = form.values()
        
        let abcls = getMultivaluedSectionValues("abcl")
        let members = getMultivaluedSectionValues("member").map( { $0.slice(from: "(", to: ")")! })
        let admins = getMultivaluedSectionValues("admin").map( { $0.slice(from: "(", to: ")")! })
        
        let day = values["day"] as! String
        
        if values["leader_first"]! == nil {
            createAlert(title: "Leader First Name Empty", message: "Enter the leader's first name", view: self)
        
        } else if values["leader_last"]! == nil {
            createAlert(title: "Leader Last Name Empty", message: "Enter the leader's last name", view: self)
        
        } else if (values["year"] as! String).isEmpty {
            createAlert(title: "Year Empty", message: "Enter a class year", view: self)
        
        } else if (values["gender"] as! String).isEmpty {
            createAlert(title: "Gender Empty", message: "Enter a gender", view: self)
        
        } else if values["location"]! == nil {
            createAlert(title: "Location Empty", message: "Enter a location", view: self)
        
        } else if !abcls.filter({ $0.contains("|") }).isEmpty {
            createAlert(title: "Invalid ABCL Name", message: "Don't be a troll. Remove the |.",
                        view: self)
            
        } else if !members.filter({ admins.contains($0) }).isEmpty {
            createAlert(title: "Member/Admin Duplicate", message: "Bible course members cannot be admins",
                        view: self)
        
        } else if admins.isEmpty {
            createAlert(title: "Missing an Admin", message: "Bible course needs at least one admin",
                        view: self)
            
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mma"
            
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
                
                let start = dateFormatter.string(from: startTime).lowercased()
                let end = dateFormatter.string(from: endTime).lowercased()
                
                meetings!["day"] = day
                meetings!["start"] = start
                meetings!["end"] = end
            }
            
            let leaderFirst = values["leader_first"] as! String
            let leaderLast = values["leader_last"] as! String
            let year = values["year"] as! String
            let gender = values["gender"] as! String
            let material = values["material"] as! String
            let location = values["location"] as! String
            
            var link = values["link"] as? String
            if link == "https://groupme.com/join_group/" {
                link = nil
            }

            startLoading()
            
            if editingBC {
                API.updateCourse(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                                 cid: data["cid"] as! Int, leader_first: leaderFirst, leader_last: leaderLast,
                                 year: year, gender: gender, location: location, material: material,
                                 meetings: meetings, abcls: abcls, groupme: link, members: members,
                                 admins: admins) {
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
                        self.backToCourses(title: "Course Updated", message: "")
                    }
                }
                
            } else {
                API.createCourse(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                                 leader_first: leaderFirst, leader_last: leaderLast, year: year, gender: gender,
                                 location: location, material: material, meetings: meetings, abcls: abcls,
                                 groupme: link, members: members, admins: admins) {
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
                        self.backToCourses(title: "Course Created", message: "")
                    }
                }
            }
        }
    }
}
