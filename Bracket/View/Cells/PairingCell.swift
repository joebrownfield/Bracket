//
//  PairingCell.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/5/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit

class PairingCell: BaseCell {
    
    let pairingLabel = GenericLabel("Label", .center, fontLight(15), MainPageOptions().labelColor)
    
    let underlineView = GenericView(color: MainPageOptions().tabBarColor, alpha: 1)
    
    let mainPageOptions = MainPageOptions()
    
    override var isHighlighted: Bool {
        didSet {
            pairingLabel.textColor = isHighlighted ? mainPageOptions.tabBarColor : mainPageOptions.labelColor
            underlineView.isHidden = isHighlighted ? false : true
        }
    }
    
    override var isSelected: Bool {
        didSet {
            pairingLabel.textColor = isSelected ? mainPageOptions.tabBarColor : mainPageOptions.labelColor
            underlineView.isHidden = isSelected ? false : true
        }
    }
    
    override func addViews() {
        
        addSubview(pairingLabel)
        addSubview(underlineView)
        
        underlineView.isHidden = true
        
        backgroundColor = mainPageOptions.tabBarTintColor
        
        setupViewConstraints(format: "H:|[v0]|", views: pairingLabel)
        setupViewConstraints(format: "V:|[v0]|", views: pairingLabel)
        
        setupViewConstraints(format: "H:|[v0]|", views: underlineView)
        setupViewConstraints(format: "V:[v0(2)]|", views: underlineView)
    }
}
