//
//  PermissionVC.swift
//  HCFA
//
//  Created by Collin Price on 7/28/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import Eureka

class PermissionVC: FormViewController, TypedRowControllerType {
    
    var hostVC: HostVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = lightColor
        hostVC = (navigationController?.viewControllers.first as! HostVC)
        
        form +++ Section("Leaders")
        <<< ButtonRowWithPresent<SetPermissionVC> { row in
            row.title = "Add Leader"
            row.presentationMode = PresentationMode<SetPermissionVC>.show(controllerProvider: ControllerProvider.callback {
                let vc = SetPermissionVC()
                vc.isLeader = true
                vc.isAdd = true
                return vc
            }, onDismiss: nil)
            row.cellUpdate { cell, row in
                cell.textLabel?.font = formFont
            }
        }
        <<< ButtonRowWithPresent<SetPermissionVC> { row in
            row.title = "Remove Leader"
            row.presentationMode = PresentationMode<SetPermissionVC>.show(controllerProvider: ControllerProvider.callback {
                let vc = SetPermissionVC()
                vc.isLeader = true
                vc.isAdd = false
                return vc
            }, onDismiss: nil)
            row.cellUpdate { cell, row in
                cell.textLabel?.font = formFont
            }
        }
        
        +++ Section("Admins")
        <<< ButtonRowWithPresent<SetPermissionVC> { row in
            row.title = "Add Admin"
            row.presentationMode = PresentationMode<SetPermissionVC>.show(controllerProvider: ControllerProvider.callback {
                let vc = SetPermissionVC()
                vc.isLeader = false
                vc.isAdd = true
                return vc
            }, onDismiss: nil)
            row.cellUpdate { cell, row in
                cell.textLabel?.font = formFont
            }
        }
        <<< ButtonRowWithPresent<SetPermissionVC> { row in
            row.title = "Remove Admin"
            row.presentationMode = PresentationMode<SetPermissionVC>.show(controllerProvider: ControllerProvider.callback {
                let vc = SetPermissionVC()
                vc.isLeader = false
                vc.isAdd = false
                return vc
            }, onDismiss: nil)
            row.cellUpdate { cell, row in
                cell.textLabel?.font = formFont
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Permissions"
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItems = nil
    }
    
    // these are required to conform to TypedRowControllerType
    public var row: RowOf<String>!
    public var onDismissCallback : ((UIViewController) -> ())?
}
