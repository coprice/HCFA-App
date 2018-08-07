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
    var navBar: UINavigationBar!
    var loadingView: LoadingView!
    var isCourse: Bool!
    var id: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = lightColor
        navigationAccessoryView.barTintColor = redColor
        hostVC = navigationController?.viewControllers.first as! HostVC
        navBar = navigationController!.navigationBar
        loadingView = LoadingView(frame: CGRect(x: view.frame.width*0.375,
                                                y: view.frame.height/2 - view.frame.width*0.125,
                                                width: view.frame.width*0.25, height: view.frame.width*0.25))
        
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
            
            self.view.addSubview(self.loadingView)
            self.navBar.isUserInteractionEnabled = false
            self.tableView.isUserInteractionEnabled = false
            
            if self.isCourse {
                API.sendCourseRequest(uid: defaults.integer(forKey: "uid"),
                                        token: defaults.string(forKey: "token")!, cid: self.id,
                                        message: message, completionHandler: { response, data in
                    self.handle(response, data)
                })
            } else {
                API.sendTeamRequest(uid: defaults.integer(forKey: "uid"),
                                      token: defaults.string(forKey: "token")!, tid: self.id,
                                      message: message, completionHandler: { response, data in
                    self.handle(response, data)
                })
            }
        }
        
        animateScroll = true
    }
    
    func handle(_ response: URLResponses, _ data: Any?) {
        loadingView.removeFromSuperview()
        navBar.isUserInteractionEnabled = true
        tableView.isUserInteractionEnabled = true
        
        switch response {
        case .NotConnected:
            createAlert(title: "Connection Error", message: "Unable to connect to the server", view: self)
        case .Error:
            createAlert(title: "Error", message: data as! String, view: self)
        case .InvalidSession:
            resetDefaults()
            let signInVC = navigationController!.presentingViewController!
            dismiss(animated: true, completion: {
                createAlert(title: "Session Expired", message: "", view: signInVC)
            })
        case .InternalError:
            createAlert(title: "Internal Server Error", message: "Something went wrong", view: self)
        default:
            navigationController!.popViewController(animated: true)
            createAlert(title: "Request Sent", message: "", view: navigationController!.viewControllers.last!)
        }
    }
}
