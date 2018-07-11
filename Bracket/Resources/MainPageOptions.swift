//
//  MainPageOptions.swift
//  Bracket
//
//  Created by Joseph Brownfield on 5/31/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit

class MainPageOptions {
    let options: [Exchanges] = [.combination,.idex,.bittrex,.kucoin]
    let cvSpacing = "10"
    let cvHeight: CGFloat = 75
    let pairingHeight: Int = 50
    
    //Placeholder Colors
    let darkColor = "#313A47"
    
    //Tab Bar Colors
    let (tabBarTintColor, tabBarColor, tabBarUnselected, navigationTitleColor) = { () -> (UIColor, UIColor, UIColor, UIColor) in
        if (BeastMode.sharedInstance.nightMode) {
            return (setColor(hValue: "#1C262E"), setColor(hValue: "#F3F402"), setColor(hValue: "#575F66"), setColor(hValue: "#F7F7F7"))
        } else {
            return (setColor(hValue: "#F7F8F9"), setColor(hValue: "#5F6FEE"), setColor(hValue: "#B3BAC8"), setColor(hValue: "#1A1A1A"))
        }
    }()
    //let tabBarTintColor = setColor(hValue: "#F7F8F9")
    //let tabBarColor = setColor(hValue: "#5F6FEE")
    //let tabBarUnselected = setColor(hValue: "#B3BAC8")
    
    //Nav Bar Colors
    //let navigationTitleColor = setColor(hValue: "#1A1A1A")
    
    //Other Colors
    let (backgroundColor, labelColor, separatorColor) = { () -> (UIColor, UIColor, UIColor) in
        if (BeastMode.sharedInstance.nightMode) {
            return (setColor(hValue: "#1C262E"), setColor(hValue: "#F7F7F7"), setColor(hValue: "#5F676D"))
        } else {
            return (setColor(hValue: "#FFFFFF"), setColor(hValue: "#4B617F"), setColor(hValue: "#EBECEF"))
        }
    }()
    //let backgroundColor = setColor(hValue: "#FFFFFF")
    //let labelColor = setColor(hValue: "#4B617F")
    //let separatorColor = setColor(hValue: "#EBECEF")
    
    //Price Colors
    let (darkGreen, darkRed) = { () -> (UIColor, UIColor) in
        if (BeastMode.sharedInstance.nightMode) {
            return (setColor(hValue: "#03A575"), setColor(hValue: "#F40755"))
        } else {
            return (setColor(hValue: "#00CCAA"), setColor(hValue: "#FF328B"))
        }
    }()
    //let darkGreen = setColor(hValue: "#00CCAA")
    //let darkRed = setColor(hValue: "#FF328B")
    
}

class BeastMode {
    static let sharedInstance = BeastMode()
    var nightMode: Bool = true
}

class TickerInformation {
    static let sharedInstance = TickerInformation()
    
    var tradingPairs: [PairInfo] = [PairInfo]()
    
    var pairings: [String] = [""]
    
    var currencyPrices: [CoinbasePairInfo] = [CoinbasePairInfo]()
    
    var coinPrecisions: [String : Int] = [String : Int]()
    
    var openOrders: [KuCoinOpenInfo] = [KuCoinOpenInfo]()
    var exchgOrderHist: [HistoryInfo] = [HistoryInfo]()
    
    var activeIndex: Int = 0
    
    var exchangeOptions: [APIKeyValues] = [APIKeyValues]()
    var wallets: [Wallets] = [Wallets]()
    
}

struct ExchangeBalance {
    let exchange: Exchanges
    var balance: Double
    var balanceStr: String
    let coinType: String
    let freezeBalance: Double
    let freezeBalanceStr: String
    var change: String
    var price: String
}

class ExchangeBalances {
    static let sharedInstance = ExchangeBalances()
    
    var exchangeBalances: [ExchangeBalance] = [ExchangeBalance]()
    
    var cmcValues: [CMCData] = [CMCData]()
    
}

func getBalanceValue(_ exchg: Exchanges, _ coin: String) -> ExchangeBalance? {
    if let index = ExchangeBalances.sharedInstance.exchangeBalances.index(where: { $0.exchange == exchg && $0.coinType == coin }) {
        return ExchangeBalances.sharedInstance.exchangeBalances[index]
    }
    return nil
}

enum Exchanges: String {
    case combination = "Combination"
    case idex = "IDEX"
    case bittrex = "Bittrex"
    case kucoin = "KuCoin"
    case none = "None"
}
