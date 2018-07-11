//
//  OpenOrdersView.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/30/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit


class OpenOrdersView: OrderBook, OrdersCVDelegate {
    
    func displayAlert(title: String, message: String) {
        orderBookController?.alert(message: message, title: title)
    }
    
    func localUpdateOrders(orderInfo: KuCoinOpenInfo) {
        if orderInfo.direction.lowercased() == MarketOrderTypes.buy.rawValue.lowercased() {
            globalUpdateBal(exchg: Exchanges(rawValue: orderInfo.exchg!)!, coinType: orderInfo.coinTypePair, amount: orderInfo.pendingAmount * orderInfo.price)
        } else {
            globalUpdateBal(exchg: Exchanges(rawValue: orderInfo.exchg!)!, coinType: orderInfo.coinType, amount: orderInfo.pendingAmount)
        }
        orderBookController?.reloadOpenOrders(isTimer: false)
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        orderBookCollectionView.register(OpenOrdersCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        addSubview(orderBookCollectionView)
        setupViewConstraints(format: "H:|[v0]|", views: orderBookCollectionView)
        setupViewConstraints(format: "V:|[v0]|", views: orderBookCollectionView)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orderBookController!.openOrders.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! OpenOrdersCell
        cell.openOrders = orderBookController?.openOrders[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Adjust for the different sizes of phones or iPads
        return CGSize(width: frame.width, height: 75)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class HistoryOrdersView: OpenOrdersView {
    
    override func displayAlert(title: String, message: String) {
        ordersViewController?.alert(message: message, title: title)
    }
    
    override func localUpdateOrders(orderInfo: KuCoinOpenInfo) {
        if orderInfo.direction.lowercased() == MarketOrderTypes.buy.rawValue.lowercased() {
            globalUpdateBal(exchg: Exchanges(rawValue: orderInfo.exchg!)!, coinType: orderInfo.coinTypePair, amount: orderInfo.pendingAmount * orderInfo.price)
        } else {
            globalUpdateBal(exchg: Exchanges(rawValue: orderInfo.exchg!)!, coinType: orderInfo.coinType, amount: orderInfo.pendingAmount)
        }
        ordersViewController?.reloadOpenOrders(exchg: Exchanges(rawValue: orderInfo.exchg!)!)
    }
    
    var ordersViewController: OrdersViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bookType = DropdownOptions.open.rawValue
        
        orderBookCollectionView.register(OpenOrdersCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        orderBookController = nil
        addSubview(orderBookCollectionView)
        setupViewConstraints(format: "H:|[v0]|", views: orderBookCollectionView)
        setupViewConstraints(format: "V:|[v0]|", views: orderBookCollectionView)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if bookType == DropdownOptions.history.rawValue {
            return TickerInformation.sharedInstance.exchgOrderHist.count
        } else {
            return TickerInformation.sharedInstance.openOrders.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! OpenOrdersCell
        if bookType == DropdownOptions.history.rawValue {
            cell.orderHistory = TickerInformation.sharedInstance.exchgOrderHist[indexPath.item]
        } else {
            cell.openOrders = TickerInformation.sharedInstance.openOrders[indexPath.item]
            cell.delegate = self
        }
        return cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
