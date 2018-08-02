//
//  SetPermissionVC.swift
//  HCFA
//
//  Created by Collin Price on 7/31/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import Eureka

class SetPermissionVC: FormViewController, TypedRowControllerType {
    
    var isLeader: Bool!
    var isAdd: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("")
        <<< EmailRow() { row in
            row.placeholder = "Email"
            row.tag = "email"
            row.cellUpdate { cell, row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            }
            row.onCellHighlightChanged { cell, row in
                cell.textLabel?.textColor = redColor
            }
        }
        <<< ButtonRow() { row in
            if isAdd {
                if isLeader {
                    row.title = "Add Leader"
                } else {
                    row.title = "Add Admin"
                }
            } else if isLeader {
                row.title = "Remove Leader"
            } else {
                row.title = "Remove Admin"
            }
        }
        .cellUpdate { cell, _row in
            cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            cell.textLabel?.textColor = redColor
        }
        .onCellSelection { _, _ in

            if let email = self.form.values()["email"] as? String {
                if email == defaults.string(forKey: "email")! {
                    createAlert(title: "Invalid Action", message: "You cannot change your own permissions",
                                view: self)
                } else {
                    if self.isAdd {
                        if self.isLeader {
                            self.addLeader(email: email)
                        } else {
                            self.addAdmin(email: email)
                        }
                    } else if self.isLeader {
                        self.removeLeader(email: email)
                    } else {
                        self.removeAdmin(email: email)
                    }
                }
            } else {
                createAlert(title: "Email Empty", message: "Enter a user's email", view: self)
            }
        }
    }
    
    func handle(_ response: URLResponses, _ data: Any?, _ message: String) {
        switch response {
        case .NotConnected:
            createAlert(title: "Connection Error", message: "Unable to connect to the server",
                        view: self)
        case .Error:
            createAlert(title: "Error", message: data as! String, view: self)
        case .InvalidSession:
            self.backToSignIn()
        default:
            navigationController!.popViewController(animated: true)
            createAlert(title: message, message: "", view: navigationController!.viewControllers.last!)
        }
    }
    
    func addLeader(email: String) {
        API.addLeader(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!, email: email,
                      completionHandler: { response, data in
            self.handle(response, data, "Leader Permission Added")
        })
    }
    
    func removeLeader(email: String) {
        API.removeLeader(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                         email: email, completionHandler: { response, data in
            self.handle(response, data, "Leader Permission Removed")
        })
    }
    
    func addAdmin(email: String) {
        API.addAdmin(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!, email: email,
                     completionHandler: { response, data in
                        self.handle(response, data, "Admin Permission Added")
        })
    }
    
    func removeAdmin(email: String) {
        API.removeAdmin(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!, email: email,
                        completionHandler: { response, data in
            self.handle(response, data, "Admin Permission Removed")
        })
    }
    
    func backToSignIn() {
        resetDefaults()
        let signInVC = navigationController!.presentingViewController!
        dismiss(animated: true, completion: nil)
        createAlert(title: "Session Expired", message: "", view: signInVC)
    }
    
    // these are required to conform to TypedRowControllerType
    public var row: RowOf<String>!
    public var onDismissCallback : ((UIViewController) -> ())?
}
