//
//  CustomTabBarController.swift
//  Bracket
//
//  Created by Joseph Brownfield on 5/31/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainPageOptions = MainPageOptions()
        
        let layout = UICollectionViewFlowLayout()
        let mainPageController = MainPageController(collectionViewLayout: layout)
        let navigationController = UINavigationController(rootViewController: mainPageController)
        navigationController.title = "Home"
        navigationController.tabBarItem.image = UIImage(named: "Home")?.withRenderingMode(.alwaysTemplate)
        navigationController.tabBarItem.selectedImage = UIImage(named: "Home")?.withRenderingMode(.alwaysTemplate)
        navigationController.navigationBar.tintColor = mainPageOptions.navigationTitleColor
        
        let portfolioLayout = UICollectionViewFlowLayout()
        let portfolioController = PortfolioController(collectionViewLayout: portfolioLayout)
        let portfolioNav = UINavigationController(rootViewController: portfolioController)
        portfolioNav.title = "Portfolio"
        portfolioNav.tabBarItem.image = UIImage(named: "chart")?.withRenderingMode(.alwaysTemplate)
        portfolioNav.tabBarItem.selectedImage = UIImage(named: "chart")?.withRenderingMode(.alwaysTemplate)
        portfolioNav.navigationBar.tintColor = mainPageOptions.navigationTitleColor
        
        let extrasController = ExtrasController()
        let extrasNav = UINavigationController(rootViewController: extrasController)
        extrasNav.title = "Extras"
        if (BeastMode.sharedInstance.nightMode) {
            extrasNav.tabBarItem.image = UIImage(named: "extrasIcon")?.withRenderingMode(.alwaysTemplate)
            extrasNav.tabBarItem.selectedImage = UIImage(named: "extrasIcon")?.withRenderingMode(.alwaysTemplate)
        } else {
            extrasNav.tabBarItem.image = UIImage(named: "extras")?.withRenderingMode(.alwaysOriginal)
            extrasNav.tabBarItem.selectedImage = UIImage(named: "extrasSelected")?.withRenderingMode(.alwaysOriginal)
        }
        extrasNav.navigationBar.tintColor = mainPageOptions.navigationTitleColor
        
        viewControllers = [portfolioNav, navigationController, extrasNav]
        
        tabBar.barStyle = .black
        tabBar.isTranslucent = false
        
        tabBar.barTintColor = mainPageOptions.tabBarTintColor
        tabBar.tintColor = mainPageOptions.tabBarColor
        tabBar.unselectedItemTintColor = mainPageOptions.tabBarUnselected
        
    }
    
}
