//
//  TemplateVC.swift
//  HCFA
//
//  Created by Collin Price on 1/4/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit

class TemplateVC: UIViewController {
    
    let upButton = UIButton()
    let toggleFont = UIFont(name: "Montserrat-Regular", size: UIScreen.main.bounds.width*0.035) ??
        UIFont.systemFont(ofSize: UIScreen.main.bounds.width*0.035)

    var hostVC: HostVC!
    var tableView: UITableView!
    var showingUpButton = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = lightColor
        hostVC = (navigationController?.viewControllers.first as! HostVC)
        
        let barHeight = navigationController!.navigationBar.frame.height
        let BUTTON_LENGTH = barHeight*0.6
        let offset = barHeight + UIApplication.shared.statusBarFrame.height
        
        upButton.frame = CGRect(x: view.frame.width, y: offset*1.2,
                                width: BUTTON_LENGTH*1.1, height: BUTTON_LENGTH*1.1)
        upButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.8)
        upButton.layer.cornerRadius = upButton.frame.width/2
        
        let arrow = UIImage(named: "arrow")
        upButton.setImage(arrow, for: .normal)
        upButton.setImage(arrow, for: .highlighted)
        upButton.contentMode = .scaleAspectFit
        upButton.addTarget(self, action: #selector(toTop), for: .touchDown)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hostVC.navigationItem.leftBarButtonItem = hostVC.slider
        hostVC.navigationItem.rightBarButtonItems = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldShowUpButton() {
            showUpButton()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if showingUpButton {
            hideUpButton()
        }
    }
    
    func backToSignIn() {
        resetDefaults()
        let signInVC = navigationController!.presentingViewController!
        dismiss(animated: true, completion: {
            createAlert(title: "Session Expired", message: "", view: signInVC)
        })
    }
    
    func shouldShowUpButton() -> Bool {
        return tableView.contentOffset.y >= tableView.frame.height/2 && !showingUpButton
    }
    
    func shouldHideUpButton() -> Bool {
        return tableView.contentOffset.y < tableView.frame.height/2 && showingUpButton
    }
    
    func showUpButton() {
        showingUpButton = true
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.upButton.transform = CGAffineTransform(translationX: -self.upButton.frame.width*1.5, y: 0)
        }, completion: {_ in })
    }
    
    func hideUpButton() {
        showingUpButton = false
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.2)
        UIView.setAnimationCurve(.linear)
        UIView.setAnimationBeginsFromCurrentState(true)
        upButton.transform = CGAffineTransform(translationX: upButton.frame.width*1.5, y: 0)
        UIView.commitAnimations()
    }
    
    @objc func toTop() {
        tableView.setContentOffset(CGPoint.zero, animated: true)
        hideUpButton()
    }
}

extension TemplateVC: UIScrollViewDelegate {
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollingFinish()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingFinish()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollingFinish()
        }
    }
    
    func scrollingFinish() -> Void {
        if shouldShowUpButton() {
            showUpButton()
        } else if shouldHideUpButton() {
            hideUpButton()
        }
    }
}
