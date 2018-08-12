//
//  ForgotPasswordVC.swift
//  HCFA
//
//  Created by Collin Price on 8/4/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import Eureka

class ForgotPasswordVC: FormViewController {

    var loadingView: LoadingView!
    var cancel: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = lightColor
        navigationAccessoryView.tintColor = redColor
        loadingView = LoadingView(frame: CGRect(x: view.frame.width*0.375,
                                                y: view.frame.height/2 - view.frame.width*0.125,
                                                width: view.frame.width*0.25, height: view.frame.width*0.25))
        cancel = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelTapped))
        
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
            row.title = "Send Email"
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
            self.navigationController!.navigationBar.isUserInteractionEnabled = false
            self.tableView.isUserInteractionEnabled = false
            
            API.sendPasswordRequest(email: email, completionHandler: { response, data in
                
                self.loadingView.removeFromSuperview()
                self.navigationController!.navigationBar.isUserInteractionEnabled = true
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Reset Password"
        navigationItem.rightBarButtonItem = cancel
    }
    
    @objc func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
}
