//
//  MainCell.swift
//  Bracket
//
//  Created by Joseph Brownfield on 5/31/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit

class MainCell: BaseCell {
    
    let exchgLabel = GenericLabel("Label", .center, fontRegular(20), MainPageOptions().labelColor)
    
    let arrowIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "arrow")?.withRenderingMode(.alwaysTemplate)
        image.tintColor = MainPageOptions().labelColor
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    override func addViews() {
        
        let cvHeight = Int(MainPageOptions().cvHeight)
        addSubview(exchgLabel)
        addSubview(bottomSpace)
        addSubview(arrowIcon)
        setupViewConstraints(format: "H:|-" + cvSpacing + "-[v0]-" + cvSpacing + "-|", views: exchgLabel)
        setupViewConstraints(format: "V:|[v0(" + "\(cvHeight - 1)" + ")][v1(1)]|", views: exchgLabel, bottomSpace)
        
        setupViewConstraints(format: "H:|-" + cvSpacing + "-[v0]-" + cvSpacing + "-|", views: bottomSpace)
        
        setupViewConstraints(format: "V:|[v0][v1(1)]|", views: arrowIcon, bottomSpace)
        setupViewConstraints(format: "H:[v0(" + "\(cvHeight / 7)" + ")]-" + "\(Int(cvSpacing)! * 3)" + "-|", views: arrowIcon)
    }
    
}
