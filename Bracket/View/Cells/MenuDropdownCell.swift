//
//  MenuDropdownCell.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/25/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit


class MenuDropdownCell: BaseCell {
    
    let pairingLabel: UILabel = {
        let label = GenericLabel("", .center, fontLight(15), MainPageOptions().navigationTitleColor)
        label.backgroundColor = MainPageOptions().backgroundColor
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let separator = GenericUnderline(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.5), alpha: 0.5)
    
    let separatorBottom = GenericUnderline(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.5), alpha: 0.5)
    
    let mainPageOptions = MainPageOptions()
    
    override func addViews() {
        
        addSubview(pairingLabel)
        addSubview(separator)
        addSubview(separatorBottom)
        setupViewConstraints(format: "H:|[v0]|", views: pairingLabel)
        setupViewConstraints(format: "V:|[v0]|", views: pairingLabel)
        setupViewConstraints(format: "H:[v0(1)]|", views: separator)
        setupViewConstraints(format: "V:|[v0]|", views: separator)
        setupViewConstraints(format: "H:|-10-[v0]-10-|", views: separatorBottom)
        setupViewConstraints(format: "V:[v0(1)]|", views: separatorBottom)
        
    }
    
}
