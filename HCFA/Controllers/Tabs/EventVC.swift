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
    
    let deleteButton = UIButton()
    
    var select: UIBarButtonItem!
    var cancel: UIBarButtonItem!
    var loadingView: LoadingView!
    var cellWidth: CGFloat!
    var cellHeight: CGFloat!
    var rows: [[String:Any]] = []
    var upcomingRows: [[String:Any]] = []
    var pastRows: [[String:Any]] = []
    var displayingUpcoming = true
    var firstAppearance = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cellWidth = view.frame.width
        
        if IS_IPHONE_X {
            cellHeight = view.frame.height*0.13
        } else {
            cellHeight = view.frame.height*0.15
        }
        
        let barHeight = navigationController!.navigationBar.frame.height
        let BUTTON_LENGTH = barHeight*0.6
        let selectButton = UIButton(frame: CGRect(x: view.frame.width - BUTTON_LENGTH*3,
                                                  y: (barHeight-BUTTON_LENGTH)/2,
                                                  width: BUTTON_LENGTH, height: BUTTON_LENGTH))
        selectButton.setImage(UIImage(named: "select"), for: .normal)
        selectButton.setImage(UIImage(named: "select")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        selectButton.tintColor = barHighlightColor
        selectButton.imageView?.contentMode = .scaleAspectFit
        selectButton.addTarget(self, action: #selector(selectRows), for: .touchUpInside)
        selectButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        selectButton.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        select = UIBarButtonItem(customView: selectButton)
        cancel = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelSelect))
        
        let refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0))
        refreshControl.tintColor = highlightColor
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        
        let offset = barHeight + UIApplication.shared.statusBarFrame.height
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
        
        let font = UIFont(name: "Montserrat-Regular", size: view.frame.width*0.0375) ??
            UIFont.systemFont(ofSize: view.frame.width*0.0375)
        deleteButton.frame = CGRect(x: view.frame.width/40, y: view.frame.height - offset,
                                    width: view.frame.width*0.95, height: offset*0.8)
        deleteButton.layer.cornerRadius = deleteButton.frame.width/20
        deleteButton.backgroundColor = UIColor(red: 0.9, green: 0.87, blue: 0.87, alpha: 1.0)
        deleteButton.setBackgroundImage(roundedImage(color: UIColor(red: 0.8, green: 0.78, blue: 0.78, alpha: 1.0),
                                                     width: deleteButton.frame.width,
                                                     height: deleteButton.frame.height,
                                                     cornerRadius: deleteButton.layer.cornerRadius),
                                        for: .highlighted)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.titleLabel?.font = font
        deleteButton.addTarget(self, action: #selector(deleteSelected), for: .touchUpInside)
    
        loadingView = LoadingView(frame: CGRect(x: view.frame.width*0.375,
                                                y: view.frame.height/2 - view.frame.width*0.125,
                                                width: view.frame.width*0.25, height: view.frame.width*0.25))
        view.addSubview(upButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if firstAppearance {
            startRefreshControl()
            refresh()
        }
        
        hostVC.navigationItem.title = "Events"
        
        let backItem = UIBarButtonItem()
        backItem.title = hostVC.navigationItem.title
        hostVC.navigationItem.backBarButtonItem = backItem

        if defaults.bool(forKey: "admin") || defaults.bool(forKey: "leader") {
            if !displayingUpcoming {
                hostVC.navigationItem.rightBarButtonItems = [hostVC.create, select]
            } else {
                hostVC.navigationItem.rightBarButtonItem = hostVC.create
            }
            hostVC.createButton.addTarget(self, action: #selector(create), for: .touchUpInside)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if tableView.allowsMultipleSelection {
            cancelSelect()
        }
        
        if defaults.bool(forKey: "admin") || defaults.bool(forKey: "leader") {
            hostVC.createButton.removeTarget(self, action: #selector(create), for: .touchUpInside)
        }
    }
    
    func startRefreshControl() {
        tableView.setContentOffset(CGPoint(x: 0, y: -(tableView.refreshControl?.frame.size.height)!),
                                   animated: false)
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
    
    @objc func create() {
        navigationController!.pushViewController(CreateEventVC(), animated: true)
    }
    
    @objc func selectRows() {
        hostVC.navigationItem.rightBarButtonItems = [cancel]
        tableView.allowsMultipleSelection = true
    }
    
    @objc func cancelSelect() {
        hostVC.navigationItem.rightBarButtonItems = [hostVC.create, select]
        tableView.allowsMultipleSelection = false
        deleteButton.removeFromSuperview()
    }
    
    @objc func deleteSelected() {
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
            self.navigationController!.navigationBar.isUserInteractionEnabled = false
            
            API.deleteEvents(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                             events: events, completionHandler: { response, data in
                                
                self.loadingView.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
                self.navigationController!.navigationBar.isUserInteractionEnabled = true
                self.cancelSelect()
                
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
                    self.refresh()
                    for eid in events {
                        deleteEventImage(eid)
                    }
                    
                    if events.count == self.rows.count {
                        self.hostVC.navigationItem.rightBarButtonItems = [self.hostVC.create]
                    }
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func refresh() {
        
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

    @objc func displayUpcomingEvents() {
        
        if displayingUpcoming || tableView.refreshControl!.isRefreshing { return }
        
        displayingUpcoming = true
        
        if defaults.bool(forKey: "admin") || defaults.bool(forKey: "leader") {
            hostVC.navigationItem.rightBarButtonItems = [hostVC.create]
        }
        
        rows = currentRows()
        tableView.reloadData()
    }
    
    @objc func displayPastEvents() {
        
        if !displayingUpcoming || tableView.refreshControl!.isRefreshing { return }
        displayingUpcoming = false
        
        if defaults.bool(forKey: "admin") || defaults.bool(forKey: "leader") {
            if !pastRows.isEmpty {
                hostVC.navigationItem.rightBarButtonItems = [hostVC.create, select]
            } else {
                hostVC.navigationItem.rightBarButtonItem = hostVC.create
            }
        }
        
        rows = currentRows()
        tableView.reloadData()
    }
}

// MARK: UITableViewDelegate methods

extension EventVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            let upcoming = UIButton(frame: CGRect(x: cellWidth/2 - TOGGLE_WIDTH - 2,
                                                  y: view.frame.height/20 - TOGGLE_HEIGHT/2,
                                                  width: TOGGLE_WIDTH, height: TOGGLE_HEIGHT))
            
            if displayingUpcoming {
                upcoming.backgroundColor = redColor
            } else {
                upcoming.backgroundColor = highlightColor
            }
            
            upcoming.layer.cornerRadius = view.frame.height*0.015
            upcoming.setBackgroundImage(roundedImage(color: redColor, width: TOGGLE_WIDTH, height: TOGGLE_HEIGHT,
                                                     cornerRadius: upcoming.layer.cornerRadius),
                                        for: .highlighted)
            upcoming.setTitle("UPCOMING", for: .normal)
            upcoming.titleLabel?.font = toggleFont
            upcoming.addTarget(self, action: #selector(displayUpcomingEvents), for: .touchUpInside)
            
            let past = UIButton(frame: CGRect(x: cellWidth/2 + 2, y: view.frame.height/20 - TOGGLE_HEIGHT/2,
                                              width: TOGGLE_WIDTH, height: TOGGLE_HEIGHT))
            
            if displayingUpcoming {
                past.backgroundColor = highlightColor
            } else {
                past.backgroundColor = redColor
            }
            
            past.layer.cornerRadius = view.frame.height*0.015
            past.setBackgroundImage(roundedImage(color: redColor, width: TOGGLE_WIDTH, height: TOGGLE_HEIGHT,
                                                 cornerRadius: past.layer.cornerRadius),
                                    for: .highlighted)
            past.setTitle("PAST", for: .normal)
            past.titleLabel?.font = toggleFont
            past.addTarget(self, action: #selector(displayPastEvents), for: .touchUpInside)
            
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
        
        if tableView.allowsMultipleSelection && tableView.indexPathsForSelectedRows == nil {
            deleteButton.removeFromSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !tableView.allowsMultipleSelection {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let data = rows[indexPath.row]
            
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
            
            cell.load(width: cellWidth, height: cellHeight/4, text: text, color: .gray,
                      font: displayFont)
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
