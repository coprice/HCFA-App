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
    
    let slider = UIButton()
    var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar = navigationController!.navigationBar
        
        let BUTTON_LENGTH = navBar.frame.height*0.6
        slider.frame = CGRect(x: BUTTON_LENGTH/2, y: navBar.frame.height*0.2,
                              width: BUTTON_LENGTH, height: BUTTON_LENGTH)
        slider.setImage(UIImage(named: "slider"), for: .normal)
        slider.contentMode = .scaleAspectFit
        slider.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        slider.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        let barItem = UIBarButtonItem(customView: slider)
        navBar.topItem?.leftBarButtonItem = barItem

        transitionOptions = TransitionOptions(duration: 0.4, contentScale: 1.0,
                                              visibleContentWidth: UIScreen.main.bounds.width/6)
 
        contentViewControllers = [ProfileVC(), EventVC(), BibleCourseVC(), MinistryTeamVC(), SettingsVC()]
        selectContentViewController(contentViewControllers[Tabs.Events])
        
        menuViewController = SideMenuVC()
        menuViewController.menuContainerViewController = self
    }
}
