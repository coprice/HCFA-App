//
//  RequestVC.swift
//  HCFA
//
//  Created by CollinP on 7/25/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import Eureka

class RequestVC: FormViewController {
    
    var hostVC: HostVC!
    var isCourse: Bool!
    var id: Int!
    var parentVC: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = lightColor
        navigationAccessoryView.barTintColor = redColor
        hostVC = navigationController?.viewControllers.first as! HostVC
        
        form +++ Section("Optional Message")
            <<< TextAreaRow() { row in
                var text: String!
                if isCourse {
                    text = "bible course"
                } else {
                    text = "ministry team"
                }
                row.placeholder = "Enter why you want to join this \(text!)"
                row.tag = "message"
                row.value = nil
                row.cellUpdate { cell, row in
                    cell.placeholderLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                    cell.textView.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                }
            }
            
        +++ Section("")
        <<< ButtonRow() { row in
            row.title = "Send Request"
        }
        .cellUpdate { cell, _row in
            cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            cell.textLabel?.textColor = redColor
        }
        .onCellSelection { _cell, _row in
            
            let message = self.form.values()["message"] as? String
            
            if self.isCourse {
                API.createCourseRequest(uid: defaults.integer(forKey: "uid"),
                                        token: defaults.string(forKey: "token")!, cid: self.id,
                                        message: message, completionHandler: { response, data in
                    self.handle(response, data)
                })
            } else {
                API.createTeamRequest(uid: defaults.integer(forKey: "uid"),
                                      token: defaults.string(forKey: "token")!, tid: self.id,
                                      message: message, completionHandler: { response, data in
                    self.handle(response, data)
                })
            }
        }
        
        animateScroll = true
    }
    
    func handle(_ response: URLResponses, _ data: Any?) {
        switch response {
        case .NotConnected:
            createAlert(title: "Connection Error", message: "Unable to connect to the server", view: self)
        case .Error:
            createAlert(title: "Error", message: data as! String, view: self)
        case .InvalidSession:
            resetDefaults()
            let signInVC = navigationController!.presentingViewController!
            dismiss(animated: true, completion: nil)
            createAlert(title: "Session Expired", message: "", view: signInVC)
        default:
            navigationController!.popViewController(animated: true)
            createAlert(title: "Request Sent", message: "", view: navigationController!.viewControllers.last!)
        }
    }
}
