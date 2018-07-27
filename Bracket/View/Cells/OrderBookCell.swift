//
//  OrderBookCell.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/21/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit

class OrderBookCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }
    
    let priceLabel: UILabel = {
        let label = GenericLabel("", .center, UIFont.boldSystemFont(ofSize: 10), MainPageOptions().darkRed)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let volumeLabel: UILabel = {
        let label = GenericLabel("", .center, UIFont.systemFont(ofSize: 10), MainPageOptions().navigationTitleColor)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let separatorBottom = GenericView(color: .black, alpha: 0)
    
    func addViews() {
        
        let labelSpacing = frame.width / 2
        
        addSubview(priceLabel)
        addSubview(volumeLabel)
        addSubview(separatorBottom)
        
        setupViewConstraints(format: "H:|-10-[v0(\(labelSpacing))][v1]|", views: priceLabel, volumeLabel)
        setupViewConstraints(format: "V:|[v0]|", views: priceLabel)
        setupViewConstraints(format: "V:|[v0]|", views: volumeLabel)
        setupViewConstraints(format: "H:|[v0]|", views: separatorBottom)
        setupViewConstraints(format: "V:[v0(1)]|", views: separatorBottom)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
