//
//  TradingAPIHelpers.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/24/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit


extension TradingController {
    
    func loadIdexData(_ pair: PairInfo, completion: @escaping (_ asks: [Order], _ bids: [Order]) -> Void) {
        idex.getOrderBook(pairing: pair) { (results, error) in
            guard error == nil, var buys = results?.bids, var sells = results?.asks else {
                self.alert(message: (error ?? "Data loading error"), title: "Error")
                return
            }
            sells = sells.filter { $0.price != "" }
            buys = buys.filter { $0.price != "" }
            sells.sort { Double($0.price)! < Double($1.price)! }
            buys.sort { Double($0.price)! > Double($1.price)! }
            
            var asks: [Order] = [Order]()
            for sell in sells {
                var newSell = [sell.price, sell.amount, sell.total]
                if self.activePair?.coinTypePair == "ETH" {
                    newSell[0] = newSell[0].numberToStringFormat(8)
                }
                asks.append(Order(order: newSell))
            }
            
            var bids: [Order] = [Order]()
            for buy in buys {
                var newBuy = [buy.price, buy.amount, buy.total]
                if self.activePair?.coinTypePair == "ETH" {
                    newBuy[0] = newBuy[0].numberToStringFormat(8)
                }
                bids.append(Order(order: newBuy))
            }
            
            self.orderBooks.asks = asks
            self.orderBooks.bids = bids
            
            completion(asks, bids)
            
        }
    }
    
    func loadBittrexData(_ pair: PairInfo, completion: @escaping (_ asks: [Order], _ bids: [Order]) -> Void) {
        bittrex.getOrderBook(pairing: pair) { (results, error) in
            guard error == nil, var buys = results?.result.buy, var sells = results?.result.sell else {
                self.alert(message: (error ?? "Data loading error"), title: "Error")
                return
            }
            
            sells = sells.filter { $0[0] != "" }
            buys = buys.filter { $0[0] != "" }
            sells.sort { Double($0[0])! < Double($1[0])! }
            buys.sort { Double($0[0])! > Double($1[0])! }
            
            var asks: [Order] = [Order]()
            for sell in sells {
                var newSell = sell
                if self.activePair?.coinTypePair == "ETH" {
                    newSell[0] = newSell[0].numberToStringFormat(7)
                }
                asks.append(Order(order: newSell))
            }
            
            var bids: [Order] = [Order]()
            for buy in buys {
                var newBuy = buy
                if self.activePair?.coinTypePair == "ETH" {
                    newBuy[0] = newBuy[0].numberToStringFormat(7)
                }
                bids.append(Order(order: newBuy))
            }
            
            self.orderBooks.asks = asks
            self.orderBooks.bids = bids
            
            completion(asks, bids)
            
        }
    }
    
    func loadKucoinData(_ pair: PairInfo, completion: @escaping (_ asks: [Order], _ bids: [Order]) -> Void) {
        kuCoin.getOrderBook(pairing: pair) { (results, error) in
            guard error == nil, var buys = results?.data.buy, var sells = results?.data.sell else {
                self.alert(message: (error ?? "Data loading error"), title: "Error")
                return
            }
            sells = sells.filter { $0[0] != "" }
            buys = buys.filter { $0[0] != "" }
            sells.sort { Double($0[0])! < Double($1[0])! }
            buys.sort { Double($0[0])! > Double($1[0])! }
            
            var asks: [Order] = [Order]()
            for sell in sells {
                var newSell = sell
                if self.activePair?.coinTypePair == "ETH" {
                    newSell[0] = newSell[0].numberToStringFormat(7)
                }
                asks.append(Order(order: newSell))
            }
            
            var bids: [Order] = [Order]()
            for buy in buys {
                var newBuy = buy
                if self.activePair?.coinTypePair == "ETH" {
                    newBuy[0] = newBuy[0].numberToStringFormat(7)
                }
                bids.append(Order(order: newBuy))
            }
            
            self.orderBooks.asks = asks
            self.orderBooks.bids = bids
            
            completion(asks, bids)
            
        }
    }
    
    func getTextFieldInfo() -> (CGFloat, CGFloat, Int, CGFloat, Int, Int, CGFloat, CGFloat) {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height - (navigationController?.navigationBar.frame.height)! - 50
        let bookWidth = (screenWidth / 2) - 5
        
        let buttonHeight = 40
        
        let textFieldSpacing: CGFloat = {
            if (screenHeight / 50) < 30 {
                return (screenHeight / 50)
            } else {
                return 30
            }
        }()
        
        let textFieldHeight: Int = {
            if screenHeight <= 320 {
                return 35
            } else {
                return 50
            }
        }()
        
        let textLabelHeights: Int = 16
        
        let textFieldWidth: CGFloat = 148
        let textFieldSides: CGFloat = (screenWidth / 2 - textFieldWidth) / 2
        
        return (screenWidth, bookWidth, buttonHeight, textFieldSpacing, textFieldHeight, textLabelHeights, textFieldWidth, textFieldSides)
    }
    
}
