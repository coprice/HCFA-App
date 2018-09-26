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
        hostVC = (navigationController?.viewControllers.first as! HostVC)
        
        form +++ Section("Notifications")
        <<< SwitchRow { row in
            row.title = "Events"
            row.value = defaults.bool(forKey: "event_ntf")
            row.cellSetup  { cell, _ in
                cell.textLabel?.font = formFont
                cell.switchControl.onTintColor = redColor
            }
            row.onChange { row in
                API.updateNotifications(uid: defaults.integer(forKey: "uid"),
                                        token: defaults.string(forKey: "token")!, ntfType: "event_notifications",
                                        ntfBool: row.value!, completionHandler: { _, _ in })
                defaults.set(row.value!, forKey: "event_ntf")
            }
        }
        <<< SwitchRow { row in
            row.title = "Bible Courses"
            row.value = defaults.bool(forKey: "course_ntf")
            row.cellSetup  { cell, _ in
                cell.textLabel?.font = formFont
                cell.switchControl.onTintColor = redColor
            }
            row.onChange { row in
                API.updateNotifications(uid: defaults.integer(forKey: "uid"),
                                        token: defaults.string(forKey: "token")!, ntfType: "course_notifications",
                                        ntfBool: row.value!, completionHandler: { _, _ in })
                defaults.set(row.value!, forKey: "course_ntf")
            }
        }
        <<< SwitchRow { row in
            row.title = "Ministry Teams"
            row.value = defaults.bool(forKey: "team_ntf")
            row.cellSetup  { cell, _ in
                cell.textLabel?.font = formFont
                cell.switchControl.onTintColor = redColor
            }
            row.onChange { row in
                API.updateNotifications(uid: defaults.integer(forKey: "uid"),
                                        token: defaults.string(forKey: "token")!, ntfType: "team_notifications",
                                        ntfBool: row.value!, completionHandler: { _, _ in })
                defaults.set(row.value!, forKey: "team_ntf")
            }
        }
        
        if defaults.bool(forKey: "admin") {
            form +++ Section("")
            <<< ButtonRowWithPresent<PermissionVC> { row in
                row.title = "Permissions"
                row.presentationMode = PresentationMode<PermissionVC>.show(controllerProvider: ControllerProvider.callback {
                    return PermissionVC()
                }, onDismiss: nil)
                row.cellUpdate { cell, _ in
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
