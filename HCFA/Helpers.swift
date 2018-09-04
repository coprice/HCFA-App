//
//  Helpers.swift
//  HCFA
//
//  Created by Collin Price on 12/31/17.
//  Copyright © 2017 Collin Price. All rights reserved.
//

import UIKit
import Foundation

struct Tabs {
    static let Profile = 0
    static let Events = 1
    static let BibleCourses = 2
    static let MinistryTeams = 3
    static let Settings = 4
}

enum Gender {
    case Both
    case Men
    case Women
}

enum Year {
    case All
    case Freshman
    case Sophomore
    case Junior
    case Senior
}

let IS_IPHONE_X = UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436

// -- UserDefaults --

let defaults = UserDefaults.standard

func resetDefaults() {
    defaults.set(0, forKey: "uid")
    defaults.set("", forKey: "first")
    defaults.set("", forKey: "last")
    defaults.set("", forKey: "email")
    defaults.set(false, forKey: "admin")
    defaults.set(false, forKey: "leader")
    defaults.set("", forKey: "token")
    defaults.set([], forKey: "courses")
    defaults.set(nil, forKey: "image")
    defaults.set(nil, forKey: "userAPNToken")
    defaults.set(true, forKey: "event_ntf")
    defaults.set(true, forKey: "course_ntf")
    defaults.set(true, forKey: "team_ntf")
    defaults.set(nil, forKey: "calendar")
}

// -- Colors --

let redColor = UIColor(red: 220/255, green: 0/255, blue: 19/255, alpha: 1)
let highlightColor = UIColor(red: 237/255, green: 127/255, blue: 137/255, alpha: 1)
let lightColor = UIColor(red: 248/255, green: 250/255, blue: 253/255, alpha: 1)
let sideMenuColor = UIColor(red: 255/255, green: 248/255, blue: 248/255, alpha: 1.0)
let sideMenuHighlightColor = UIColor(red: 240/255, green: 220/255, blue: 220/255, alpha: 1.0)
let barHighlightColor = UIColor(red: 197/255, green: 104/255, blue: 122/255, alpha: 1)
let secondaryCellColor = UIColor(red: 43/255, green: 50/255, blue: 53/255, alpha: 1.0)
let tertiaryCellColor = UIColor(red: 128/255, green: 130/255, blue: 133/255, alpha: 1.0)

// -- Fonts --

let formFont = UIFont(name: "Montserrat-Light", size: UIScreen.main.bounds.width*0.04) ??
    UIFont.systemFont(ofSize: UIScreen.main.bounds.width*0.04)
let formHeaderFont = UIFont(name: "Montserrat-Regular", size: UIScreen.main.bounds.width*0.04) ??
    UIFont.systemFont(ofSize: UIScreen.main.bounds.width*0.04)
let titleFont =  UIFont(name: "Montserrat-Medium", size: UIScreen.main.bounds.width*0.068) ??
    UIFont.systemFont(ofSize: UIScreen.main.bounds.width*0.068)
let cellFont = UIFont(name: "Montserrat-Light", size: UIScreen.main.bounds.width*0.043) ??
    UIFont.systemFont(ofSize: UIScreen.main.bounds.width*0.043)
let displayFont = UIFont(name: "Montserrat-Regular", size: UIScreen.main.bounds.width*0.05) ??
    UIFont.systemFont(ofSize: UIScreen.main.bounds.width*0.05)
let memberFont = UIFont(name: "Montserrat-Regular", size: UIScreen.main.bounds.width*0.04) ??
    UIFont.systemFont(ofSize: UIScreen.main.bounds.width*0.04)
let blockTextFont = UIFont(name: "OpenSans-Light", size: UIScreen.main.bounds.width*0.05) ??
    UIFont.systemFont(ofSize: UIScreen.main.bounds.width*0.05)

let TOGGLE_WIDTH = UIScreen.main.bounds.width*0.275
let TOGGLE_HEIGHT = UIScreen.main.bounds.height*0.06

// -- Alerts --

func createAlert(title: String, message: String, view: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    view.present(alert, animated: true, completion: nil)
}

func createAlert(title: String, message: String, view: UIViewController, completion: @escaping () -> Void) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    view.present(alert, animated: true, completion: completion)
}

// -- Form checks

func isSecure(text: String) -> Bool {
    let lengthCheck = text.count > 7
    
    let capitalLetterRegEx  = ".*[A-Z]+.*"
    let texttest1 = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
    let containsCapital = texttest1.evaluate(with: text)
    
    let numberRegEx  = ".*[0-9]+.*"
    let texttest2 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
    let containsNumber = texttest2.evaluate(with: text)
    
    return lengthCheck && containsCapital && containsNumber
}

func isValidEmail(testStr:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
}

// -- Text manipulation

func createUnderlineLabel(frame: CGRect, text: String, font: UIFont, color: UIColor,
                          alignment: NSTextAlignment) -> UILabel {
    let label = UILabel(frame: frame)
    let underline = NSMutableAttributedString(string: text)
    underline.addAttribute(NSAttributedStringKey.underlineStyle, value: 1, range: NSMakeRange(0, underline.length))
    label.attributedText = underline
    label.font = font
    label.textAlignment = alignment
    label.textColor = color
    label.baselineAdjustment = .alignCenters
    return label
}

func createLabel(frame: CGRect, text: String, font: UIFont, color: UIColor, alignment: NSTextAlignment,
                 fitToWidth: Bool) -> UILabel {
    let label = UILabel(frame: frame)
    label.text = text
    label.font = font
    label.textAlignment = alignment
    label.textColor = color
    label.baselineAdjustment = .alignCenters
    label.adjustsFontSizeToFitWidth = fitToWidth
    return label
}

// -- Button images --

func squareImage(color: UIColor, width: CGFloat, height: CGFloat) -> UIImage? {
    UIGraphicsBeginImageContext(CGSize(width: width, height: height))
    let context = UIGraphicsGetCurrentContext()!
    context.setFillColor(color.cgColor)
    context.fill(CGRect(x: 0.0, y: 0.0, width: width, height: height))
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}

func roundedImage(color: UIColor, width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> UIImage? {
    UIGraphicsBeginImageContext(CGSize(width: width, height: height))
    let context = UIGraphicsGetCurrentContext()!
    context.setFillColor(color.cgColor)
    context.addPath(UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: width, height: height),
                                 cornerRadius: cornerRadius).cgPath)
    context.fillPath()
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}

// -- Loading images --

func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        completion(data, response, error)
    }.resume()
}

func downloadImage(url: URL, view: UIImageView) {
    getDataFromUrl(url: url) { data, response, error in
        guard let data = data, error == nil else { return }
        DispatchQueue.main.async() {
            view.image = UIImage(data: data)
        }
    }
}

func downloadImage(url: URL, button: UIButton) {
    getDataFromUrl(url: url) { data, response, error in
        guard let data = data, error == nil else { return }
        DispatchQueue.main.async() {
            button.setImage(UIImage(data: data), for: .normal)
        }
    }
}

//  -- Date manipulation --

func getWeekDaysInEnglish() -> [String] {
    let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
    calendar.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
    return calendar.weekdaySymbols
}

enum SearchDirection {
    case Next
    case Previous
    
    var calendarOptions: NSCalendar.Options {
        switch self {
        case .Next:
            return .matchNextTime
        case .Previous:
            return [.searchBackwards, .matchNextTime]
        }
    }
}

// Gets next or previous date with given day name
func get(_ direction: SearchDirection, _ dayName: String, considerToday consider: Bool = false) -> Date {
    let weekdaysName = getWeekDaysInEnglish()
    assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
    
    let nextWeekDayIndex = weekdaysName.index(of: dayName)! + 1
    let today = Date()
    let calendar = NSCalendar(calendarIdentifier: .gregorian)!
    
    if consider && calendar.component(.weekday, from: today) == nextWeekDayIndex {
        return today
    }
    
    var nextDateComponent = DateComponents()
    nextDateComponent.weekday = nextWeekDayIndex
    
    let date = calendar.nextDate(after: today, matching: nextDateComponent, options: direction.calendarOptions)
    return date!
}

func daySuffix(from date: Date) -> String {
    let calendar = Calendar.current
    let dayOfMonth = calendar.component(.day, from: date)
    switch dayOfMonth {
    case 1, 21, 31: return "st"
    case 2, 22: return "nd"
    case 3, 23: return "rd"
    default: return "th"
    }
}
