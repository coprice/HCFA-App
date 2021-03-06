//
//  DisplayTemplateVC.swift
//  HCFA
//
//  Created by Collin Price on 1/14/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit
import EventKit

class DisplayTemplateVC: UIViewController {
    
    var edit: UIBarButtonItem!
    var hostVC: HostVC!
    var data: [String:Any]!
    var firstAppearance = true
      
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    func shouldDisplayCalendar() -> Bool {
        
        var granted: Bool!
        
        let group = DispatchGroup()
        group.enter()
        
        EKEventStore().requestAccess(to: .event, completion: {grantedAccess, error in
            granted = grantedAccess
            group.leave()
        })
        
        group.wait()
        return granted
    }
    
    func backToSignIn() {
        resetDefaults()
        let signInVC = navigationController!.presentingViewController!
        dismiss(animated: true, completion: {
            createAlert(title: "Session Expired", message: "", view: signInVC)
        })
    }
    
    // Helpers for displaying views
    
    func calcLabelHeight(text: String, frame: CGRect, font: UIFont) -> CGFloat {
        let label = UILabel(frame: frame)
        label.text = text
        label.font = font
        label.sizeToFit()
        return label.frame.height
    }
    
    func resizeFrameToContent(_ textView: UITextView) {
        var newFrame = textView.frame
        newFrame.size.height = textView.contentSize.height
        textView.frame = newFrame
    }
    
    func recenterText(_ textView: UITextView) {
        textView.setContentOffset(CGPoint(x: 0, y: abs(textView.contentSize.height-textView.frame.height)/2), animated: false)
    }
    
    func createTextView(_ textView: UITextView, font: UIFont, text: String, color: UIColor,
                        textAlignment: NSTextAlignment) {
        textView.font = font
        textView.textAlignment = textAlignment
        textView.textColor = color
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isUserInteractionEnabled = false
        textView.text = text
        resizeFrameToContent(textView)
        recenterText(textView)
    }
    
    func createListLabel(label: UILabel, text: String, font: UIFont, color: UIColor, view: UIView) {
        label.text = text
        label.textAlignment = .center
        label.font = font
        label.textColor = color
        label.baselineAdjustment = .alignCenters
        view.addSubview(label)
    }
    
    func addLine(x: CGFloat, y: CGFloat, width: CGFloat, view: UIView) {
        let line = UILabel(frame: CGRect(x: x, y: y, width: width, height: 1))
        line.backgroundColor = .lightGray
        view.addSubview(line)
    }
    
    func addLightLine(x: CGFloat, y: CGFloat, width: CGFloat, view: UIView) {
        let line = UILabel(frame: CGRect(x: x, y: y, width: width, height: 1))
        line.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.2)
        view.addSubview(line)
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
}
