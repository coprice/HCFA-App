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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = lightColor
        navigationAccessoryView.tintColor = redColor
        let navBar = navigationController!.navigationBar
        
        cancel.frame = CGRect(x: navBar.frame.width*0.75, y: 0,
                              width: navBar.frame.width/4, height: navBar.frame.height)
        cancel.setTitle("Cancel", for: .normal)
        cancel.titleLabel?.textColor = .white
        cancel.titleLabel?.font = UIFont(name: "Georgia", size: navBar.frame.width/21)
        cancel.setTitleColor(barHighlightColor, for: .highlighted)
        cancel.addTarget(self, action: #selector(self.cancelTapped), for: .touchUpInside)
        
        
        navBar.topItem?.title = "Reset Password"
        navBar.addSubview(cancel)
        
        form +++ Section("")
        <<< EmailRow() { row in
            row.title = "Email"
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
            
        +++ Section("")
        <<< ButtonRow() { row in
            row.title = "Send Request"
        }
        .cellUpdate { cell, _row in
            cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            cell.textLabel?.textColor = redColor
        }
        .onCellSelection { _, _ in
            print("time to send change password request")
        }
    }
    
    @objc func cancelTapped(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
