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
            notes = data["material"] as! String
        
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
                    cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                    cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                }
            }
            <<< NameRow() { row in
                row.placeholder = "Location"
                row.tag = "location"
                row.value = (data["location"] as! String)
                row.cellUpdate { cell, row in
                    cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                    cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                }
            }
            
            +++ Section("Date and Time")
            <<< DateTimeInlineRow() { row in
                row.title = "Starts"
                row.tag = "start"
                row.value = startDate
                row.cellUpdate { cell, row in
                    cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                    cell.detailTextLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
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
                row.title = "Ends"
                row.tag = "end"
                row.value = endDate
                row.cellUpdate { cell, row in
                    cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                    cell.detailTextLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
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
            <<< PushRow<String>() { row in
                row.title = "Repeat"
                row.options = ["Never", "Every Day", "Every Week", "Every 2 weeks", "Every Month", "Every Year"]
                row.value = repeatString
                row.tag = "repeat"
            }
            .onPresent({ from, to in
                to.enableDeselection = false
            })
            .cellUpdate({ cell, _ in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.detailTextLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
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
            })
            .cellUpdate({ cell, row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.detailTextLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            })
            <<< DatePickerRow() { row in
                row.tag = "endRepeatDate"
                row.validationOptions = .validatesOnChange
                row.hidden = Condition.function(["endRepeat"], { form in
                    return (form.rowBy(tag: "endRepeat")?.value == "Never")
                })
            }
            
        +++ Section("Alerts")
        <<< PushRow<String>(){ row in
            row.title = "Alert"
            row.options = ["None", "At time of event", "5 minutes before", "15 minutes before", "30 minutes before",
                           "1 hour before", "2 hours before", "1 day before", "2 days before", "1 week before"]
            row.value = "None"
            row.tag = "alert"
        }
        .cellUpdate({ cell, _ in
            cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            cell.detailTextLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
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
        .cellUpdate({ cell, _ in
            cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            cell.detailTextLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            self.form.rowBy(tag: "alert2")?.evaluateHidden()
        })
            
        +++ Section("Description")
        <<< TextAreaRow() { row in
            row.placeholder = "Notes"
            row.tag = "notes"
            row.value = notes
            row.cellUpdate { cell, row in
                cell.placeholderLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textView.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            }
        }
        
        +++ Section("Calendar")
        <<< PushRow<String>(){ row in
            row.title = "Calendar"
            row.options = eventStore.calendars(for: .event).map({$0.title})
            row.value = eventStore.defaultCalendarForNewEvents?.title
            row.tag = "calendar"
        }
        
        +++ Section()
        <<< ButtonRow() { row in
            row.title = "Add to Calendar"
            row.cellUpdate { cell, _ in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textLabel?.textColor = redColor
            }
        }
        .onCellSelection({ _cell, _row in
            
            self.navigationController!.popViewController(animated: true)
            
            self.eventStore.requestAccess(to: .event) { (granted, error) in

                if !granted {
                    createAlert(title: "Access not granted",
                                message: "Go to Settings > HCFA > toggle Calendars on",
                                view: self.navigationController!.viewControllers.last!)
                } else if error == nil {

                    let values = self.form.values()
                    let event = EKEvent(eventStore: self.eventStore)
                    
                    event.title = values["title"] as! String
                    event.startDate = values["start"] as! Date
                    event.endDate = values["end"] as! Date
                    event.location = (values["location"] as! String)
                    event.notes = (values["notes"] as! String)
                    event.alarms = self.getAlarmsFor(event.startDate)
                    
                    var calendar: EKCalendar? = nil
                    for cal in self.eventStore.calendars(for: .event) {
                        if cal.title == (values["calendar"] as! String) {
                            calendar = cal
                        }
                    }
                    
                    if let calendar = calendar {
                        event.calendar = calendar
                        print("using calendar \(calendar.title)")
                    } else {
                        event.calendar = self.eventStore.defaultCalendarForNewEvents
                    }
                
                    let repeatString = values["repeat"] as! String
                    if repeatString != "Never" {
                        let frequency = self.getRecurrenceFrequency(repeatString)
                        let interval = self.getInterval(repeatString)
                        
                        var endRepeat: EKRecurrenceEnd? = nil
                        
                        if (values["endRepeat"] as! String) == "Date" {
                            endRepeat = EKRecurrenceEnd(end: (values["endRepeatDate"] as! Date))
                        }
                        
                        event.addRecurrenceRule(EKRecurrenceRule(recurrenceWith: frequency, interval: interval,
                                                                 end: endRepeat))
                    }
                    
                    do {
                        try self.eventStore.save(event, span: .thisEvent)
                    } catch let error as NSError {
                        createAlert(title: "Error: \(String(describing: error))", message: "Failed to save event",
                                    view: self.navigationController!.viewControllers.last!)
                    }
                    if self.type == .Event {
                        createAlert(title: "Success!", message: "Event is now in your calendar",
                                    view: self.navigationController!.viewControllers.last!)
                    } else if self.type == .Course {
                        createAlert(title: "Success!", message: "This bible course is now in your calendar",
                                    view: self.navigationController!.viewControllers.last!)
                    } else if self.type == .Team {
                        createAlert(title: "Success!", message: "This ministry team meeting is now in your calendar",
                                    view: self.navigationController!.viewControllers.last!)
                    }

                } else {
                    createAlert(title: "Error: \(String(describing: error))", message: "Failed to create event",
                                view: self.navigationController!.viewControllers.last!)
                }
            }
        })
        animateScroll = true
    }
}

// HELPERS
extension CalendarVC {
    
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
