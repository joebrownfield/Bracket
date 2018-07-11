//
//  TickersCell.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/10/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit

class TickersCell: BaseCell {
    
    let symbol = GenericLabel("ETH/BTC", .center, fontRegular(15), MainPageOptions().labelColor)
    
    let volume = GenericLabel("Vol: 100.00", .center, fontLight(15), MainPageOptions().labelColor)
    
    let price = GenericLabel("0.012345", .center, fontRegular(17), MainPageOptions().labelColor)
    
    let dollarAmount = GenericLabel("", .center, fontLight(12), MainPageOptions().labelColor)
    
    let change: UILabel = {
        let label = GenericLabel("0.012345", .center, fontRegular(15), MainPageOptions().backgroundColor)
        if (BeastMode.sharedInstance.nightMode) {
            label.textColor = .white
        }
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()
    
    let mainPageOptions = MainPageOptions()
    
    override func addViews() {
        
        addSubview(symbol)
        addSubview(volume)
        addSubview(price)
        addSubview(dollarAmount)
        addSubview(change)
        addSubview(bottomSpace)
        
        let spacing = 4
        let labelHeights = Int(mainPageOptions.cvHeight / 2) - spacing
        let width = UIScreen.main.bounds.width / 10
        
        setupViewConstraints(format: "V:|-" + "\(spacing + 4)" + "-[v0(" + "\(labelHeights - 4)" + ")][v1(" + "\(labelHeights)" + ")]-" + "\(spacing + 1)" + "-|", views: symbol, volume)
        setupViewConstraints(format: "V:|-" + "\(spacing + 4)" + "-[v0(" + "\(labelHeights - 4)" + ")][v1(" + "\(labelHeights)" + ")]-" + "\(spacing + 1)" + "-|", views: price, dollarAmount)
        setupViewConstraints(format: "V:|-" + "\(labelHeights / 2)" + "-[v0]-" + "\(labelHeights / 2)" + "-|", views: change)
        
        setupViewConstraints(format: "H:|-5-[v0(" + "\(width * 3)" + ")][v1][v2(" + "\(width * 3)" + ")]-5-|", views: symbol, price, change)
        setupViewConstraints(format: "H:|-5-[v0(" + "\(width * 3)" + ")][v1]-" + "\(width * 3)" + "-|", views: volume, dollarAmount)
        
        setupViewConstraints(format: "H:|-" + cvSpacing + "-[v0]-" + cvSpacing + "-|", views: bottomSpace)
        setupViewConstraints(format: "V:[v0(1)]|", views: bottomSpace)
        
    }
    
}
