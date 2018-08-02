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
    var createButton: UIButton!
    var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = lightColor
        
        navBar = navigationController!.navigationBar
        hostVC = navigationController?.viewControllers.first as! HostVC
        
        let BUTTON_LENGTH = navBar.frame.height*0.6
        createButton = UIButton(frame: CGRect(x: view.frame.width - BUTTON_LENGTH*1.5,
                                              y: (navBar.frame.height-BUTTON_LENGTH)/2,
                                              width: BUTTON_LENGTH, height: BUTTON_LENGTH))
        createButton.setImage(UIImage(named: "create"), for: .normal)
        createButton.imageView?.contentMode = .scaleAspectFit
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hostVC.slider.addTarget(self, action: #selector(self.sliderTapped), for: .touchUpInside)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        hostVC.slider.removeTarget(self, action: #selector(self.sliderTapped), for: .touchUpInside)
    }
    
    func backToSignIn() {
        resetDefaults()
        let signInVC = self.navigationController!.presentingViewController!
        dismiss(animated: true, completion: nil)
        createAlert(title: "Session Expired", message: "", view: signInVC)
    }
    
    @objc func sliderTapped(sender: UIButton) {
        showSideMenu()
    }
}
