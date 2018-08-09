//
//  HostVC.swift
//  HCFA
//
//  Created by Collin Price on 1/4/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import InteractiveSideMenu
import AWSCore
import AWSS3

class HostVC: MenuContainerViewController {
    
    let sliderButton = UIButton()
    let createButton = UIButton()
    var slider: UIBarButtonItem!
    var create: UIBarButtonItem!
    var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar = navigationController!.navigationBar
        
        let BUTTON_LENGTH = navBar.frame.height*0.6
        sliderButton.frame = CGRect(x: 0, y: 0, width: BUTTON_LENGTH, height: BUTTON_LENGTH)
        sliderButton.setImage(UIImage(named: "slider"), for: .normal)
        sliderButton.contentMode = .scaleAspectFit
        sliderButton.widthAnchor.constraint(equalToConstant: 28).isActive = true
        sliderButton.heightAnchor.constraint(equalToConstant: 28).isActive = true

        createButton.frame = CGRect(x: 0, y: 0, width: BUTTON_LENGTH, height: BUTTON_LENGTH)
        createButton.setImage(UIImage(named: "create"), for: .normal)
        createButton.imageView?.contentMode = .scaleAspectFit
        createButton.widthAnchor.constraint(equalToConstant: 28).isActive = true
        createButton.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        slider = UIBarButtonItem(customView: sliderButton)
        create = UIBarButtonItem(customView: createButton)

        transitionOptions = TransitionOptions(duration: 0.4, contentScale: 1.0,
                                              visibleContentWidth: UIScreen.main.bounds.width/6)
 
        contentViewControllers = [ProfileVC(), EventVC(), BibleCourseVC(), MinistryTeamVC(), SettingsVC()]
        selectContentViewController(contentViewControllers[Tabs.Events])
        
        menuViewController = SideMenuVC()
        menuViewController.menuContainerViewController = self
    }
}
