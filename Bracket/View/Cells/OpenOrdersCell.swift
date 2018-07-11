//
//  OpenOrdersCell.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/30/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit

protocol OrdersCVDelegate {
    func displayAlert(title: String, message: String)
    func localUpdateOrders(orderInfo: KuCoinOpenInfo)
}

class OpenOrdersCell: PortfolioCell {
    
    let cancelButton: UIButton = {
        let button = GenericButton(title: "Cancel", radius: 3, color: .clear, font: fontLight(15))
        button.layer.borderWidth = 1
        let buttonColor = MainPageOptions().darkRed
        button.layer.borderColor = buttonColor.cgColor
        button.setTitleColor(buttonColor, for: [])
        button.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.5), for: .highlighted)
        return button
    }()
    
    let orderType: UILabel = {
        let label = GenericLabel("BUY", .center, UIFont.boldSystemFont(ofSize: 8), MainPageOptions().darkGreen)
        label.textColor = .white
        label.layer.cornerRadius = 1
        label.clipsToBounds = true
        return label
    }()
    
    var delegate: OrdersCVDelegate?
    
    var openOrders: KuCoinOpenInfo? {
        didSet {
            coin.text = (openOrders?.coinType)! + "-" + (openOrders?.coinTypePair)!
            coinAmount.text = "Amount: " + (openOrders?.pendingAmount.toString().numberToStringFormat(2))!
            coinValue.text = "Filled: " + (openOrders?.dealAmount.toString().numberToStringFormat(2))!
            if let decimals = TickerInformation.sharedInstance.coinPrecisions[(openOrders?.coinTypePair)!] {
                price.text = openOrders?.price.toString().numberToStringFormat(decimals)
            } else {
                price.text = openOrders?.price.toString().numberToStringFormat(8)
            }
            let direction = openOrders?.direction
            if direction?.lowercased() == MarketOrderTypes.buy.rawValue.lowercased() {
                orderType.backgroundColor = mainPageOptions.darkGreen
            } else {
                orderType.backgroundColor = mainPageOptions.darkRed
            }
            orderType.text = direction
            cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        }
    }
    
    var orderHistory: HistoryInfo? {
        didSet {
            coin.text = (orderHistory?.coinType)! + "-" + (orderHistory?.coinTypePair)!
            //coin.font = fontRegular(14)
            coinAmount.text = "Amount: " + (orderHistory?.amount.toString().numberToStringFormat(2))!
            coinValue.text = "Date: " + (orderHistory?.createdAt)!
            if let decimals = TickerInformation.sharedInstance.coinPrecisions[(orderHistory?.coinTypePair)!] {
                price.text = orderHistory?.dealPrice.toString().numberToStringFormat(decimals)
            } else {
                price.text = orderHistory?.dealPrice.toString().numberToStringFormat(8)
            }
            let direction = orderHistory?.direction
            if direction?.lowercased() == MarketOrderTypes.buy.rawValue.lowercased() {
                orderType.backgroundColor = mainPageOptions.darkGreen
            } else {
                orderType.backgroundColor = mainPageOptions.darkRed
            }
            orderType.text = direction
            cancelButton.setTitle((orderHistory?.exchg)!, for: [])
            let buttonColor = mainPageOptions.navigationTitleColor
            cancelButton.setTitleColor(buttonColor, for: [])
            cancelButton.layer.borderColor = buttonColor.cgColor
        }
    }
    
    @objc func cancelButtonPressed(_ sender: UIButton) {
        print("Cancel Pressed")
        let kuCoin = KuCoin(apiKey: AllKeys.kuCoinShared.apiKey, secret: AllKeys.kuCoinShared.secret)
        kuCoin.cancelOrder(order: openOrders!) { (results, error) in
            guard let results = results else {
                return
            }
            if (results.success) {
                DispatchQueue.main.async {
                    self.localDisplayAlert()
                    self.delegate?.localUpdateOrders(orderInfo: self.openOrders!)
                }
            }
        }
    }
    
    func localDisplayAlert() {
        delegate?.displayAlert(title: "Success", message: "Order has successfully been canceled")
    }
    
    override func addViews() {
        
        addSubview(coin)
        addSubview(coinAmount)
        addSubview(coinValue)
        addSubview(price)
        addSubview(cancelButton)
        addSubview(orderType)
        addSubview(bottomSpace)
        
        //bottomSpace.isHidden = true
        
        coin.text = "BTC-ETH"
        coin.font = fontRegular(15)
        coinAmount.font = fontRegular(14)
        coinValue.font = fontRegular(14)
        coinAmount.text = "Amount: 20.000"
        coinValue.text = "Filled: 5.000"
        price.text = ".0789125"
        
        let labelHeights = Int(mainPageOptions.cvHeight / 2) - 4
        let width = UIScreen.main.bounds.width / 10
        
        setupViewConstraints(format: "H:|-10-[v0(" + "\(width * 2 + 5)" + ")]-5-[v1(" + "\(width)" + ")]", views: coin, orderType)
        setupViewConstraints(format: "H:[v0]-5-[v1(" + "\(width * 3 + 20)" + ")]", views: coinAmount, price, cancelButton)
        setupViewConstraints(format: "H:|-10-[v0(" + "\(width * 3 + 20)" + ")]-5-[v1(" + "\(width * 3 + 20)" + ")]", views: coinAmount, coinValue)
        setupViewConstraints(format: "H:[v0(" + "\(width * 3 - 45)" + ")]-10-|", views: cancelButton)
        
        setupViewConstraints(format: "V:|-5-[v0(" + "\(labelHeights)" + ")][v1(" + "\(labelHeights)" + ")]", views: coin, coinAmount)
        setupViewConstraints(format: "V:|-5-[v0(" + "\(labelHeights)" + ")]", views: price)
        setupViewConstraints(format: "V:|-10-[v0(" + "\(labelHeights - 10)" + ")]", views: orderType)
        setupViewConstraints(format: "V:[v0][v1(" + "\(labelHeights)" + ")]", views: coin, coinValue)
        setupViewConstraints(format: "V:|-" + "\(labelHeights / 2 + 5)" + "-[v0]-" + "\(labelHeights / 2 + 5)" + "-|", views: cancelButton)
        
        setupViewConstraints(format: "H:|-10-[v0]|", views: bottomSpace)
        setupViewConstraints(format: "V:[v0(1)]|", views: bottomSpace)
        
    }
    
}
