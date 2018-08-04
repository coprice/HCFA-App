//
//  PasswordVC.swift
//  HCFA
//
//  Created by Collin Price on 7/26/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import Eureka

class PasswordViewController: FormViewController, TypedRowControllerType {

    var hostVC: HostVC!
    var loadingView: LoadingView!
    var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hostVC = navigationController?.viewControllers.first as! HostVC
        navBar = navigationController!.navigationBar
        loadingView = LoadingView(frame: CGRect(x: view.frame.width*0.375,
                                                y: view.frame.height/2 - view.frame.width*0.125,
                                                width: view.frame.width*0.25, height: view.frame.width*0.25))
        
        form +++ Section("")
        <<< PasswordRow() { row in
            row.title = "Current Password"
            row.tag = "current"
            row.placeholder = "Current Password"
            row.cellUpdate { cell, row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            }
            row.onCellHighlightChanged { cell, row in
                cell.textLabel?.textColor = redColor
            }
        }
        
        <<< PasswordRow() { row in
            row.title = "New Password"
            row.tag = "password"
            row.placeholder = "New Password"
            row.cellUpdate { cell, row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            }
            row.onCellHighlightChanged { cell, row in
                cell.textLabel?.textColor = redColor
            }
        }
        
        <<< PasswordRow() { row in
            row.title = "Confirm"
            row.tag = "confirm"
            row.placeholder = "New Password"
            row.cellUpdate { cell, row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            }
            row.onCellHighlightChanged { cell, row in
                cell.textLabel?.textColor = redColor
            }
        }
        
        +++ Section("")
        <<< ButtonRow() { row in
            row.title = "Change Password"
        }
        .cellUpdate { cell, _row in
            cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            cell.textLabel?.textColor = redColor
        }
        .onCellSelection { _, _ in
            let values = self.form.values()
            
            guard let current = values["current"] as? String else {
                return createAlert(title: "Current Password Empty", message: "Enter your current password",
                                   view: self)
            }
            
            guard let password = values["password"] as? String else {
                return createAlert(title: "New Password Empty", message: "Enter your new password", view: self)
            }
            
            guard let confirm = values["confirm"] as? String else {
                return createAlert(title: "New Password Empty", message: "Confirm your new password", view: self)
            }
            
            if current == password {
                createAlert(title: "Password Not Changed",
                            message: "Your new password must be different than your previous password", view: self)
            
            } else if !isSecure(text: password) {
                createAlert(title: "Insecure Password",
                            message: "Password must be at least 8 characters, with a capital letter and a number",
                            view: self)
                
            } else if password != confirm {
                createAlert(title: "New Passwords Don't Match", message: "Your passwords do not match", view: self)
            
            } else {
                
                self.view.addSubview(self.loadingView)
                self.navBar.isUserInteractionEnabled = false
                self.tableView.isUserInteractionEnabled = false
                
                API.changePassword(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!, oldPassword: current, newPassword: password, completionHandler: { response, data in
                    
                    self.loadingView.removeFromSuperview()
                    self.navBar.isUserInteractionEnabled = true
                    self.tableView.isUserInteractionEnabled = true
                    
                    switch response {
                    case .NotConnected:
                        createAlert(title: "Connection Error", message: "Unable to connect to the server",
                                    view: self)
                    case .Error:
                        createAlert(title: "Error", message: data as! String, view: self)
                    case .InvalidSession:
                        resetDefaults()
                        let signInVC = self.navigationController!.presentingViewController!
                        self.dismiss(animated: true, completion: {
                            createAlert(title: "Session Expired", message: "", view: signInVC)
                        })
                    default:
                        self.navigationController?.popViewController(animated: true)
                        createAlert(title: "Password Updated", message: "",
                                    view: self.navigationController!.viewControllers.last!)
                    }
                })

            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Change Password"
        hostVC.slider.removeFromSuperview()
    }
    
    // these are required to conform to TypedRowControllerType
    public var row: RowOf<String>!
    public var onDismissCallback : ((UIViewController) -> ())?
}


