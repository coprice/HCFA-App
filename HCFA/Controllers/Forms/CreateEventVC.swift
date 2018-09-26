//
//  CreateEvent.swift
//  HCFA
//
//  Created by Collin Price on 1/6/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import ImageRow
import Eureka
import AWSCore
import AWSS3


class CreateEventVC: CreateTemplateVC {
    
    var done: UIBarButtonItem!
    var eventVC: EventVC!
    var eventData: [String:Any]!
    var editingEvent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        eventVC = (hostVC.contentViewControllers[Tabs.Events] as! EventVC)
        
        let today = Calendar.current.date(bySetting: .minute, value: 0, of: Date())
        
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
            row.title = "Title"
            row.placeholder = "Title"
            row.tag = "title"
            if editingEvent {
                row.value = (eventData["title"] as! String)
            }
            row.cellUpdate { cell, _ in
                cell.textLabel?.font = formFont
                cell.textField.font = formFont
            }
            row.onCellHighlightChanged { cell, row in
                cell.textLabel?.textColor = redColor
            }
        }
        <<< NameRow() { row in
            row.title = "Location"
            row.placeholder = "Location"
            row.tag = "location"
            if editingEvent {
                row.value = (eventData["location"] as! String)
            }
            row.cellUpdate { cell, row in
                cell.textLabel?.font = formFont
                cell.textField.font = formFont
            }
            row.onCellHighlightChanged { cell, row in
                cell.textLabel?.textColor = redColor
            }
        }
        
        form +++ Section("Date & Time")
            
        <<< DateTimeInlineRow() { row in
            row.title = "Start"
            row.tag = "start"
            row.minuteInterval = 5
            row.dateFormatter?.dateFormat = "h:mm a, MMM d, YYYY"
            if editingEvent {
                row.value = startDate
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
                
                let endRow = (self.form.rowBy(tag: "end") as! DateTimeInlineRow).baseCell.baseRow
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
            
        <<< DateTimeInlineRow() { row in
            row.title = "End"
            row.tag = "end"
            row.minuteInterval = 5
            row.dateFormatter?.dateFormat = "h:mm a, MMM d, YYYY"
            if editingEvent {
                row.value = endDate
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
                
                let startRow = (self.form.rowBy(tag: "start") as! DateTimeInlineRow).baseCell.baseRow
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
            
        +++ Section("Repeat")
        
        <<< PushRow<String>() { row in
            row.title = "Repeat"
            row.options = ["Never", "Every Day", "Every Week", "Every 2 weeks", "Every Month", "Every Year"]
            row.tag = "repeat"
            if editingEvent {
                row.value = eventData["repeat"] as? String
            } else {
                row.value = "Never"
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
        
        <<< SwitchRow() { row in
            row.title = "Multiple Days"
            row.tag = "multiple"
            row.value = false
            row.hidden = Condition.function(["repeat"], { form in
                if let value = form.rowBy(tag: "repeat")?.baseValue as? String {
                    return value != "Every Week" && value != "Every 2 weeks"
                }
                return true
            })
            
            row.cellSetup  { cell, _ in
                cell.textLabel?.font = formFont
                cell.switchControl.onTintColor = redColor
            }
        }
            
        let repeatSection = Section("Repeat Days") {
            $0.tag = "repeat_days"
            $0.hidden = Condition.function(["multiple", "repeat"], { form in
                if let multiple = form.rowBy(tag: "multiple") {
                    return multiple.isHidden || !(multiple.baseValue as! Bool)
                }
                return true
            })
        }
        
        for day in ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"] {
            repeatSection <<< CheckRow { row in
                row.title = day
                row.tag = day
                row.value = false
                row.cellUpdate { cell, row in
                    cell.textLabel?.font = formFont
                }
            }
        }
        
        form +++ repeatSection
        
        form +++ Section("Description")
            <<< TextAreaRow() { row in
            row.title = "Description"
            row.placeholder = "Description"
            row.tag = "description"
            if editingEvent {
                row.value = (eventData["description"] as! String)
            }
            row.cellUpdate { cell, row in
                cell.placeholderLabel?.font = formFont
                cell.textView.font = formFont
            }
        }
        
        +++ Section("Optional")
            <<< ImageRow() { row in
            row.title = "Image"
            row.sourceTypes = [.PhotoLibrary, .Camera]
            row.clearAction = .yes(style: .default)
            row.tag = "image"
            if editingEvent {
                DispatchQueue.main.async {
                    if let eventImages = defaults.dictionary(forKey: "eventImages") as? [String:Data] {
                        if let data = eventImages[String(self.eventData["eid"] as! Int)] {
                            row.value = UIImage(data: data)
                            row.updateCell()
                        }
                    }
                }
            }
            row.cellSetup { cell, row in
                cell.textLabel?.font = formFont
            }
        }
        
        if editingEvent {
            form +++ Section()
                <<< ButtonRow() { row in
                row.title = "Delete Event"
            }
            .cellUpdate { cell, _ in
                cell.textLabel?.font = formFont
                cell.textLabel?.textColor = .red
            }
            .onCellSelection { _cell, _row in

                let alert = UIAlertController(title: "Delete Event?",
                                              message: "Are you sure you want to delete this event?",
                                              preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                    
                    self.startLoading()
                    
                    let eid = self.eventData["eid"] as! Int
                    API.deleteEvents(uid: defaults.integer(forKey: "uid"),
                                     token: defaults.string(forKey: "token")!,
                                     events: [eid], completionHandler: { response, data in
                        
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
                            self.backToEvents(title: "Event Deleted", message: "")
                            deleteEventImage(eid)
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
            view.textLabel?.font = formHeaderFont
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if editingEvent {
            navigationItem.title = "Edit Event"
        } else {
            navigationItem.title = "New Event"
        }
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItems = nil
        navigationItem.rightBarButtonItem = done
    }

    func editWith(_ data: [String:Any]) {
        editingEvent = true
        eventData = data
    }
    
    func backToEvents(title: String, message: String) {
        navigationController!.popToViewController(hostVC, animated: true)
        createAlert(title: title, message: message, view: hostVC)
        eventVC.clearTableview()
        eventVC.startRefreshControl()
        eventVC.refresh()
    }
    
    func uploadImage(data: Data, eid: Int, completion: @escaping () -> Void) {
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async(execute: {
                // Do something e.g. Update a progress bar.
            })
        }
        
        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    print("Response: \(task.response?.statusCode ?? 0)")
                } else {
                    completion()
                }
            })
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        
        transferUtility.uploadData(data, bucket: S3BUCKET,
                                   key: eventS3Key(eid),
            contentType: "image/jpeg", expression: expression, completionHandler: completionHandler).continueWith {
            (task) -> AnyObject? in
            
            if let error = task.error {
                print("Error: \(error.localizedDescription)")
            }
            
            if let _ = task.result {
                DispatchQueue.main.async {
                    // print("Upload Starting!")
                }
            }
            return nil;
        }
    }
    
    @objc func doneTapped() {
        tableView.endEditing(true)
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
                
                let eid = eventData["eid"] as! Int

                var imageURL: String? = nil
                if let _ = values["image"] as? UIImage {
                    imageURL = eventImageURL(eid)
                }
                
                API.updateEvent(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                                eid: eid, title: title, location: location, startDate: start,
                                endDate: end, description: description, image: imageURL) { response, data in
                                    
                    switch response {
                    case .NotConnected:
                        self.stopLoading()
                        createAlert(title: "Connection Error", message: "Unable to connect to the server", view: self)
                    case .Error:
                        self.stopLoading()
                        createAlert(title: "Error", message: data as! String, view: self)
                    case .InvalidSession:
                        self.stopLoading()
                        self.backToSignIn()
                    case .InternalError:
                        self.stopLoading()
                        createAlert(title: "Internal Server Error", message: "Something went wrong", view: self)
                    default:
                        if let image = values["image"] as? UIImage {
                            if let data = image.jpegData(compressionQuality: 0.6) {
                                self.uploadImage(data: data, eid: eid, completion: {
                                    updateEventImages(eid, data)
                                    self.backToEvents(title: "Event Updated", message: "")
                                })
                            } else {
                                self.backToEvents(title: "Event Updated", message: "")
                            }
                        } else {
                            // event had an image but update got rid of it
                            if let _ = self.eventData["image"] as? String {
                                deleteEventImage(eid)
                            }
                            self.backToEvents(title: "Event Updated", message: "")
                        }
                    }
                }
            } else {
                
                API.createEvent(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                                title: title, location: location, startDate: start, endDate: end,
                                description: description, image: nil) { response, data in
                                    
                    switch response {
                    case .NotConnected:
                        self.stopLoading()
                        createAlert(title: "Connection Error", message: "Unable to connect to the server",
                                    view: self)
                    case .Error:
                        self.stopLoading()
                        createAlert(title: "Error", message: data as! String, view: self)
                    case .InvalidSession:
                        self.stopLoading()
                        self.backToSignIn()
                    case .InternalError:
                        self.stopLoading()
                        createAlert(title: "Internal Server Error", message: "Something went wrong", view: self)
                    default:
                        let eid = (data as! [String:Any])["eid"] as! Int
                        if let image = values["image"] as? UIImage {
                            if let data = image.jpegData(compressionQuality: 0.6) {
                                self.uploadImage(data: data, eid: eid, completion: {
                                    
                                    updateEventImages(eid, data)
                                    
                                    API.updateEvent(uid: defaults.integer(forKey: "uid"),
                                                    token: defaults.string(forKey: "token")!, eid: eid, title: title,
                                                    location: location, startDate: start, endDate: end,
                                                    description: description, image: eventImageURL(eid),
                                                    completionHandler: { _, _ in
                                                        
                                        self.backToEvents(title: "Event Created", message: "")
                                    })
                                })
                            } else {
                                self.backToEvents(title: "Event Created", message: "")
                            }
                        } else {
                            self.backToEvents(title: "Event Created", message: "")
                        }
                    }
                }
            }
        }
    }
}
