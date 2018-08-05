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
    
    var data: [String:Any]!
    var editingBC = false
    var courseVC: BibleCourseVC!
    var isTime = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        done.addTarget(self, action: #selector(self.doneTapped), for: .touchUpInside)
        courseVC = hostVC.contentViewControllers[Tabs.BibleCourses] as! BibleCourseVC
        
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
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
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
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
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
        })
        .cellUpdate({cell, row in
            cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            cell.detailTextLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            cell.detailTextLabel?.textColor = .black
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
        })
        .cellUpdate({cell, row in
            cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            cell.detailTextLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            cell.detailTextLabel?.textColor = .black
        })
            
        <<< NameRow() { row in
            row.title = "Location"
            row.placeholder = "Location"
            row.tag = "location"
            if editingBC {
                row.value = data["location"] as? String
            }
            row.cellUpdate { cell, row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
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
                cell.placeholderLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textView.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
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
            row.cellUpdate { cell, row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            }
            row.onCellHighlightChanged { cell, row in
                cell.textLabel?.textColor = redColor
            }
        }
        
        +++ MultivaluedSection(multivaluedOptions: [.Insert, .Delete], header: "ABCL Names", footer: "") {
            $0.addButtonProvider = { section in
                return ButtonRow() { row in
                    row.title = "Add ABCL"
                    row.cellUpdate { cell, _ in
                        cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                        cell.textLabel?.textColor = redColor
                    }
                }
            }
            $0.multivaluedRowToInsertAt = { index in
                return NameRow() { row in
                    row.placeholder = "ABCL's Name"
                    row.tag = "abclName\(index)"
                    row.cellUpdate { cell, _ in
                        cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                    }
                }
            }
            if editingBC {
                var idx = 0
                for abcl in (data["abcls"] as! [String]) {
                    $0 <<< NameRow() { row in
                        row.placeholder = "ABCL's Name"
                        row.value = abcl
                        row.tag = "abclName\(idx)"
                        idx += 1
                        row.cellUpdate { cell, _ in
                            cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
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
            if editingBC {
                var idx = 0
                for email in (data["members"] as! [String:Any])["emails"] as! [String] {
                    $0 <<< EmailRow() { row in
                        row.placeholder = "Member's Email"
                        row.value = email
                        row.tag = "memberEmail\(idx)"
                        idx += 1
                        row.cellUpdate { cell, _ in
                            cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                        }
                    }
                }
            }
        }
            
        +++ MultivaluedSection(multivaluedOptions: [.Insert, .Delete], header: "Course Admins", footer: "") {
            $0.addButtonProvider = { section in
                return ButtonRow() { row in
                    row.title = "Add Course Admin"
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
            if editingBC {
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
        
        if editingBC {
            form +++ Section()
            <<< ButtonRow() { row in
                row.title = "Delete Course"
            }
            .cellUpdate { cell, _row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
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
            view.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/24)
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
        courseVC.refresh(sender: self)
    }
    
    @objc func doneTapped(sender: UIButton) {
        let values = form.values()
        
        let abcls = getMultivaluedSectionValues("abclName")
        let memberEmails = getMultivaluedSectionValues("memberEmail")
        let adminEmails = getMultivaluedSectionValues("adminEmail")
        
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
            
        } else if !memberEmails.filter({ adminEmails.contains($0) }).isEmpty {
            createAlert(title: "Member/Admin Duplicate", message: "Bible course members cannot be admins",
                        view: self)
        
        } else if adminEmails.isEmpty {
            createAlert(title: "Missing an Admin", message: "Bible course needs at least one admin",
                        view: self)
            
        } else {
            
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
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mma"
            
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
                                 meetings: meetings, abcls: abcls, groupme: link, members: memberEmails,
                                 admins: adminEmails) {
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
                        self.backToCourses(title: "Course Updated", message: "")
                    }
                }
                
            } else {
                API.createCourse(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                                 leader_first: leaderFirst, leader_last: leaderLast, year: year, gender: gender,
                                 location: location, material: material, meetings: meetings, abcls: abcls,
                                 groupme: link, members: memberEmails, admins: adminEmails) {
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
                        self.backToCourses(title: "Course Created", message: "")
                    }
                }
            }
        }
    }
}
