//
//  BittrexModels.swift
//  Bracket
//
//  Created by Joseph Brownfield on 7/30/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import Foundation

public struct BittrexCoinPairings: Codable {
    
    let success: Bool
    let message: String
    let result: [BittrexPairInfo]
    
    enum CodingKeys: String, CodingKey {
        case
        success,
        message,
        result
    }
    
}

public struct BittrexPairInfo: Codable {
    
    let changeRate: String
    let coinType: String
    var coinTypePair: String
    var lastDealPrice: Double
    var trading: Bool
    var vol: Double
    var symbol: String
    
    enum CodingKeys: String, CodingKey {
        case
        changeRate = "PrevDay",
        coinType = "MarketName",
        coinTypePair,
        lastDealPrice = "Last",
        trading,
        vol = "BaseVolume",
        symbol
    }
}

extension BittrexPairInfo {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let marketName = try container.decodeIfPresent(String.self, forKey: .coinType) ?? "-"
        let pairs = marketName.components(separatedBy: "-")
        self.symbol = pairs[1] + "-" + pairs[0]
        self.coinTypePair = pairs[0]
        self.coinType = pairs[1]
        
        let changeRate = try container.decodeIfPresent(Double.self, forKey: .changeRate) ?? 0.0
        let lastDealPrice = try container.decodeIfPresent(Double.self, forKey: .lastDealPrice) ?? 0.0
        let changePercent = ((lastDealPrice / changeRate) - 1) * 100
        let numberformatter = NumberFormatter()
        numberformatter.numberStyle = .decimal
        numberformatter.alwaysShowsDecimalSeparator = true
        numberformatter.minimumFractionDigits = 2
        numberformatter.maximumFractionDigits = 2
        self.changeRate = numberformatter.string(for: changePercent)! + "%"
        self.lastDealPrice = lastDealPrice
        
        self.trading = true
        self.vol = try container.decodeIfPresent(Double.self, forKey: .vol) ?? 0.0
    }
}

public struct BittrexOrders: Codable {
    
    let result: BittrexOrder
    let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case
        result,
        success
    }
}

public struct BittrexOrder: Codable {
    let buy: [[String]]
    let sell: [[String]]
    
    enum CodingKeys: String, CodingKey {
        case
        buy,
        sell
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let numberformatter = NumberFormatter()
        numberformatter.numberStyle = .decimal
        numberformatter.alwaysShowsDecimalSeparator = true
        numberformatter.minimumFractionDigits = 8
        numberformatter.maximumFractionDigits = 8
        let buyValues = try container.decodeIfPresent([[String : Double]].self, forKey: .buy) ?? [[:]]
        var buys: [[String]] = [[String]]()
        for subBuy in buyValues {
            var individualBuy: [String] = [String]()
            for (_, value) in subBuy {
                individualBuy.append(numberformatter.string(for: value)!)
            }
            let vol = individualBuy[0].toDouble() * individualBuy[1].toDouble()
            //            let vol = Double(individualBuy[0].replacingOccurrences(of: ",", with: ""))! * Double(individualBuy[1].replacingOccurrences(of: ",", with: ""))!
            individualBuy.append(numberformatter.string(for: vol)!)
            buys.append(individualBuy)
        }
        
        self.buy = buys
        
        let sellValues = try container.decodeIfPresent([[String : Double]].self, forKey: .sell) ?? [[:]]
        var sells: [[String]] = [[String]]()
        for subBuy in sellValues {
            var individualBuy: [String] = [String]()
            for (_, value) in subBuy {
                individualBuy.append(numberformatter.string(for: value)!)
            }
            let vol = individualBuy[0].toDouble() * individualBuy[1].toDouble()
            individualBuy.append(numberformatter.string(for: vol)!)
            sells.append(individualBuy)
        }
        
        self.sell = sells
    }
}
