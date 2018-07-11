//
//  PortfolioCell.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/25/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit


class PortfolioCell: BaseCell {
    
    let coin = GenericLabel("", .center, fontBold(20), MainPageOptions().labelColor)
    
    let coinAmount = GenericLabel("", .center, fontRegular(15), MainPageOptions().labelColor)
    
    let coinLocation: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "WalletIcon")?.withRenderingMode(.alwaysTemplate)
        image.tintColor = MainPageOptions().tabBarColor
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    let coinValue = GenericLabel("", .center, fontRegular(15), MainPageOptions().labelColor)
    
    let price = GenericLabel("", .center, fontRegular(17), MainPageOptions().labelColor)
    
    let change: UILabel = {
        let label = GenericLabel("5.25%", .center, fontRegular(15), MainPageOptions().backgroundColor)
        if (BeastMode.sharedInstance.nightMode) {
            label.textColor = .white
        }
        label.backgroundColor = setColor(hValue: "#00CCAA")
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()
    
    let mainPageOptions = MainPageOptions()
    
    override func addViews() {
        
        addSubview(coin)
        addSubview(coinAmount)
        addSubview(coinLocation)
        addSubview(coinValue)
        addSubview(price)
        addSubview(change)
        
        let labelHeights = Int(mainPageOptions.cvHeight / 2) - 4
        let width = UIScreen.main.bounds.width / 10
        
        setupViewConstraints(format: "H:|-10-[v0(" + "\(width * 2)" + ")][v1(19)]", views: coin, coinLocation)
        setupViewConstraints(format: "H:|[v0]|", views: price)
        setupViewConstraints(format: "H:|-10-[v0(" + "\(width * 3)" + ")]-5-[v1(" + "\(width * 3)" + ")]", views: coinAmount, coinValue)
        setupViewConstraints(format: "H:[v0(" + "\(width * 3)" + ")]-5-|", views: change)
        
        setupViewConstraints(format: "V:|-5-[v0(" + "\(labelHeights)" + ")][v1(" + "\(labelHeights)" + ")]-5-|", views: coin, coinAmount)
        setupViewConstraints(format: "V:[v0(12)]", views: coinLocation)
        setupViewConstraints(format: "V:|-5-[v0(" + "\(labelHeights)" + ")]", views: price)
        setupViewConstraints(format: "V:[v0][v1(" + "\(labelHeights)" + ")]", views: coin, coinValue)
        setupViewConstraints(format: "V:|-" + "\(labelHeights / 2)" + "-[v0]-" + "\(labelHeights / 2)" + "-|", views: change)
        
        addConstraint(NSLayoutConstraint(item: coinLocation, attribute: .centerY, relatedBy: .equal, toItem: coin, attribute: .centerY, multiplier: 1, constant: 0))
        
    }
    
}
