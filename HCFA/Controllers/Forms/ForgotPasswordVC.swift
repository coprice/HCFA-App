//
//  ForgotPasswordVC.swift
//  HCFA
//
//  Created by Collin Price on 8/4/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import Eureka

class ForgotPasswordVC: FormViewController {

    let cancel = UIButton()
    var navBar: UINavigationBar!
    var loadingView: LoadingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = lightColor
        navigationAccessoryView.tintColor = redColor
        navBar = navigationController!.navigationBar
        
        cancel.frame = CGRect(x: navBar.frame.width*0.75, y: 0,
                              width: navBar.frame.width/4, height: navBar.frame.height)
        cancel.setTitle("Cancel", for: .normal)
        cancel.titleLabel?.textColor = .white
        cancel.titleLabel?.font = UIFont(name: "Georgia", size: navBar.frame.width/21)
        cancel.setTitleColor(barHighlightColor, for: .highlighted)
        cancel.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        loadingView = LoadingView(frame: CGRect(x: view.frame.width*0.375,
                                                y: view.frame.height/2 - view.frame.width*0.125,
                                                width: view.frame.width*0.25, height: view.frame.width*0.25))
        
        navBar.topItem?.title = "Reset Password"
        navBar.addSubview(cancel)
        
        form +++ Section("")
        <<< EmailRow() { row in
            row.title = "Email"
            row.placeholder = "Email"
            row.tag = "email"
            row.cellUpdate { cell, row in
                cell.textLabel?.font = formFont
                cell.textField.font = formFont
            }
            row.onCellHighlightChanged { cell, row in
                cell.textLabel?.textColor = redColor
            }
        }
            
        +++ Section("")
        <<< ButtonRow() { row in
            row.title = "Send Request"
        }
        .cellUpdate { cell, _row in
            cell.textLabel?.font = formFont
            cell.textLabel?.textColor = redColor
        }
        .onCellSelection { _, _ in
            
            guard let email = self.form.values()["email"] as? String else {
                return createAlert(title: "Email Empty", message: "Enter your email address", view: self)
            }
            
            self.view.addSubview(self.loadingView)
            self.navBar.isUserInteractionEnabled = false
            self.tableView.isUserInteractionEnabled = false
            
            API.sendPasswordRequest(email: email, completionHandler: { response, data in
                
                self.loadingView.removeFromSuperview()
                self.navBar.isUserInteractionEnabled = true
                self.tableView.isUserInteractionEnabled = true
                
                switch response {
                case .NotConnected:
                    createAlert(title: "Connection Error", message: "Unable to connect to the server",
                                view: self)
                case .Error:
                    createAlert(title: "Error", message: data as! String, view: self)
                case .InternalError:
                    if let msg = data as? String {
                        createAlert(title: "Internal Server Error", message: msg, view: self)
                    } else {
                        createAlert(title: "Internal Server Error", message: "Something went wrong", view: self)
                    }
                default:
                    let signInVC = self.navigationController!.presentingViewController!
                    self.dismiss(animated: true, completion: {
                        createAlert(title: "Request Sent", message: "An email has been sent to you",
                                    view: signInVC)
                    })
                }
            })
        }
    }
    
    @objc func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
}
