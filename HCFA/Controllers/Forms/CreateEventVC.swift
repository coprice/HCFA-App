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

let days = [("Sunday", 1), ("Monday", 2), ("Tuesday", 3), ("Wednesday", 4),
            ("Thursday", 5), ("Friday", 6), ("Saturday", 7)]


class CreateEventVC: CreateTemplateVC {
    
    var done: UIBarButtonItem!
    var eventVC: EventVC!
    var eventData: [String:Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        eventVC = (hostVC.contentViewControllers[Tabs.Events] as! EventVC)
        
        let today = Calendar.current.date(bySetting: .minute, value: 0, of: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var startDate: Date!
        var endDate: Date!
        if let start = eventData["start"] as? String, let end = eventData["end"] as? String {
            if let o_start = eventData["original_start"] as? String,
                let o_end = eventData["original_end"] as? String {
                
                startDate = dateFormatter.date(from: o_start)!
                endDate = dateFormatter.date(from: o_end)!
            } else {
                startDate = dateFormatter.date(from: start)!
                endDate = dateFormatter.date(from: end)!
            }
        }
        
        form +++ Section("General")
            <<< NameRow { row in
            row.title = "Title"
            row.placeholder = "Title"
            row.tag = "title"
            if let title = eventData["title"] as? String {
                row.value = title
            }
            row.cellUpdate { cell, _ in
                cell.textLabel?.font = formFont
                cell.textField.font = formFont
            }
            row.onCellHighlightChanged { cell, row in
                cell.textLabel?.textColor = redColor
            }
        }
            
        <<< NameRow { row in
            row.title = "Location"
            row.placeholder = "Location"
            row.tag = "location"
            if let loc = eventData["location"] as? String {
                if let o_loc = eventData["original_location"] as? String {
                    row.value = o_loc
                } else {
                    row.value = loc
                }
            }
            row.cellUpdate { cell, row in
                cell.textLabel?.font = formFont
                cell.textField.font = formFont
            }
            row.onCellHighlightChanged { cell, row in
                cell.textLabel?.textColor = redColor
            }
        }
        
        <<< PushRow<String> { row in
            row.title = "Repeat"
            row.options = ["Never", "Every Day", "Every Week", "Every 2 Weeks", "Every Month", "Every Year"]
            row.tag = "repeat"
            if let r = eventData["repeat"] as? String {
                row.value = r
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
        .onChange({ row in
            if let multRow = self.form.rowBy(tag: "multiple") as? SwitchRow {
                if let multiple = multRow.value {
                    if multiple && row.value != "Every Week" && row.value != "Every 2 Weeks" {
                        multRow.value = false
                        multRow.updateCell()
                    }
                }
            }
        })
            
        <<< PushRow<String> { row in
            row.title = "End Repeat"
            row.options = ["Never", "Date"]
            if eventData["end_repeat"] != nil {
                row.value = "Date"
            } else {
                row.value = "Never"
            }
            row.tag = "end_repeat"
            row.hidden = Condition.function(["repeat"], { form in
                return form.rowBy(tag: "repeat")?.value == "Never"
            })
        }
        .onPresent({ from, to in
            to.enableDeselection = false
            to.selectableRowCellSetup = { cell, row in
                cell.textLabel?.font = formFont
            }
        })
        .cellUpdate({ cell, row in
            cell.textLabel?.font = formFont
            cell.detailTextLabel?.font = formFont
        })
        
        <<< DateInlineRow { row in
            row.title = "End Repeat Date"
            row.tag = "end_repeat_date"
            if let erd = eventData["end_repeat"] as? String {
                dateFormatter.dateFormat = "yyyy-MM-dd"
                row.value = dateFormatter.date(from: erd)
            } else {
                row.value = today
            }
            row.dateFormatter?.dateFormat = "MMM dd, YYYY"
            row.hidden = Condition.function(["end_repeat"], { form in
                return form.rowBy(tag: "end_repeat")?.value == "Never"
            })
            
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
            }
        }
            
        <<< SwitchRow { row in
            row.title = "Multiple Days"
            row.tag = "multiple"
            row.value = eventData["repeat_days"] != nil
            row.hidden = Condition.function(["repeat"], { form in
                if let value = form.rowBy(tag: "repeat")?.baseValue as? String {
                    return !value.contains("Week")
                }
                return true
            })

            row.cellSetup  { cell, _ in
                cell.textLabel?.font = formFont
                cell.switchControl.onTintColor = redColor
            }
        }
            
        <<< DateTimeInlineRow { row in
            row.title = "Start"
            row.tag = "start"
            row.minuteInterval = 5
            row.dateFormatter?.dateFormat = "h:mm a, MMM d, YYYY"
            if eventData["start"] != nil {
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
                
                if let endDTRow = self.form.rowBy(tag: "end") as? DateTimeInlineRow {
                    let endRow = endDTRow.baseCell.baseRow
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
        }
            
        <<< DateTimeInlineRow { row in
            row.title = "End"
            row.tag = "end"
            row.minuteInterval = 5
            row.dateFormatter?.dateFormat = "h:mm a, MMM d, YYYY"
            if eventData["end"] != nil {
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
                
                if let startDTRow = self.form.rowBy(tag: "start") as? DateTimeInlineRow {
                    let startRow = startDTRow.baseCell.baseRow
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
        }
            
        let repeatSection = Section("Repeat Days") {
            $0.tag = "repeat_days"
            $0.hidden = Condition.function(["multiple", "repeat"], { form in
                return !(form.rowBy(tag: "multiple")?.baseValue as? Bool ?? false)
            })
        }
        
        for (day, tag) in days {
            let dayTag = String(tag)
            
            repeatSection <<< CheckRow { row in
                row.title = day
                row.tag = dayTag
                if let repeatDays = eventData["repeat_days"] as? [String:Any] {
                    row.value = repeatDays[dayTag] != nil
                } else {
                    row.value = false
                }
                row.cellUpdate { cell, row in
                    cell.textLabel?.font = formFont
                }
                row.onChange({ row in
                    if !(row.value ?? false) {
                        if let locSwitchRow = self.form.rowBy(tag: "\(dayTag)_location_bool") as? SwitchRow,
                            let timeSwitchRow = self.form.rowBy(tag: "\(dayTag)_time_bool") as? SwitchRow {
                            
                            if !(locSwitchRow.value ?? false) {
                                locSwitchRow.value = true
                                locSwitchRow.updateCell()
                                
                            }
                            
                            if !(timeSwitchRow.value ?? false) {
                                timeSwitchRow.value = true
                                timeSwitchRow.updateCell()
                            }
                        }
                    }
                })
            }
            
            <<< SwitchRow { row in
                row.title = "Use General Location"
                row.tag = "\(dayTag)_location_bool"
                
                if let repeatDays = eventData["repeat_days"] as? [String:Any] {
                    if let dayDict = repeatDays[dayTag] as? [String:Any] {
                        row.value = dayDict["location"] == nil
                    } else {
                        row.value = true
                    }
                } else {
                    row.value = true
                }
                row.hidden = Condition.function([dayTag], { form in
                    return !(form.rowBy(tag: dayTag)?.baseValue as? Bool ?? false)
                })
                row.cellSetup  { cell, _ in
                    cell.textLabel?.font = formFont
                    cell.backgroundColor = lightColor
                    cell.switchControl.onTintColor = redColor
                }
            }
            
            <<< NameRow { row in
                row.title = "Location"
                row.tag = "\(dayTag)_location"
                row.baseCell.backgroundColor = lightColor
                if let repeatDays = eventData["repeat_days"] as? [String:Any] {
                    if let dayDict = repeatDays[dayTag] as? [String:Any] {
                        row.value = dayDict["location"] as? String
                    }
                }
                row.hidden = Condition.function(["\(dayTag)_location_bool"], { form in
                    return form.rowBy(tag: "\(dayTag)_location_bool")?.baseValue as? Bool ?? true
                })
                row.cellUpdate { cell, _ in
                    cell.textLabel?.font = formFont
                    cell.textField.font = formFont
                }
                row.onCellHighlightChanged { cell, row in
                    cell.textLabel?.textColor = redColor
                }
            }
            
            <<< SwitchRow { row in
                row.title = "Use General Time"
                row.tag = "\(dayTag)_time_bool"
                if let repeatDays = eventData["repeat_days"] as? [String:Any] {
                    if let dayDict = repeatDays[dayTag] as? [String:Any] {
                        row.value = dayDict["start"] == nil
                    } else {
                        row.value = true
                    }
                } else {
                    row.value = true
                }
                row.hidden = Condition.function([dayTag], { form in
                    return !(form.rowBy(tag: dayTag)?.baseValue as? Bool ?? false)
                })
                row.cellSetup  { cell, _ in
                    cell.textLabel?.font = formFont
                    cell.backgroundColor = lightColor
                    cell.switchControl.onTintColor = redColor
                }
            }
            
            <<< TimeInlineRow { row in
                row.title = "Start"
                row.tag = "\(dayTag)_start_time"
                row.minuteInterval = 5
                row.dateFormatter?.dateFormat = "h:mm a"
                row.hidden = Condition.function(["\(dayTag)_time_bool"], { form in
                    return form.rowBy(tag: "\(dayTag)_time_bool")?.baseValue as? Bool ?? true
                })
                
                var flag = false
                if let repeatDays = eventData["repeat_days"] as? [String:Any] {
                    if let dayDict = repeatDays[dayTag] as? [String:Any] {
                        if let start = dayDict["start"] as? String {
                            dateFormatter.dateFormat = "h:mm a"
                            row.value = dateFormatter.date(from: start)
                            flag = true
                        }
                    }
                }
                if flag {
                    row.value = startDate
                }
                
                row.cellSetup { cell, row in
                    cell.textLabel?.font = formFont
                    cell.backgroundColor = lightColor
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
                    
                    if let endTRow = self.form.rowBy(tag: "\(dayTag)_end_time") as? TimeInlineRow {
                        let endRow = endTRow.baseCell.baseRow
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
            }
            
            <<< TimeInlineRow { row in
                row.title = "End"
                row.tag = "\(dayTag)_end_time"
                row.minuteInterval = 5
                row.dateFormatter?.dateFormat = "h:mm a"
                row.hidden = Condition.function(["\(dayTag)_time_bool"], { form in
                    return form.rowBy(tag: "\(dayTag)_time_bool")?.baseValue as? Bool ?? true
                })
                var flag = false
                if let repeatDays = eventData["repeat_days"] as? [String:Any] {
                    if let dayDict = repeatDays[dayTag] as? [String:Any] {
                        if let end = dayDict["end"] as? String {
                            dateFormatter.dateFormat = "h:mm a"
                            row.value = dateFormatter.date(from: end)
                            flag = true
                        }
                    }
                }
                if flag {
                    row.value = endDate
                }
                row.cellSetup { cell, row in
                    cell.textLabel?.font = formFont
                    cell.backgroundColor = lightColor
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
                    
                    if let startTRow = self.form.rowBy(tag: "\(dayTag)_start_time") as? TimeInlineRow {
                        let startRow = startTRow.baseCell.baseRow
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
            }
        }
        
        form +++ repeatSection
        
        form +++ Section("Description")
            <<< TextAreaRow() { row in
            row.title = "Description"
            row.placeholder = "Description"
            row.tag = "description"
            if let description = eventData["description"] as? String {
                row.value = description
            }
            row.cellUpdate { cell, row in
                cell.placeholderLabel?.font = formFont
                cell.textView.font = formFont
            }
        }
        
        +++ Section("Optional")
            <<< ImageRow { row in
            row.title = "Image"
            row.sourceTypes = [.PhotoLibrary, .Camera]
            row.clearAction = .yes(style: .default)
            row.tag = "image"
            if eventData["image"] != nil {
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
        
        if eventData.count != 0 {
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
        
        if eventData.count != 0 {
            navigationItem.title = "Edit Event"
        } else {
            navigationItem.title = "New Event"
        }
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItems = nil
        navigationItem.rightBarButtonItem = done
    }

    func editWith(_ data: [String:Any]) {
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
    
    func checkDates(start: Date, end: Date) -> String? {
        if end < start {
            return "An event cannot end before it starts!"
        } else if end == start {
            return "An event cannot start when it ends!"
        }
        return nil
    }
    
    func wtf() {
        createAlert(title: "Whaaaaaaaaat??", message: "This should never happen", view: self)
    }
    
    @objc func doneTapped() {
        tableView.endEditing(true)
        
        let values = form.values()
        
        guard let title = values["title"] as? String else {
            return createAlert(title: "Title Empty", message: "Enter an event title", view: self)
        }
        
        guard let location = values["location"] as? String else {
            return createAlert(title: "Location Empty", message: "Enter a location", view: self)
        }
        
        guard let startDate = values["start"] as? Date, let endDate = values["end"] as? Date else {
            return wtf()
        }
        
        if let errMsg = checkDates(start: startDate, end: endDate) {
            return createAlert(title: "Invalid Date/Times", message: errMsg, view: self)
        }
        
        guard let repeatStringVal = values["repeat"] as? String else { return wtf() }
        var repeatString: String? = nil
        var endRepeat: String? = nil
        var multiple: Bool? = nil
        let dateFormatter = DateFormatter()
        
        if repeatStringVal != "Never" {
            repeatString = repeatStringVal
            
            guard let endRepeatVal = values["end_repeat"] as? String else { return wtf() }
            
            if endRepeatVal == "Date" {
                guard let endRepeatDate = values["end_repeat_date"] as? Date else { return wtf() }
                
                if endRepeatDate <= Date() {
                    return createAlert(title: "Invalid End Repeat",
                                       message: "Event cannot stop repeating before it starts", view: self)
                }
                
                dateFormatter.dateFormat = "yyyy-MM-dd"
                endRepeat = dateFormatter.string(from: endRepeatDate)
            }
            
            if repeatStringVal.contains("Week") {
                guard let m = values["multiple"] as? Bool else { return wtf() }
                multiple = m
            }
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let start = dateFormatter.string(from: startDate)
        let end = dateFormatter.string(from: endDate)
        
        var repeatDays: [String:Any]? = nil
        
        if multiple ?? false {
            repeatDays = [:]
            
            for (day, tag) in days {
                if values[String(tag)] as? Bool ?? false {
                    var currentDay: [String:String] = [:]
                    
                    if !(values["\(tag)_location_bool"] as? Bool ?? true) {
                        guard let location = values["\(tag)_location"] as? String else {
                            return createAlert(title: "\(day) Location Empty",
                                               message: "Enter a location for \(day)", view: self)
                        }
                        currentDay["location"] = location
                    }
                    
                    if !(values["\(tag)_time_bool"] as? Bool ?? true) {
                        guard let startTime = values["\(tag)_start_time"] as? Date,
                            let endTime = values["\(tag)_end_time"] as? Date else {
                            return createAlert(title: "Whaaaaaaaaat??", message: "This should never happen",
                                               view: self)
                        }
                        
                        if let errMsg = checkDates(start: startTime, end: endTime) {
                            return createAlert(title: "Invalid Dates", message: errMsg, view: self)
                        }
                        
                        dateFormatter.dateFormat = "h:mm a"
                        currentDay["start"] = dateFormatter.string(from: startTime)
                        currentDay["end"] = dateFormatter.string(from: endTime)
                    }
                    
                    repeatDays![String(tag)] = currentDay
                }
            }
            
            if repeatDays!.count < 2 {
                return createAlert(title: "Too Few Days",
                                   message: "You must have at least two days to have multiple days",
                                   view: self)
            }
            
            let weekday = Calendar.current.component(.weekday, from: startDate)
            if repeatDays![String(weekday)] == nil {
                let day = dateFormatter.weekdaySymbols[weekday - 1].lowercased()
                return createAlert(title: "Multi-Day Error",
                                   message: "The event starts on a \(day), but there is no \(day) in the specified repeat days",
                                   view: self)
            }
        }
        
        guard let description = values["description"] as? String else {
            return createAlert(title: "Description Empty", message: "Enter a description", view: self)
        }
        
        startLoading()
        
        if let eid = eventData["eid"] as? Int {
            var imageURL: String? = nil
            if let _ = values["image"] as? UIImage {
                imageURL = eventImageURL(eid)
            }
            
            API.updateEvent(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                            eid: eid, title: title, location: location, startDate: start, endDate: end,
                            description: description, repeatString: repeatString, endRepeat: endRepeat,
                            repeatDays: repeatDays, image: imageURL) { response, data in
                                
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
                        if self.eventData["image"] != nil {
                            deleteEventImage(eid)
                        }
                        self.backToEvents(title: "Event Updated", message: "")
                    }
                }
            }
        } else {

            API.createEvent(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                            title: title, location: location, startDate: start, endDate: end,
                            description: description, repeatString: repeatString, endRepeat: endRepeat,
                            repeatDays: repeatDays, image: nil) { response, data in
                
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
                                                description: description, repeatString: repeatString,
                                                endRepeat: endRepeat, repeatDays: repeatDays,
                                                image: eventImageURL(eid), completionHandler: { _, _ in
                                                    
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
