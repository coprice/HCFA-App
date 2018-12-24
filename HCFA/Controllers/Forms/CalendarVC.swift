//
//  CalendarVC.swift
//  HCFA
//
//  Created by Collin Price on 1/18/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import EventKit
import Eureka

enum CalendarType {
    case Event
    case Course
    case Team
}

class CalendarVC: FormViewController {
    
    let eventStore = EKEventStore()
    var type: CalendarType!
    var data: [String:Any]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = lightColor
        navigationAccessoryView.barTintColor = redColor
        
        title = "Add to Calendar"
        
        var titleString: String!
        var startDate: Date!
        var endDate: Date!
        var repeatString: String! = "Every Week"
        var notes: String!
        if type == .Event {
            titleString = (data["title"] as! String)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            startDate = dateFormatter.date(from: (data["start"] as! String))!
            endDate = dateFormatter.date(from: (data["end"] as! String))!
            
            repeatString = "Never"
            notes = (data["description"] as! String)
            
        } else if type == .Course {
            titleString = "Bible Course"
            
            let (sd, ed) = getStartAndEndTimes(start: (data["start"] as! String), end: (data["end"] as! String))
            startDate = sd
            endDate = ed
            notes = (data["material"] as! String)
        
        } else if type == .Team {
            titleString = (data["name"] as! String) + " Meeting"
            
            let (sd, ed) = getStartAndEndTimes(start: (data["start"] as! String), end: (data["end"] as! String))
            startDate = sd
            endDate = ed
            notes = (data["description"] as! String)
        }
        
        form +++ Section("Name and Location")
        <<< NameRow() { row in
            row.placeholder = "Title"
            row.tag = "title"
            row.value = titleString
            row.cellUpdate { cell, row in
                cell.textLabel?.font = formFont
                cell.textField.font = formFont
            }
        }
            
        <<< NameRow() { row in
            row.placeholder = "Location"
            row.tag = "location"
            row.value = (data["location"] as! String)
            row.cellUpdate { cell, row in
                cell.textLabel?.font = formFont
                cell.textField.font = formFont
            }
        }
            
        +++ Section("Date and Time")
        <<< DateTimeInlineRow() { row in
            row.title = "Starts"
            row.tag = "start"
            row.value = startDate
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
            row.title = "Ends"
            row.tag = "end"
            row.value = endDate
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
            
        <<< PushRow<String>() { row in
            row.title = "Repeat"
            row.options = ["Never", "Every Day", "Every Week", "Every 2 weeks", "Every Month", "Every Year"]
            row.value = repeatString
            row.tag = "repeat"
        }
        .onPresent({ from, to in
            to.enableDeselection = false
            to.selectableRowCellSetup = { cell, _ in
                cell.textLabel?.font = formFont
            }
        })
        .cellUpdate({ cell, _ in
            cell.textLabel?.font = formFont
            cell.detailTextLabel?.font = formFont
            self.form.rowBy(tag: "endRepeat")?.evaluateHidden()
        })

        <<< PushRow<String>() { row in
            row.title = "End Repeat"
            row.options = ["Never", "Date"]
            row.value = "Never"
            row.tag = "endRepeat"
            row.hidden = Condition.function(["repeat"], { form in
                return (form.rowBy(tag: "repeat")?.value == "Never")
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
            row.tag = "endRepeatDate"
            row.value = Date()
            row.dateFormatter?.dateFormat = "MMM d, YYYY"
            row.hidden = Condition.function(["endRepeat"], { form in
                return form.rowBy(tag: "endRepeat")?.value == "Never"
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
            
        +++ Section("Alerts")
        <<< PushRow<String>(){ row in
            row.title = "Alert"
            row.options = ["None", "At time of event", "5 minutes before", "15 minutes before", "30 minutes before",
                           "1 hour before", "2 hours before", "1 day before", "2 days before", "1 week before"]
            row.value = "None"
            row.tag = "alert"
        }
        .onPresent({ from, to in
            to.enableDeselection = false
            to.selectableRowCellUpdate = { cell, row in
                cell.textLabel?.font = formFont
            }
        })
        .cellUpdate({ cell, _ in
            cell.textLabel?.font = formFont
            cell.detailTextLabel?.font = formFont
            self.form.rowBy(tag: "alert2")?.evaluateHidden()
        })
            
        <<< PushRow<String>(){ row in
            row.title = "Second Alert"
            row.options = ["None", "At time of event", "5 minutes before", "15 minutes before", "30 minutes before",
                           "1 hour before", "2 hours before", "1 day before", "2 days before", "1 week before"]
            row.value = "None"
            row.tag = "alert2"
            row.hidden = Condition.function(["alert"], { form in
                return (form.rowBy(tag: "alert")?.value == "None")
            })
        }
        .onPresent({ from, to in
            to.enableDeselection = false
            to.selectableRowCellUpdate = { cell, row in
                cell.textLabel?.font = formFont
            }
        })
        .cellUpdate({ cell, _ in
            cell.textLabel?.font = formFont
            cell.detailTextLabel?.font = formFont
            self.form.rowBy(tag: "alert2")?.evaluateHidden()
        })
            
        +++ Section("Description")
        <<< TextAreaRow() { row in
            row.placeholder = "Notes"
            row.tag = "notes"
            row.value = notes
            row.cellUpdate { cell, row in
                cell.placeholderLabel?.font = formFont
                cell.textView.font = formFont
            }
        }
        
        +++ Section("Calendar")
        <<< PushRow<String>(){ row in
            row.title = "Calendar"
            row.options = Array(Set(eventStore.calendars(for: .event).map({ $0.title })))
            
            if let calendar = getCalendar(withTitle: defaults.string(forKey: "calendar")) {
                row.value = calendar.title
            } else {
                row.value = eventStore.defaultCalendarForNewEvents?.title
            }
            row.tag = "calendar"
        }
        .onPresent({ from, to in
            to.enableDeselection = false
            to.selectableRowCellUpdate = { cell, row in
                cell.textLabel?.font = formFont
            }
        })
        .cellUpdate({ cell, _ in
            cell.textLabel?.font = formFont
            cell.detailTextLabel?.font = formFont
            self.form.rowBy(tag: "endRepeat")?.evaluateHidden()
        })
        .onChange({ row in
            if let title = row.value {
                defaults.set(title, forKey: "calendar")
            }
        })
        
        +++ Section()
        <<< ButtonRow() { row in
            row.title = "Add to Calendar"
            row.cellUpdate { cell, _ in
                cell.textLabel?.font = formFont
                cell.textLabel?.textColor = redColor
            }
        }
        .onCellSelection({ _cell, _row in
            
            let hostVC = self.navigationController!.viewControllers.first!
            self.navigationController!.popToViewController(hostVC, animated: true)
            
            self.eventStore.requestAccess(to: .event) { (granted, error) in

                if !granted {
                    createAlert(title: "Access not granted",
                                message: "Go to Settings > HCFA > Turn on Calendars",
                                view: hostVC)
                } else if error == nil {

                    let values = self.form.values()
                    let event = EKEvent(eventStore: self.eventStore)
                    
                    event.title = values["title"] as? String
                    event.startDate = values["start"] as? Date
                    event.endDate = values["end"] as? Date
                    event.location = values["location"] as? String
                    event.notes = values["notes"] as? String
                    event.alarms = self.getAlarmsFor(event.startDate)
                    
                    if let calendar = self.getCalendar(withTitle: values["calendar"] as? String) {
                        event.calendar = calendar
                    } else {
                        event.calendar = self.eventStore.defaultCalendarForNewEvents
                    }
                
                    let repeatString = values["repeat"] as! String
                    if repeatString != "Never" {
                        let frequency = self.getRecurrenceFrequency(repeatString)
                        let interval = self.getInterval(repeatString)
                        
                        var endRepeat: EKRecurrenceEnd? = nil
                        
                        if values["endRepeat"] as? String == "Date" {
                            endRepeat = EKRecurrenceEnd(end: (values["endRepeatDate"] as! Date))
                        }
                        
                        event.addRecurrenceRule(EKRecurrenceRule(recurrenceWith: frequency, interval: interval,
                                                                 end: endRepeat))
                    }
                    
                    do {
                        try self.eventStore.save(event, span: .thisEvent)
                    } catch let error as NSError {
                        createAlert(title: "Error: \(String(describing: error))", message: "Failed to save event",
                                    view: hostVC)
                    }
                    if self.type == .Event {
                        createAlert(title: "Success!", message: "Event is now in your calendar", view: hostVC)
                    } else if self.type == .Course {
                        createAlert(title: "Success!", message: "This bible course is now in your calendar",
                                    view: hostVC)
                    } else if self.type == .Team {
                        createAlert(title: "Success!", message: "This ministry team meeting is now in your calendar",
                                    view: hostVC)
                    }

                } else {
                    createAlert(title: "Error: \(String(describing: error))", message: "Failed to create event",
                                view: hostVC)
                }
            }
        })
        animateScroll = true
    }
    
    func tableView(_: UITableView, willDisplayHeaderView view: UIView, forSection: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.font = formHeaderFont
        }
    }
}

// HELPERS
extension CalendarVC {
    
    func getCalendar(withTitle title: String?) -> EKCalendar? {
        guard let title = title else { return nil }
        
        for cal in self.eventStore.calendars(for: .event) {
            if cal.title == title {
                return cal
            }
        }
        return nil
    }
    
    func getStartAndEndTimes(start: String, end: String) -> (Date, Date) {
        let gregorian = Calendar(identifier: .gregorian)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mma"
        
        let startTime = dateFormatter.date(from: start)!
        let endTime = dateFormatter.date(from: end)!
        
        let nextMeeting = get(.Next, (data["day"] as! String))
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: nextMeeting)
        
        components.hour = Calendar.current.component(.hour, from: startTime)
        components.minute = Calendar.current.component(.minute, from: startTime)
        components.second = Calendar.current.component(.second, from: startTime)
        let startDate = gregorian.date(from: components)!
        
        components.hour = Calendar.current.component(.hour, from: endTime)
        components.minute = Calendar.current.component(.minute, from: endTime)
        let endDate = gregorian.date(from: components)!
        
        return (startDate, endDate)
    }
    
    func getAlarmsFor(_ startDate: Date) -> [EKAlarm] {
        let values = form.values()
        
        let first = values["alert"] as! String
        if first == "None" { return [] }
        let firstAlert = convertStringToAlarm(first, startDate)
        
        let second = values["alert2"] as! String
        if second == "None" { return [firstAlert] }
        let secondAlert = convertStringToAlarm(second, startDate)
        
        return [firstAlert, secondAlert]
    }
    
    func convertStringToAlarm(_ str: String, _ startDate: Date) -> EKAlarm {
        
        let minute: TimeInterval = 60.0
        let hour: TimeInterval = 60.0 * minute
        let day: TimeInterval = 24 * hour
        
        switch str {
        case "At time of event": return EKAlarm(absoluteDate: startDate)
        case "5 minutes before": return EKAlarm(absoluteDate: Date(timeInterval: -5*minute, since: startDate))
        case "15 minutes before": return EKAlarm(absoluteDate: Date(timeInterval: -15*minute, since: startDate))
        case "30 minutes before": return EKAlarm(absoluteDate: Date(timeInterval: -30*minute, since: startDate))
        case "1 hour before": return EKAlarm(absoluteDate: Date(timeInterval: -hour, since: startDate))
        case "2 hours before": return EKAlarm(absoluteDate: Date(timeInterval: -2*hour, since: startDate))
        case "1 day before": return EKAlarm(absoluteDate: Date(timeInterval: -day, since: startDate))
        case "2 days before": return EKAlarm(absoluteDate: Date(timeInterval: -2*day, since: startDate))
        default: return EKAlarm(absoluteDate: Date(timeInterval: -7*day, since: startDate))
        }
    }
    
    func getInterval(_ fromString: String) -> Int {
        if fromString == "Every 2 Weeks" {
            return 2
        }
        return 1
    }
    
    func getRecurrenceFrequency(_ fromString: String) -> EKRecurrenceFrequency {
        switch fromString {
            case "Every Week": return .weekly
            case "Every 2 Weeks": return .weekly
            case "Every Month": return .monthly
            case "Every Year": return .yearly
            default: return .daily
        }
    }
}
