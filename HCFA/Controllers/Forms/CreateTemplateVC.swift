//
//  CreateTemplateVC.swift
//  HCFA
//
//  Created by Collin Price on 7/14/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import Eureka

class CreateTemplateVC: FormViewController {

    var navBar: UINavigationBar!
    var hostVC: HostVC!
    var loadingView: LoadingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = lightColor
        navigationAccessoryView.barTintColor = redColor
        navBar = navigationController!.navigationBar
        hostVC = navigationController?.viewControllers.first as! HostVC
        
        loadingView = LoadingView(frame: CGRect(x: view.frame.width*0.375,
                                                y: view.frame.height/2 - view.frame.width*0.125,
                                                width: view.frame.width*0.25, height: view.frame.width*0.25))
    }
    
    func startLoading() {
        view.addSubview(loadingView)
        navBar.isUserInteractionEnabled = false
        tableView.isUserInteractionEnabled = false
    }
    
    func stopLoading() {
        loadingView.removeFromSuperview()
        navBar.isUserInteractionEnabled = true
        tableView.isUserInteractionEnabled = true
    }
    
    func backToSignIn() {
        resetDefaults()
        let signInVC = navigationController!.presentingViewController!
        dismiss(animated: true, completion: {
            createAlert(title: "Session Expired", message: "", view: signInVC)
        })
    }
    
    func getMultivaluedSectionValues(_ tag: String) -> [String] {
        let values = form.values()
        var list: [String] = []
        
        for (key, value) in values {
            if key.contains(tag) {
                if let value = value as? String {
                    list.append(value)
                }
            }
        }
        
        return list
    }
}
