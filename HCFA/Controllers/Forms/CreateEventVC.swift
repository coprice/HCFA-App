//
//  CreateEvent.swift
//  HCFA
//
//  Created by Collin Price on 1/6/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import ImageRow
import Eureka

class CreateEventVC: CreateTemplateVC {
    
    var eventData: [String:Any]!
    var image: UIImage!
    var editingEvent = false
    var eventVC: EventVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        done.addTarget(self, action: #selector(self.doneTapped), for: .touchUpInside)
        eventVC = hostVC.contentViewControllers[Tabs.Events] as! EventVC
        
        let today = Date()
        var startDate: Date!
        var endDate: Date!
        if editingEvent {           
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            startDate = dateFormatter.date(from: (eventData["start"] as! String))!
            endDate = dateFormatter.date(from: (eventData["end"] as! String))!
        }
        
        form +++ Section("General")
            <<< NameRow() { row in
            row.title = "Event Name"
            row.placeholder = "Enter title here"
            row.tag = "title"
            if editingEvent {
                row.value = (eventData["title"] as! String)
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
            row.title = "Location"
            row.placeholder = "Enter address here"
            row.tag = "location"
            if editingEvent {
                row.value = (eventData["location"] as! String)
            }
            row.cellUpdate { cell, row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            }
            row.onCellHighlightChanged { cell, row in
                cell.textLabel?.textColor = redColor
            }
        }
            
            <<< DateTimeInlineRow() { row in
            row.title = "Start"
            row.tag = "start"
            row.dateFormatter?.dateFormat = "h:mm a, MMM d, YYYY"
            if editingEvent {
                row.value = startDate
            } else {
                row.value = today
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
            
            <<< DateTimeInlineRow() { row in
            row.title = "End"
            row.tag = "end"
            row.dateFormatter?.dateFormat = "h:mm a, MMM d, YYYY"
            if editingEvent {
                row.value = endDate
            } else {
                row.value = today
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
            
        +++ Section("Description")
            <<< TextAreaRow() { row in
            row.title = "Description"
            row.placeholder = "Describe the event here"
            row.tag = "description"
            if editingEvent {
                row.value = (eventData["description"] as! String)
            }
            row.cellUpdate { cell, row in
                cell.placeholderLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textView.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            }
        }
        
        +++ Section("Optional")
            <<< ImageRow() { row in
            row.title = "Image"
            row.sourceTypes = [.PhotoLibrary, .Camera]
            row.clearAction = .yes(style: .default)
            row.tag = "image"
            if editingEvent {
                if let loadedImage = image {
                    row.value = loadedImage
                }
            }
            row.cellUpdate { cell, row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            }
        }
        
        if editingEvent {
            form +++ Section()
                <<< ButtonRow() { row in
                row.title = "Delete Event"
            }
            .cellUpdate { cell, _row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textLabel?.textColor = .red
            }
            .onCellSelection { _cell, _row in

                let alert = UIAlertController(title: "Delete Event?",
                                              message: "Are you sure you want to delete this event?",
                                              preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                    
                    self.startLoading()
                    
                    API.deleteEvents(uid: defaults.integer(forKey: "uid"),
                                     token: defaults.string(forKey: "token")!,
                                     events: [self.eventData["eid"] as! Int], completionHandler: { response, data in
                        
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
                            self.backToEvents(title: "Event Deleted", message: "")
                            createAlert(title: "Event Deleted", message: "", view: self.hostVC)
                        }
                    })
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
                
                alert.addAction(cancelAction)
                alert.addAction(deleteAction)
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
        if editingEvent {
            navigationItem.title = "Edit Event"
        } else {
            navigationItem.title = "New Event"
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
    
    func editWith(_ data: [String:Any], _ loadedImage: UIImage?) {
        editingEvent = true
        image = loadedImage
        eventData = data
    }
    
    func backToEvents(title: String, message: String) {
        navigationController!.popToViewController(hostVC, animated: true)
        createAlert(title: title, message: message, view: hostVC)
        eventVC.clearTableview()
        eventVC.startRefreshControl()
        eventVC.refresh(sender: self)
    }
    
    @objc func doneTapped(sender: UIButton) {
        let values = form.values()
        let startDate = values["start"] as! Date
        let endDate = values["end"] as! Date
        
        if values["title"]! == nil {
            createAlert(title: "Title Empty", message: "Enter an event title", view: self)
        } else if values["location"]! == nil {
            createAlert(title: "Location Empty", message: "Enter a location", view: self)
        } else if values["description"]! == nil {
            createAlert(title: "Description Empty", message: "Enter a description", view: self)
        } else if endDate < startDate {
            createAlert(title: "Invalid Dates", message: "An event cannot end before it starts!", view: self)
        } else if endDate == startDate {
            createAlert(title: "Invalid Dates", message: "An event cannot end when it starts!", view: self)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let title = values["title"] as! String
            let location = values["location"] as! String
            let description = values["description"] as! String
            let start = dateFormatter.string(from: startDate)
            let end = dateFormatter.string(from: endDate)
            
            startLoading()
            
            if editingEvent {
                API.updateEvent(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                                eid: (eventData["eid"] as! Int), title: title, location: location, startDate: start,
                                endDate: end, description: description, image: nil) { response, data in
                                    
                    self.stopLoading()
                                    
                    switch response {
                    case .NotConnected:
                        createAlert(title: "Connection Error", message: "Unable to connect to the server", view: self)
                    case .Error:
                        createAlert(title: "Error", message: data as! String, view: self)
                    case .InvalidSession:
                        self.backToSignIn()
                    default:
                        self.backToEvents(title: "Event Updated", message: "")
                        createAlert(title: "Event Updated", message: "", view: self.hostVC)
                    }
                }
                
            } else {
                
                API.createEvent(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                                title: title, location: location, startDate: start, endDate: end,
                                description: description, image: nil) { response, data in
                                    
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
                        self.backToEvents(title: "Event Created", message: "")
                    }
                }
            }
        }
    }
}

