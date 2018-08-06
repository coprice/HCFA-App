//
//  EventVC.swift
//  HCFA
//
//  Created by Collin Price on 1/4/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit
import AWSS3
import AWSCore

class EventVC: TemplateVC {
    
    var tableView: UITableView!
    var cellWidth: CGFloat!
    var cellHeight: CGFloat!
    var rows: [[String:Any]] = []
    var upcomingRows: [[String:Any]] = []
    var pastRows: [[String:Any]] = []
    var displayingUpcoming = true
    var firstAppearance = true
    var selectButton: UIButton!
    var cancel: UIButton!
    var deleteButton: UIButton!
    var loadingView: LoadingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cellWidth = view.frame.width
        cellHeight = view.frame.height*0.175
        
        let BUTTON_LENGTH = navBar.frame.height*0.6
        selectButton = UIButton(frame: CGRect(x: view.frame.width - BUTTON_LENGTH*3,
                                              y: (navBar.frame.height-BUTTON_LENGTH)/2,
                                              width: BUTTON_LENGTH, height: BUTTON_LENGTH))
        selectButton.setImage(UIImage(named: "select"), for: .normal)
        selectButton.imageView?.contentMode = .scaleAspectFit
        selectButton.addTarget(self, action: #selector(self.selectRows), for: .touchUpInside)
        
        cancel = UIButton(frame: CGRect(x: navBar.frame.width*0.75, y: 0, width: navBar.frame.width/4,
                                      height: navBar.frame.height))
        cancel.setTitle("Cancel", for: .normal)
        cancel.titleLabel?.textColor = .white
        cancel.titleLabel?.font = UIFont(name: "Georgia", size: navBar.frame.width/21)
        cancel.setTitleColor(barHighlightColor, for: .highlighted)
        cancel.addTarget(self, action: #selector(self.cancelSelect), for: .touchUpInside)
        
        createButton.addTarget(self, action: #selector(self.create), for: .touchUpInside)
        
        let refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0))
        refreshControl.tintColor = highlightColor
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControlEvents.valueChanged)
        
        let offset = navBar.frame.height + UIApplication.shared.statusBarFrame.height
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
        
        deleteButton = UIButton(frame: CGRect(x: view.frame.width*0.125 - 1, y: view.frame.height - offset,
                                         width: view.frame.width*0.75, height: offset*0.8))
        deleteButton.layer.cornerRadius = deleteButton.frame.width/25
        deleteButton.backgroundColor = UIColor(red: 0.98, green: 0.95, blue: 0.95, alpha: 1.0)
        deleteButton.setBackgroundImage(roundedImage(color: UIColor(red: 0.8, green: 0.78, blue: 0.78, alpha: 1.0),
                                                     width: deleteButton.frame.width,
                                                     height: deleteButton.frame.height,
                                                     cornerRadius: deleteButton.layer.cornerRadius),
                                        for: .highlighted)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.titleLabel?.font = UIFont(name: "Baskerville", size: view.frame.width/20)
        deleteButton.layer.borderWidth = 1
        deleteButton.layer.borderColor = redColor.cgColor
        deleteButton.addTarget(self, action: #selector(self.deleteSelected), for: .touchUpInside)
    
        loadingView = LoadingView(frame: CGRect(x: view.frame.width*0.375,
                                                y: view.frame.height/2 - view.frame.width*0.125,
                                                width: view.frame.width*0.25, height: view.frame.width*0.25))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstAppearance {
            startRefreshControl()
            refresh(sender: self)
        }
        
        navBar.topItem?.title = "Events"
        
        let backItem = UIBarButtonItem()
        backItem.title = "Events"
        navBar.topItem?.backBarButtonItem = backItem

        if createButton.superview == nil && (defaults.bool(forKey: "admin") || defaults.bool(forKey: "leader")) {
            navBar.addSubview(createButton)
        }
        
        if selectButton.superview == nil && defaults.bool(forKey: "admin") && !displayingUpcoming {
            navBar.addSubview(selectButton)
        }
        
        if hostVC.slider.superview == nil {
            navBar.addSubview(hostVC.slider)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        createButton.removeFromSuperview()
        selectButton.removeFromSuperview()
    }
    
    func startRefreshControl() {
        tableView.setContentOffset(CGPoint(x: 0, y: -(tableView.refreshControl?.frame.size.height)!), animated: true)
        tableView.refreshControl?.beginRefreshing()
    }
    
    func clearTableview() {
        displayingUpcoming = true
        rows = []
        tableView.reloadData()
    }
    
    func currentRows() -> [[String:Any]] {
        if displayingUpcoming {
            return upcomingRows
        } else {
            return pastRows
        }
    }
    
    func trimImages() {
        let events = Set(upcomingRows.map({ String($0["eid"] as! Int) }) + pastRows.map({ String($0["eid"] as! Int) }))
        
        if var eventImages = defaults.dictionary(forKey: "eventImages") as? [String:Data] {
            for (eid, _) in eventImages {
                if !events.contains(eid) {
                    eventImages.removeValue(forKey: eid)
                }
            }
            defaults.set(eventImages, forKey: "eventImages")
        }
    }
    
    func emptyTable() {
        upcomingRows = []
        pastRows = []
        rows = []
        tableView.reloadData()
    }
    
    @objc func create(sender: UIButton) {
        hostVC.slider.removeFromSuperview()
        navigationController!.pushViewController(CreateEventVC(), animated: true)
    }
    
    @objc func selectRows(sender: UIButton) {
        createButton.removeFromSuperview()
        selectButton.removeFromSuperview()
        navBar.addSubview(cancel)
        tableView.allowsMultipleSelection = true
    }
    
    @objc func cancelSelect(sender: UIButton) {
        cancel.removeFromSuperview()
        deleteButton.removeFromSuperview()
        navBar.addSubview(createButton)
        navBar.addSubview(selectButton)
        tableView.allowsMultipleSelection = false
    }
    
    @objc func deleteSelected(sender: UIButton) {
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return }
        
        var events: [Int] = []
        for indexPath in indexPaths {
            events.append(rows[indexPath.row]["eid"] as! Int)
        }
        
        var txt: String!
        var msg: String!
        
        if events.count > 1 {
            txt = "Events"
            msg = "these"
        } else {
            txt = "Event"
            msg = "this"
        }
        
        let alert = UIAlertController(title: "Delete \(txt!)?",
            message: "Are you sure you want to delete \(msg!) \(txt!.lowercased())?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            
            self.view.addSubview(self.loadingView)
            self.view.isUserInteractionEnabled = false
            self.cancel.isUserInteractionEnabled = false
            
            API.deleteEvents(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                             events: events, completionHandler: { response, data in
                                
                self.loadingView.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
                self.cancel.isUserInteractionEnabled = true
                self.cancelSelect(sender: self.cancel)
                
                switch response {
                case .NotConnected:
                    createAlert(title: "Connection Error", message: "Unable to connect to the server", view: self)
                case .Error:
                    createAlert(title: "Error", message: data as! String, view: self)
                case .InvalidSession:
                    self.backToSignIn()
                case .InternalError:
                    createAlert(title: "Internal Server Error", message: "Something went wrong", view: self)
                default:
                    createAlert(title: "\(txt!) Deleted", message: "", view: self)
                    self.startRefreshControl()
                    self.refresh(sender: self)
                    for eid in events {
                        deleteEventImage(eid)
                    }
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func refresh(sender: AnyObject) {
        
        if firstAppearance {
            firstAppearance = false
        }
        
        API.getEvents { response, data in
            
            switch response {
            case .NotConnected:
                self.emptyTable()
                createAlert(title: "Connection Error", message: "Unable to connect to the server", view: self,
                            completion: { self.tableView.refreshControl?.endRefreshing() })
            case .Error:
                self.emptyTable()
                createAlert(title: "Error", message: "Unable to connect to the server", view: self,
                            completion: { self.tableView.refreshControl?.endRefreshing() })
            case .InvalidSession:
                self.backToSignIn()
            case .InternalError:
                self.emptyTable()
                createAlert(title: "Internal Server Error", message: "Something went wrong", view: self,
                            completion: { self.tableView.refreshControl?.endRefreshing() })
            default:
                let data = data as! [String:Any]
                self.upcomingRows = data["upcoming_events"] as! [[String:Any]]
                self.pastRows = data["past_events"] as! [[String:Any]]
                self.rows = self.currentRows()
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                self.trimImages()
            }
        }
    }

    @objc func displayUpcomingEvents(sender: UIButton) {
        
        if displayingUpcoming || tableView.refreshControl!.isRefreshing || cancel.superview != nil { return }
        displayingUpcoming = true
        
        if selectButton.superview != nil {
            selectButton.removeFromSuperview()
        }
        
        rows = currentRows()
        tableView.reloadData()
    }
    
    @objc func displayPastEvents(sender: UIButton) {
        
        if !displayingUpcoming || tableView.refreshControl!.isRefreshing { return }
        displayingUpcoming = false
        
        if defaults.bool(forKey: "admin") && !pastRows.isEmpty {
            navBar.addSubview(selectButton)
        }
        
        rows = currentRows()
        tableView.reloadData()
    }
    
    override func sliderTapped(sender: UIButton) {
        if cancel.superview != nil {
            cancelSelect(sender: cancel)
        }
        showSideMenu()
    }
}

// MARK: UITableViewDelegate methods

extension EventVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            let TOGGLE_HEIGHT = view.frame.height/20
            let TOGGLE_WIDTH = view.frame.width/4
            
            let upcoming = UIButton(frame: CGRect(x: cellWidth/2 - TOGGLE_WIDTH - 2,
                                                  y: view.frame.height/20 - TOGGLE_HEIGHT/2,
                                                  width: TOGGLE_WIDTH, height: TOGGLE_HEIGHT))
            
            if displayingUpcoming {
                upcoming.backgroundColor = redColor
            } else {
                upcoming.backgroundColor = highlightColor
            }
            
            upcoming.layer.cornerRadius = TOGGLE_HEIGHT/5
            upcoming.setBackgroundImage(roundedImage(color: redColor, width: TOGGLE_WIDTH, height: TOGGLE_HEIGHT,
                                                     cornerRadius: upcoming.layer.cornerRadius),
                                        for: .highlighted)
            upcoming.setTitle("Upcoming", for: .normal)
            upcoming.titleLabel?.font = UIFont(name: "Baskerville", size: TOGGLE_WIDTH/5)
            upcoming.layer.borderWidth = TOGGLE_HEIGHT/20
            upcoming.layer.borderColor = redColor.cgColor
            upcoming.addTarget(self, action: #selector(self.displayUpcomingEvents), for: .touchUpInside)
            
            let past = UIButton(frame: CGRect(x: cellWidth/2 + 2, y: view.frame.height/20 - TOGGLE_HEIGHT/2,
                                              width: TOGGLE_WIDTH, height: TOGGLE_HEIGHT))
            
            if displayingUpcoming {
                past.backgroundColor = highlightColor
            } else {
                past.backgroundColor = redColor
            }
            
            past.layer.cornerRadius = TOGGLE_HEIGHT/5
            past.setBackgroundImage(roundedImage(color: redColor, width: TOGGLE_WIDTH, height: TOGGLE_HEIGHT,
                                                 cornerRadius: past.layer.cornerRadius),
                                    for: .highlighted)
            past.setTitle("Past", for: .normal)
            past.titleLabel?.font = UIFont(name: "Baskerville", size: TOGGLE_WIDTH/5)
            past.layer.borderWidth = TOGGLE_HEIGHT/20
            past.layer.borderColor = redColor.cgColor
            past.addTarget(self, action: #selector(self.displayPastEvents), for: .touchUpInside)
            
            let headerView = UIView()
            headerView.backgroundColor = .clear
            headerView.addSubview(upcoming)
            headerView.addSubview(past)
            return headerView
            
        } else {
            let view = UIView()
            view.backgroundColor = .clear
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if rows.isEmpty {
            return cellHeight*1.1
        }
        
        let data = rows[indexPath.row]

        if let _ = data["image"] as? NSNull {
            return cellHeight*1.1
        } else {
            return cellHeight*3.1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return view.frame.height/10
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if cancel.superview != nil && tableView.indexPathsForSelectedRows == nil {
            deleteButton.removeFromSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if cancel.superview == nil {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let data = rows[indexPath.row]
            
            hostVC.slider.removeFromSuperview()
            createButton.removeFromSuperview()
            selectButton.removeFromSuperview()
            
            let displayEvent = DisplayEventVC()
            displayEvent.data = data
            navigationController!.pushViewController(displayEvent, animated: true)
        } else {
            
            if deleteButton.superview == nil {
                view.addSubview(deleteButton)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        let cell = tableView.cellForRow(at: indexPath) as? EventCell
        cell?.highlightView()
        return true
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {

        let cell = tableView.cellForRow(at: indexPath) as? EventCell
        
        if !tableView.cellForRow(at: indexPath)!.isSelected {
            cell?.unhighlightView()
        }
    }
}
    
// MARK: UITableViewDataSource methods
    
extension EventVC: UITableViewDataSource {
    
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
        } else {
            return rows.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if rows.isEmpty {
            let cell = EmptyCell()
            var text: String
            
            if displayingUpcoming {
                text = "No upcoming events to display"
            } else {
                text = "No past events to display"
            }
            
            cell.load(width: cellWidth, height: cellHeight/4, text: text)
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        let data = rows[indexPath.row]
        let cell = EventCell()
        cell.width = cellWidth
        cell.height = cellHeight
        cell.load(data: data)
        return cell
    }
}
