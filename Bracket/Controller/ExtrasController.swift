//
//  ExtrasController.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/14/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit
//import Web3

class ExtrasController: UIViewController {
    
    let cellId = "cellId"
    
    let informationLabel = GenericLabel("Features Disabled", .center, fontRegular(30), MainPageOptions().labelColor)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        view.backgroundColor = MainPageOptions().backgroundColor
        view.addSubview(informationLabel)
        let height = Int(UIScreen.main.bounds.height / 4)
        view.setupViewConstraints(format: "H:|[v0]|", views: informationLabel)
        view.setupViewConstraints(format: "V:|-" + "\(height)" + "-[v0]", views: informationLabel)
        
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Extras"
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: menuButton)
//        menuButton.addTarget(self, action: #selector(menuButtonPressed), for: .touchUpInside)
    }
    
}
