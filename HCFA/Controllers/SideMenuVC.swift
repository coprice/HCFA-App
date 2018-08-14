//
//  SideMenuVC.swift
//  HCFA
//
//  Created by Collin Price on 1/4/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit
import InteractiveSideMenu

class SideMenuVC: MenuViewController {
    
    var currentTab = Tabs.Events
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = sideMenuColor
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.width*(5/6), height: view.frame.height),
                                style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.separatorColor = sideMenuHighlightColor
        view.addSubview(tableView)
 
    }
        
    private func changeVC(destinationTab: Int) {
        
        guard let host = menuContainerViewController else { return }
        host.hideSideMenu()
        if currentTab == destinationTab { return }
        currentTab = destinationTab
        let contentController = host.contentViewControllers[destinationTab]
        host.selectContentViewController(contentController)
    }
}

// MARK: UITableViewDelegate methods

extension SideMenuVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return tableView.frame.height*0.35
        }
        return tableView.frame.height/8
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        changeVC(destinationTab: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

// MARK: UITableViewDataSource methods

extension SideMenuVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = ProfileCell()
            cell.cellWidth = tableView.frame.width
            cell.cellHeight = tableView.frame.height*0.35
            cell.load()
            return cell
        } else {
            let cell = SideMenuCell()
            cell.cellWidth = tableView.frame.width
            cell.cellHeight = tableView.frame.height/8
            cell.load(tab: indexPath.row)
            return cell
        }
    }
}
