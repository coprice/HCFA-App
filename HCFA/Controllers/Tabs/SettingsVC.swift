//
//  SettingsVC.swift
//  HCFA
//
//  Created by Collin Price on 1/6/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import Eureka

class SettingsVC: FormViewController {
    
    var hostVC: HostVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = lightColor
        hostVC = navigationController?.viewControllers.first as! HostVC
        
        if defaults.bool(forKey: "admin") {
            form +++ Section("")
            <<< ButtonRowWithPresent<PermissionVC> { row in
                row.title = "Permissions"
                row.presentationMode = PresentationMode<PermissionVC>.show(controllerProvider: ControllerProvider.callback {
                    return PermissionVC()
                }, onDismiss: nil)
                row.cellUpdate { cell, row in
                    cell.textLabel?.font = formFont
                }
            }
        }
        
        form +++ Section("")
        <<< ButtonRow() { row in
            row.title = "Sign Out"
        }
        .cellUpdate { cell, _row in
            cell.textLabel?.font = formFont
            cell.textLabel?.textColor = redColor
        }
        .onCellSelection { _, _ in
            
            let alert = UIAlertController(title: "Are you sure you want to sign out?",
                                          message: "",
                                          preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Yes", style: .default) { _ in
                resetDefaults()
                self.dismiss(animated: true, completion: nil)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
            
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hostVC.navigationItem.leftBarButtonItem = hostVC.slider
        hostVC.navigationItem.rightBarButtonItems = nil
        
        hostVC.navigationItem.title = "Settings"
        
        let backItem = UIBarButtonItem()
        backItem.title = hostVC.navigationItem.title
        hostVC.navigationItem.backBarButtonItem = backItem
    }
}
