//
//  OrderBookView.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/21/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import Foundation
import UIKit

class OrderBook: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    lazy var orderBookCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    let screenWidth = UIScreen.main.bounds.width
    
    let mainPageOptions = MainPageOptions()
    
    var bookType: String = OrderBookType.sell.rawValue
    
    var orderBookController: TradingController?
    
    let reuseIdentifier = "orderCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        orderBookCollectionView.register(OrderBookCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        addSubview(orderBookCollectionView)
        setupViewConstraints(format: "H:|[v0]|", views: orderBookCollectionView)
        setupViewConstraints(format: "V:|[v0]|", views: orderBookCollectionView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if bookType == OrderBookType.sell.rawValue {
            return orderBookController!.orderBooks.asks.count
        } else {
            return orderBookController!.orderBooks.bids.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! OrderBookCell
        // We want to do two different things depending on if it is a sell book or a buy book. If it is a sell book then we
        // are going to want to display the lowest value at the bottom and if it's a buy book we want to display the highest
        if bookType == OrderBookType.sell.rawValue {
            let rowCount = orderBookController!.orderBooks.asks.count - 1
            let order = orderBookController!.orderBooks.asks[rowCount - indexPath.item].order
            cell.priceLabel.text = order[0]
            cell.volumeLabel.text = order[2].numberToStringFormat(5)
            return cell
        } else {
            let order = orderBookController!.orderBooks.bids[indexPath.item].order
            cell.priceLabel.text = order[0]
            cell.volumeLabel.text = order[2].numberToStringFormat(5)
            cell.priceLabel.textColor = mainPageOptions.darkGreen
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Adjust for the different sizes of phones or iPads
        let cellHeight: CGFloat = {
            if screenWidth > 700 {
                return frame.height / 20
            } else if screenWidth > 374 {
                return frame.height / 14
            } else {
                return frame.height / 10
            }
        }()
        return CGSize(width: frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Whenever selecting a new price we will clear the text field values for quote and base currency
        orderBookController?.clearTextFieldValues()
        
        //Updating the price field with the selected price from the order book
        if bookType == OrderBookType.sell.rawValue {
            let rowCount = orderBookController!.orderBooks.asks.count - 1
            orderBookController?.quoteCurrencyPrice.text = orderBookController!.orderBooks.asks[rowCount - indexPath.item].order[0]
        } else {
            orderBookController?.quoteCurrencyPrice.text = orderBookController!.orderBooks.bids[indexPath.item].order[0]
        }
        
    }
    
}
