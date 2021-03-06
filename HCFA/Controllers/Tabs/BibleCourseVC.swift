//
//  BibleCourseVC.swift
//  HCFA
//
//  Created by Collin Price on 1/6/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit

class BibleCourseVC: TemplateVC {
    
    var filter: UIBarButtonItem!
    var cellWidth: CGFloat!
    var cellHeight: CGFloat!
    
    var rows: [[String:Any]] = []
    var yourRows: [[String:Any]] = []
    var freshmanMen: [[String:Any]] = []
    var freshmanWomen: [[String:Any]] = []
    var sophomoreMen: [[String:Any]] = []
    var sophomoreWomen: [[String:Any]] = []
    var juniorMen: [[String:Any]] = []
    var juniorWomen: [[String:Any]] = []
    var seniorMen: [[String:Any]] = []
    var seniorWomen: [[String:Any]] = []
    
    var userCourses: [Int] = []
    var adminCourses: [Int] = []
    var displayingYear = Year.All
    var displayingGender = Gender.Both
    var displayingYours = true
    var firstAppearance = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barHeight = navigationController!.navigationBar.frame.height
        let BUTTON_LENGTH = barHeight*0.6
        
        let filterButton = UIButton(frame: CGRect(x: 0, y: 0, width: BUTTON_LENGTH, height: BUTTON_LENGTH))
        filterButton.setImage(UIImage(named: "filter"), for: .normal)
        filterButton.setImage(UIImage(named: "filter")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        filterButton.tintColor = barHighlightColor
        filterButton.imageView?.contentMode = .scaleAspectFit
        filterButton.addTarget(self, action: #selector(toggleFilter), for: .touchUpInside)
        if defaults.bool(forKey: "admin") {
            filterButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        } else {
            filterButton.widthAnchor.constraint(equalToConstant: 28).isActive = true
        }
        filterButton.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        filter = UIBarButtonItem(customView: filterButton)
        
        let offset = barHeight + UIApplication.shared.statusBarFrame.height
        cellWidth = view.frame.width
        
        if IS_IPHONE_X {
            cellHeight = view.frame.height*0.13
        } else {
            cellHeight = view.frame.height*0.15
        }
        
        let refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0))
        refreshControl.tintColor = highlightColor
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        
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
        view.addSubview(upButton)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstAppearance {
            startRefreshControl()
            refresh()
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = "BCs"
        hostVC.navigationItem.backBarButtonItem = backItem
        hostVC.navigationItem.title = "Bible Courses"
        
        if defaults.bool(forKey: "admin") {
            if !displayingYours {
                hostVC.navigationItem.rightBarButtonItems = [hostVC.create, filter]
            } else {
                hostVC.navigationItem.rightBarButtonItem = hostVC.create
            }
            hostVC.createButton.addTarget(self, action: #selector(create), for: .touchUpInside)
        } else {
            if !displayingYours {
                hostVC.navigationItem.rightBarButtonItem = filter
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if defaults.bool(forKey: "admin") {
            hostVC.createButton.removeTarget(self, action: #selector(create), for: .touchUpInside)
        }
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
    
    func getHeaderTextBySection(_ section: Int) -> String {
        let year = getYearBySection(section).uppercased()
        
        switch displayingGender {
        case .Men:
            return "\(year) MEN"
        case .Women:
            return "\(year) WOMEN"
        default:
            if section % 2 == 0 {
                return "\(year) MEN"
            }
            return "\(year) WOMEN"
        }
    }
    
    func getYearBySection(_ section: Int) -> String {
        
        switch displayingYear {
        case .Freshman:
            return "Freshman"
        case .Sophomore:
            return "Sophomore"
        case .Junior:
            return "Junior"
        case .Senior:
            return "Senior"
        default:
            if displayingGender == .Both {
                switch section {
                case 0, 1: return "Freshman"
                case 2, 3: return "Sophomore"
                case 4, 5: return "Junior"
                default: return "Senior"
                }
            } else {
                switch section {
                case 0: return "Freshman"
                case 1: return "Sophomore"
                case 2: return "Junior"
                default: return "Senior"
                }
            }
        }
    }
    
    func getRowsBySection(_ section: Int) -> [[String:Any]?] {
        
        if displayingGender == .Men {
            switch displayingYear {
            case .Freshman:
                return freshmanMen
            case .Sophomore:
                return sophomoreMen
            case .Junior:
                return juniorMen
            case .Senior:
                return seniorMen
            default:
                switch section {
                case 0:
                    return freshmanMen
                case 1:
                    return sophomoreMen
                case 2:
                    return juniorMen
                default:
                    return seniorMen
                }
            }
            
        } else if displayingGender == .Women {
            switch displayingYear {
            case .Freshman:
                return freshmanWomen
            case .Sophomore:
                return sophomoreWomen
            case .Junior:
                return juniorWomen
            case .Senior:
                return seniorWomen
            default:
                switch section {
                case 0:
                    return freshmanWomen
                case 1:
                    return sophomoreWomen
                case 2:
                    return juniorWomen
                default:
                    return seniorWomen
                }
            }
        }
        
        switch displayingYear {
        case .Freshman:
            if section == 0 { return freshmanMen } else { return freshmanWomen }
        case .Sophomore:
            if section == 0 { return sophomoreMen } else { return sophomoreWomen }
        case .Junior:
            if section == 0 { return juniorMen } else { return juniorWomen }
        case .Senior:
            if section == 0 { return seniorMen } else { return seniorWomen }
        default:
            switch section {
            case 0:
                return freshmanMen
            case 1:
                return freshmanWomen
            case 2:
                return sophomoreMen
            case 3:
                return sophomoreWomen
            case 4:
                return juniorMen
            case 5:
                return juniorWomen
            case 6:
                return seniorMen
            default:
                return seniorWomen
            }
        }
    }
    
    func filterRowsByYear(_ year: String) -> [[String:Any]] {
        return rows.filter({ ($0["year"] as! String) == year })
    }
    
    func filterByGender(_ rows: [[String:Any]], _ gender: String) -> [[String:Any]] {
        return rows.filter({ ($0["gender"] as! String) == gender })
    }
    
    func setSectionRows() {
        yourRows = rows.filter({ userCourses.contains($0["cid"] as! Int) })
        
        let freshmen = filterRowsByYear("Freshman")
        let sophomores = filterRowsByYear("Sophomore")
        let juniors = filterRowsByYear("Junior")
        let seniors = filterRowsByYear("Senior")
        
        freshmanMen = filterByGender(freshmen, "Men")
        freshmanWomen = filterByGender(freshmen, "Women")
        sophomoreMen = filterByGender(sophomores, "Men")
        sophomoreWomen = filterByGender(sophomores, "Women")
        juniorMen = filterByGender(juniors, "Men")
        juniorWomen = filterByGender(juniors, "Women")
        seniorMen = filterByGender(seniors, "Men")
        seniorWomen = filterByGender(seniors, "Women")
    }
    
    func emptyTable() {
        rows = []
        yourRows = []
        setSectionRows()
        tableView.reloadData()
    }
    
    @objc func create() {
        navigationController!.pushViewController(CreateBibleCourseVC(), animated: true)
    }
    
    @objc func displayUsersBCs() {
        if displayingYours || tableView.refreshControl!.isRefreshing { return }
        displayingYours = true
        
        if defaults.bool(forKey: "admin") {
            hostVC.navigationItem.rightBarButtonItems = [hostVC.create]
        } else {
            hostVC.navigationItem.rightBarButtonItems = nil
        }
        
        tableView.reloadData()
    }
    
    @objc func displayBCs() {
        if !displayingYours || tableView.refreshControl!.isRefreshing { return }
        displayingYours = false
        
        if defaults.bool(forKey: "admin") {
            hostVC.navigationItem.rightBarButtonItems = [hostVC.create, filter]
        } else {
            hostVC.navigationItem.rightBarButtonItem = filter
        }
        
        tableView.reloadData()
    }
    
    @objc func refresh() {
        
        API.getCourses(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!) {
            response, data in
            
            if self.firstAppearance {
                self.firstAppearance = false
            } else {
                URLCache.shared.removeAllCachedResponses()
            }

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
                self.rows = data["courses"] as! [[String:Any]]
                
                let coursesDict = data["user_courses"] as! [String:Any]
                self.adminCourses = (coursesDict["admin"] as! [Int])
                self.userCourses = (coursesDict["member"] as! [Int]) + self.adminCourses
                self.setSectionRows()
                
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc func toggleFilter() {
        navigationController!.pushViewController(FilterVC(), animated: true)
    }
}

// MARK: UITableViewDelegate methods

extension BibleCourseVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {

            let your = UIButton(frame: CGRect(x: cellWidth/2 - TOGGLE_WIDTH - 2,
                                              y: view.frame.height/20 - TOGGLE_HEIGHT/2,
                                              width: TOGGLE_WIDTH, height: TOGGLE_HEIGHT))
            
            if displayingYours {
                your.backgroundColor = redColor
            } else {
                your.backgroundColor = highlightColor
            }
            
            your.layer.cornerRadius = view.frame.height*0.015
            your.setBackgroundImage(roundedImage(color: redColor, width: TOGGLE_WIDTH, height: TOGGLE_HEIGHT, cornerRadius: your.layer.cornerRadius), for: .highlighted)
            your.setTitle("MY COURSES", for: .normal)
            your.titleLabel?.font = toggleFont
            your.addTarget(self, action: #selector(displayUsersBCs), for: .touchUpInside)
            
            let all = UIButton(frame: CGRect(x: cellWidth/2 + 2, y: view.frame.height/20 - TOGGLE_HEIGHT/2,
                                              width: TOGGLE_WIDTH, height: TOGGLE_HEIGHT))
            
            if displayingYours {
                all.backgroundColor = highlightColor
            } else {
                all.backgroundColor = redColor
            }
            
            all.layer.cornerRadius = view.frame.height*0.015
            all.setBackgroundImage(roundedImage(color: redColor, width: TOGGLE_WIDTH, height: TOGGLE_HEIGHT,
                                                 cornerRadius: all.layer.cornerRadius), for: .highlighted)
            
            all.setTitle("ALL COURSES", for: .normal)
            all.titleLabel?.font = toggleFont
            all.addTarget(self, action: #selector(displayBCs), for: .touchUpInside)
            
            let headerView = UIView()
            headerView.backgroundColor = .clear
            headerView.addSubview(your)
            headerView.addSubview(all)
            
            if !displayingYours && !rows.isEmpty {

                let firstSection = UILabel(frame: CGRect(x: cellWidth/2 - view.frame.width/2,
                                                         y: view.frame.height/12,
                                                         width: view.frame.width, height: view.frame.height/20))
                let font = UIFont(name: "Montserrat-Regular", size: view.frame.width*0.042) ??
                    UIFont.systemFont(ofSize: view.frame.width*0.042)
                let text = getHeaderTextBySection(section)
                let underline = NSMutableAttributedString(string: text)
                underline.addAttribute(NSAttributedString.Key.underlineStyle, value: 1,
                                       range: NSMakeRange(0, underline.length))
                firstSection.attributedText = underline
                firstSection.font = font
                firstSection.textAlignment = .center
                firstSection.baselineAdjustment = .alignCenters
                firstSection.textColor = .darkGray
                
                headerView.addSubview(firstSection)
            }
            
            return headerView
            
        } else if !displayingYours {
            
            let sectionView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width,
                                                   height: view.frame.height/10 + view.frame.height/30))
            sectionView.backgroundColor = .clear
            
            let nextSection = UILabel(frame: CGRect(x: cellWidth/2 - view.frame.width/2, y: -cellHeight/20,
                                                    width: view.frame.width, height: view.frame.height/20))
            let font = UIFont(name: "Montserrat-Regular", size: view.frame.width*0.041) ??
                UIFont.systemFont(ofSize: view.frame.width*0.041)
            let text = getHeaderTextBySection(section)
            let underline = NSMutableAttributedString(string: text)
            underline.addAttribute(NSAttributedString.Key.underlineStyle, value: 1,
                                   range: NSMakeRange(0, underline.length))
            nextSection.attributedText = underline
            nextSection.font = font
            nextSection.textAlignment = .center
            nextSection.baselineAdjustment = .alignCenters
            nextSection.textColor = .darkGray
            sectionView.addSubview(nextSection)
            
            return sectionView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if rows.isEmpty || !displayingYours && getRowsBySection(indexPath.section).isEmpty {
            return cellHeight/2
        }
        return cellHeight*1.1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            if displayingYours || rows.isEmpty {
                return view.frame.height/10
            } else {
                return view.frame.height/10 + view.frame.height/30
            }
        }
        if displayingYours {
            return view.frame.height/60
        } else {
            return view.frame.height/60 + view.frame.height/30
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var currentRows: [[String:Any]?]
        if displayingYours {
            currentRows = yourRows
        } else {
            currentRows = getRowsBySection(indexPath.section)
        }
        
        if let data = currentRows[indexPath.row] {

            let cid = data["cid"] as! Int
            
            let displayBC = DisplayBibleCourseVC()
            
            if userCourses.contains(cid) {
                displayBC.joined = true
            }
            if adminCourses.contains(cid) || defaults.bool(forKey: "admin") {
                displayBC.admin = true
            }
            
            displayBC.data = data
            navigationController!.pushViewController(displayBC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let cell = tableView.cellForRow(at: indexPath) as? BibleCourseCell
        cell?.highlightView()
        return true
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? BibleCourseCell
        cell?.unhighlightView()
    }
}

// MARK: UITableViewDataSource methods

extension BibleCourseVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if rows.isEmpty && firstAppearance {
            return 0
        }
        
        if rows.isEmpty || displayingYours {
            return 1
        }
        
        if displayingGender == .Both {
            if displayingYear == .All { return 8 } else { return 2 }
        } else {
            if displayingYear == .All { return 4 } else { return 1 }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if displayingYours {
            if yourRows.isEmpty {
                return 1
            } else {
                return yourRows.count
            }
        } else {
            let currentRows = getRowsBySection(section)
            if currentRows.isEmpty { return 1 }
            return currentRows.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if displayingYours {
            if yourRows.isEmpty {
                let cell = EmptyCell()
                cell.load(width: cellWidth, height: cellHeight/4, text: "You are not in any bible courses",
                          color: .gray, font: displayFont)
                cell.isUserInteractionEnabled = false
                return cell
            }
            
            let data = yourRows[indexPath.row]
            let cell = BibleCourseCell()
            cell.width = cellWidth
            cell.height = cellHeight
            cell.load(data: data)
            return cell
            
        } else {
            if rows.isEmpty {
                let cell = EmptyCell()
                cell.load(width: cellWidth, height: cellHeight/4, text: "No bible courses to display",
                          color: .gray, font: displayFont)
                cell.isUserInteractionEnabled = false
                return cell
            }
            
            let currentRows = getRowsBySection(indexPath.section)
            if currentRows.isEmpty {
                let cell = EmptyCell()
                let font = UIFont(name: "Montserrat-Regular", size: cellWidth*0.05) ??
                    UIFont.systemFont(ofSize: cellWidth*0.05)
                cell.load(width: cellWidth, height: cellHeight/4, text: "Bible courses TBD",
                          color: redColor, font: font)
                cell.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                return cell
            }
            
            let data = currentRows[indexPath.row]
            let cell = BibleCourseCell()
            cell.width = cellWidth
            cell.height = cellHeight
            cell.load(data: data!)
            return cell
        }
    }
}
