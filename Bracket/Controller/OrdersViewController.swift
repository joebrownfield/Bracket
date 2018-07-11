//
//  OrdersViewController.swift
//  Bracket
//
//  Created by Joseph Brownfield on 7/3/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit


class OrdersViewController: UIViewController {
    
    lazy var collectionView: HistoryOrdersView = {
        let cv = HistoryOrdersView()
        cv.backgroundColor = MainPageOptions().backgroundColor
        cv.bookType = self.bookType
        cv.ordersViewController = self
        return cv
    }()
    
    var bookType = DropdownOptions.open.rawValue
    
    convenience init(bookType: String) {
        self.init()
        self.bookType = bookType
    }
    
    override func viewDidLoad() {
        view.addSubview(collectionView)
        view.setupViewConstraints(format: "H:|[v0]|", views: collectionView)
        view.setupViewConstraints(format: "V:|[v0]|", views: collectionView)
    }
    
    func reloadOpenOrders(exchg: Exchanges) {
        getExchgOpenOrders(exchg: exchg) {
            DispatchQueue.main.async {
                self.collectionView.orderBookCollectionView.reloadData()
            }
        }
    }
    
}
