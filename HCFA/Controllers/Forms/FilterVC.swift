//
//  FilterVC.swift
//  HCFA
//
//  Created by Collin Price on 7/23/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import Eureka

class FilterVC: FormViewController {
    
    var hostVC: HostVC!
    var courseVC: BibleCourseVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = lightColor
        hostVC = navigationController?.viewControllers.first as! HostVC
        courseVC = hostVC.contentViewControllers[Tabs.BibleCourses] as! BibleCourseVC
        
        var gender: String!
        switch courseVC.displayingGender {
        case .Men:
            gender = "Men"
        case .Women:
            gender = "Women"
        default:
            gender = "Both"
        }
        
        var year: String!
        switch courseVC.displayingYear {
        case .Freshman:
            year = "Freshman"
        case .Sophomore:
            year = "Sophomore"
        case .Junior:
            year = "Junior"
        case .Senior:
            year = "Senior"
        default:
            year = "All"
        }
        
        let genderSection =
            SelectableSection<ListCheckRow<String>>("Gender",
                                                    selectionType: .singleSelection(enableDeselection: false))
        form +++ genderSection
        
        for option in ["Both", "Men", "Women"] {
            form.last! <<< ListCheckRow<String>(option){ listRow in
                listRow.title = option
                listRow.selectableValue = option
                
                if option == gender {
                    listRow.value = gender
                }
            }
        }
    
        
        let yearSection =
            SelectableSection<ListCheckRow<String>>("Year",
                                                    selectionType: .singleSelection(enableDeselection: false))
        form +++ yearSection
        
        for option in ["All", "Freshman", "Sophomore", "Junior", "Senior"] {
            form.last! <<< ListCheckRow<String>(option){ listRow in
                listRow.title = option
                listRow.selectableValue = option
                
                if option == year {
                    listRow.value = year
                }
            }
        }
        
        genderSection.tag = "gender"
        yearSection.tag = "year"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Filter Bible Courses"
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItems = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let gender = (form.sectionBy(tag: "gender") as!
            SelectableSection<ListCheckRow<String>>).selectedRow()?.value!
        let year = (form.sectionBy(tag: "year") as!
            SelectableSection<ListCheckRow<String>>).selectedRow()?.value!
        
        switch gender {
        case "Men":
            courseVC.displayingGender = .Men
        case "Women":
            courseVC.displayingGender = .Women
        default:
            courseVC.displayingGender = .Both
        }
        
        switch year {
        case "Freshman":
            courseVC.displayingYear = .Freshman
        case "Sophomore":
            courseVC.displayingYear = .Sophomore
        case "Junior":
            courseVC.displayingYear = .Junior
        case "Senior":
            courseVC.displayingYear = .Senior
        default:
            courseVC.displayingYear = .All
        }

        courseVC.tableView.reloadData()
    }
}
