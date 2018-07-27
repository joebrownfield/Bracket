//
//  BaseCell.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/5/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }
    
    let cvSpacing: String = {
        let mainPage = MainPageOptions()
        let spacing = mainPage.cvSpacing
        return spacing
    }()
    
    let bottomSpace: UIView = {
        let view = UIView()
        view.backgroundColor = MainPageOptions().separatorColor
        view.alpha = 0.7
        return view
    }()
    
    func addViews() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
