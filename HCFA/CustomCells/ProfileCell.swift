//
//  ProfileCell.swift
//  HCFA
//
//  Created by Collin Price on 7/26/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//


import UIKit

class ProfileCell: UITableViewCell {
    
    var cellWidth: CGFloat!
    var cellHeight: CGFloat!
    let picture = UIImageView()
    let name = UILabel()
    
    func load() {
        frame = CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight)
        backgroundColor = .clear
        layoutMargins = UIEdgeInsets.zero
        
        let colorView = UIView(frame: frame)
        colorView.backgroundColor = .clear
        selectedBackgroundView = colorView
        
        picture.frame = CGRect(x: cellWidth*0.2625, y: UIApplication.shared.statusBarFrame.height + cellHeight/40,
                               width: cellWidth*0.475, height: cellWidth*0.475)
        picture.image = UIImage(named: "generic")
        picture.contentMode = .scaleAspectFill
        picture.layer.cornerRadius = picture.frame.width/2
        picture.layer.masksToBounds = true
        addSubview(picture)
        
        DispatchQueue.main.async {
            if let urlString = defaults.string(forKey: "image") {
                if let url = URL(string: urlString) {
                    downloadImage(url: url, view: self.picture)
                }
            }
        }
        
        let y = picture.frame.origin.y + picture.frame.height
        
        name.frame = CGRect(x: 0, y: y, width: cellWidth, height: (cellHeight - y)*0.8)
        name.text = "\(defaults.string(forKey: "first")!) \(defaults.string(forKey: "last")!)"
        name.textColor = .black
        name.font = UIFont(name: "Montserrat-Regular", size: cellWidth*0.0675) ??
            UIFont.systemFont(ofSize: cellWidth*0.0675)
        name.textAlignment = .center
        name.baselineAdjustment = .alignBaselines
        addSubview(name)
    }
    
    // hide top separator inset
    override func layoutSubviews() {
        super.layoutSubviews()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight*0.05))
        view.backgroundColor = sideMenuColor
        addSubview(view)
    }
}

