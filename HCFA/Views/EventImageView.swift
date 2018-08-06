//
//  eventImageView.swift
//  HCFA
//
//  Created by Collin Price on 8/5/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import UIKit

class EventImageView: UIImageView {
    
    let spinner = UIActivityIndicatorView()
    let reload = UIButton()
    var eid: Int!
    var imageString: String!
    var isCell: Bool!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = frame.width/40
        layer.masksToBounds = true
        contentMode = .scaleAspectFill
        
        spinner.activityIndicatorViewStyle = .whiteLarge
        spinner.center = CGPoint(x: frame.width/2, y: frame.height/2)
    }
    
    func initializeReload() {
        if isCell {
            reload.frame = CGRect(x: 0, y: frame.height*0.4,
                                  width: frame.width, height: frame.height*0.2)
            reload.setTitle("Refresh Page", for: .normal)
            reload.setTitleColor(.white, for: .normal)
            reload.titleLabel?.baselineAdjustment = .alignCenters
            reload.titleLabel?.font = UIFont(name: "Baskerville", size: frame.width/16)
        } else {
            reload.frame = CGRect(x: frame.width*0.35, y: frame.height*0.3,
                                  width: frame.width*0.3, height: frame.width*0.3)
            reload.setImage(UIImage(named: "reload"), for: .normal)
            reload.addTarget(self, action: #selector(download), for: .touchUpInside)
        }
    }
    
    func displayReload() {
        spinner.removeFromSuperview()
        
        if !isCell {
            isUserInteractionEnabled = true
        }
        addSubview(reload)
    }
    
    @objc func download() {
        reload.removeFromSuperview()
        isUserInteractionEnabled = false
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        spinner.startAnimating()
        addSubview(spinner)
        
        if let url = URL(string: imageString) {
            getDataFromUrl(url: url) { data, response, error in
                guard let data = data, error == nil else {
                    return self.displayReload()
                }
                
                DispatchQueue.main.async() {
                    self.spinner.removeFromSuperview()
                    
                    if let image = UIImage(data: data) {
                        self.image = image
                        self.backgroundColor = .clear
                        updateEventImages(self.eid, data)
                    } else {
                        self.displayReload()
                    }
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
}
