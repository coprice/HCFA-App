//
//  TemplateVC.swift
//  HCFA
//
//  Created by Collin Price on 1/4/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit
import InteractiveSideMenu

class TemplateVC: UIViewController, SideMenuItemContent {
    
    var hostVC: HostVC!
    var navBar: UINavigationBar!
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = lightColor
        
        navBar = navigationController!.navigationBar
        hostVC = navigationController?.viewControllers.first as! HostVC
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hostVC.sliderButton.addTarget(self, action: #selector(self.sliderTapped), for: .touchUpInside)
        hostVC.navigationItem.leftBarButtonItem = hostVC.slider
        hostVC.navigationItem.rightBarButtonItems = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hostVC.sliderButton.removeTarget(self, action: #selector(self.sliderTapped), for: .touchUpInside)
    }
    
    func backToSignIn() {
        resetDefaults()
        let signInVC = navigationController!.presentingViewController!
        dismiss(animated: true, completion: {
            createAlert(title: "Session Expired", message: "", view: signInVC)
        })
    }
    
    @objc func sliderTapped() {
        showSideMenu()
    }
}
