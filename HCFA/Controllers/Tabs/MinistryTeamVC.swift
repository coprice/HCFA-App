//
//  MinistryTeamVC.swift
//  HCFA
//
//  Created by Collin Price on 1/6/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit

class MinistryTeamVC: TemplateVC {
    
    var tableView: UITableView!
    var cellWidth: CGFloat!
    var cellHeight: CGFloat!
    var rows: [[String:Any]] = []
    var yourRows: [[String:Any]] = []
    var allRows: [[String:Any]] = []
    var userTeams: [Int] = []
    var adminTeams: [Int] = []
    var displayingYours = true
    var firstAppearance = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let offset = navBar.frame.height + UIApplication.shared.statusBarFrame.height
        cellWidth = view.frame.width
        cellHeight = view.frame.height/5
        
        createButton.addTarget(self, action: #selector(self.create), for: .touchUpInside)
        
        let refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0))
        refreshControl.tintColor = highlightColor
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControlEvents.valueChanged)
        
        tableView = UITableView(frame: CGRect(x: 0, y: offset, width: view.frame.width,
                                              height: view.frame.height - offset), style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = lightColor
        tableView.showsVerticalScrollIndicator = false
        tableView.sectionFooterHeight = 0.0
        tableView.refreshControl = refreshControl
        tableView.separatorStyle = .none
        view.addSubview(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstAppearance {
            startRefreshControl()
            refresh(sender: self)
        }
        
        navBar.topItem?.title = "Ministry Teams"
        let backItem = UIBarButtonItem()
        backItem.title = "MTs"
        navBar.topItem?.backBarButtonItem = backItem
        
        if createButton.superview == nil && defaults.bool(forKey: "admin") {
            navBar.addSubview(createButton)
        }
        if hostVC.slider.superview == nil {
            navBar.addSubview(hostVC.slider)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        createButton.removeFromSuperview()
    }
    
    func startRefreshControl() {
        tableView.setContentOffset(CGPoint(x: 0, y: -(tableView.refreshControl?.frame.size.height)!),
                                   animated: true)
        tableView.refreshControl?.beginRefreshing()
    }
    
    func clearTableview() {
        displayingYours = true
        rows = []
        tableView.reloadData()
    }
    
    func currentRows() -> [[String:Any]] {
        if displayingYours {
            return yourRows
        } else {
            return allRows
        }
    }
    
    @objc func create(sender: UIButton) {
        hostVC.slider.removeFromSuperview()
        createButton.removeFromSuperview()
        navigationController!.pushViewController(CreateMinistryTeamVC(), animated: true)
    }
    
    @objc func displayUsersMTs(sender: UIButton) {
        if displayingYours || tableView.refreshControl!.isRefreshing { return }
        displayingYours = true
        rows = currentRows()
        tableView.reloadData()
    }
    
    @objc func displayMTs(sender: UIButton) {
        if !displayingYours || tableView.refreshControl!.isRefreshing { return }
        displayingYours = false
        rows = currentRows()
        tableView.reloadData()
    }
    
    @objc func refresh(sender:AnyObject) {
        
        API.getTeams(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!) {
            response, data in
            
            if self.firstAppearance {
                self.firstAppearance = false
            }
            
            switch response {
            case .NotConnected:
                self.allRows = []
                self.yourRows = self.allRows.filter({ row in
                    self.userTeams.contains(row["tid"] as! Int)
                })
                self.rows = self.currentRows()
                self.tableView.reloadData()
                createAlert(title: "Connection Error", message: "Unable to connect to the server", view: self,
                            completion: {
                    self.tableView.refreshControl?.endRefreshing()
                })
            case .Error:
                self.allRows = []
                self.yourRows = self.allRows.filter({ row in
                    self.userTeams.contains(row["tid"] as! Int)
                })
                self.rows = self.currentRows()
                self.tableView.reloadData()
                createAlert(title: "Error", message: "Unable to connect to the server", view: self, completion: {
                    self.tableView.refreshControl?.endRefreshing()
                })
            case .InvalidSession:
                self.backToSignIn()
            default:
                let data = data as! [String:Any]
                
                self.allRows = data["teams"] as! [[String:Any]]

                let coursesDict = data["user_teams"] as! [String:Any]
                self.adminTeams = (coursesDict["admin"] as! [Int])
                self.userTeams = (coursesDict["member"] as! [Int]) + self.adminTeams
                
                self.yourRows = self.allRows.filter({ row in
                    self.userTeams.contains(row["tid"] as! Int)
                })
                
                self.rows = self.currentRows()
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: UITableViewDelegate methods

extension MinistryTeamVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            let TOGGLE_HEIGHT = view.frame.height/20
            let TOGGLE_WIDTH = view.frame.width/4
            
            let your = UIButton(frame: CGRect(x: cellWidth/2 - TOGGLE_WIDTH - 2,
                                              y: view.frame.height/20 - TOGGLE_HEIGHT/2,
                                              width: TOGGLE_WIDTH, height: TOGGLE_HEIGHT))
            if displayingYours {
                your.backgroundColor = redColor
            } else {
                your.backgroundColor = highlightColor
            }
            
            your.layer.cornerRadius = TOGGLE_HEIGHT/5
            your.setBackgroundImage(roundedImage(color: redColor, width: TOGGLE_WIDTH, height: TOGGLE_HEIGHT,
                                                 cornerRadius: your.layer.cornerRadius), for: .highlighted)
            your.setTitle("Your", for: .normal)
            your.titleLabel?.font = UIFont(name: "Baskerville", size: TOGGLE_WIDTH/5)
            your.layer.borderWidth = TOGGLE_HEIGHT/20
            your.layer.borderColor = redColor.cgColor
            your.addTarget(self, action: #selector(self.displayUsersMTs), for: .touchUpInside)
            
            let join = UIButton(frame: CGRect(x: cellWidth/2 + 2, y: view.frame.height/20 - TOGGLE_HEIGHT/2,
                                              width: TOGGLE_WIDTH, height: TOGGLE_HEIGHT))
            if displayingYours {
                join.backgroundColor = highlightColor
            } else {
                join.backgroundColor = redColor
            }
            
            join.layer.cornerRadius = TOGGLE_HEIGHT/5
            join.setBackgroundImage(roundedImage(color: redColor, width: TOGGLE_WIDTH, height: TOGGLE_HEIGHT,
                                                 cornerRadius: join.layer.cornerRadius), for: .highlighted)
            join.setTitle("All", for: .normal)
            join.titleLabel?.font = UIFont(name: "Baskerville", size: TOGGLE_WIDTH/5)
            join.layer.borderWidth = TOGGLE_HEIGHT/20
            join.layer.borderColor = redColor.cgColor
            join.addTarget(self, action: #selector(self.displayMTs), for: .touchUpInside)
            
            let headerView = UIView()
            headerView.backgroundColor = .clear
            headerView.addSubview(your)
            headerView.addSubview(join)
            return headerView
        } else {
            let view = UIView()
            view.backgroundColor = .clear
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight*1.1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return view.frame.height/10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let data = rows[indexPath.row]
        
        let displayMT = DisplayMinistryTeamVC()
        let tid = data["tid"] as! Int
        
        if userTeams.contains(tid) {
            displayMT.joined = true
        }
        
        if adminTeams.contains(tid) || defaults.bool(forKey: "admin") {
            displayMT.admin = true
        }
        displayMT.load(data, navBar, hostVC)
        navigationController!.pushViewController(displayMT, animated: true)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        let cell = tableView.cellForRow(at: indexPath) as? MinistryTeamCell
        cell?.highlightView()
        return true
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? MinistryTeamCell
        cell?.unhighlightView()
    }
}

// MARK: UITableViewDataSource methods

extension MinistryTeamVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if firstAppearance {
            return 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if rows.isEmpty {
            return 1
        }
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if rows.isEmpty {
            let cell = EmptyCell()
            var text: String
            if displayingYours {
                text = "You are not in any ministry teams"
            } else {
                text = "No ministry teams to display"
            }
            cell.load(width: cellWidth, height: cellHeight/4, text: text)
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        let data = rows[indexPath.row]
        let cell = MinistryTeamCell()
        cell.width = cellWidth
        cell.height = cellHeight
        cell.load(data: data)
        return cell
    }
}
