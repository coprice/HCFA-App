//
//  SettingsVC.swift
//  HCFA
//
//  Created by Collin Price on 1/6/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import Eureka
import InteractiveSideMenu

class SettingsVC: FormViewController, SideMenuItemContent {
    
    var navBar: UINavigationBar!
    var hostVC: HostVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = lightColor
        
        navBar = navigationController!.navigationBar
        hostVC = navigationController?.viewControllers.first as! HostVC
        
        if defaults.bool(forKey: "admin") {
            form +++ Section("")
            <<< ButtonRowWithPresent<PermissionVC> { row in
                row.title = "Permissions"
                row.presentationMode = PresentationMode<PermissionVC>.show(controllerProvider: ControllerProvider.callback {
                    return PermissionVC()
                }, onDismiss: nil)
                row.cellUpdate { cell, row in
                    cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                }
            }
        }
        
        form +++ Section("")
        <<< ButtonRow() { row in
            row.title = "Sign Out"
        }
        .cellUpdate { cell, _row in
            cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
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
        navBar.topItem?.title = "Settings"
        
        if hostVC.slider.superview == nil {
            navBar.addSubview(hostVC.slider)
        }
        
        hostVC.slider.addTarget(self, action: #selector(self.sliderTapped), for: .touchUpInside)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hostVC.slider.removeTarget(self, action: #selector(self.sliderTapped), for: .touchUpInside)
    }
    
    @objc func sliderTapped() {
        showSideMenu()
    }
}
