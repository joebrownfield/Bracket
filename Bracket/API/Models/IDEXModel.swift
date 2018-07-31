//
//  IDEXModel.swift
//  Bracket
//
//  Created by Joseph Brownfield on 7/30/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import Foundation

public struct IDEXPairInfo: Codable {
    
    let changeRate: String
    let coinType: String
    var coinTypePair: String
    var lastDealPrice: Double
    var vol: Double
    var symbol: String
    
    enum CodingKeys: String, CodingKey {
        case
        changeRate = "percentChange",
        coinType,
        coinTypePair,
        lastDealPrice = "last",
        vol = "baseVolume",
        symbol
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let changeRateValue = try container.decodeIfPresent(String.self, forKey: .changeRate) ?? "0.0"
        let changeRate = Double(changeRateValue)!
        let changePercent = changeRate
        let numberformatter = NumberFormatter()
        numberformatter.numberStyle = .decimal
        numberformatter.alwaysShowsDecimalSeparator = true
        numberformatter.minimumFractionDigits = 2
        numberformatter.maximumFractionDigits = 2
        self.changeRate = numberformatter.string(for: changePercent)! + "%"
        self.coinType = try container.decodeIfPresent(String.self, forKey: .coinType) ?? ""
        self.coinTypePair = try container.decodeIfPresent(String.self, forKey: .coinTypePair) ?? ""
        let price = try container.decodeIfPresent(String.self, forKey: .lastDealPrice) ?? "0.0"
        if price == "N/A" {
            self.lastDealPrice = 0
        } else {
            self.lastDealPrice = Double(price)!
        }
        let volumeValue = try container.decodeIfPresent(String.self, forKey: .vol) ?? "0.0"
        self.vol = Double(volumeValue)!
        self.symbol = try container.decodeIfPresent(String.self, forKey: .symbol) ?? ""
    }
}

public struct IDEXOrders: Codable {
    
    let asks: [IDEXOrder]
    let bids: [IDEXOrder]
    
    enum CodingKeys: String, CodingKey {
        case
        asks,
        bids
    }
}

public struct IDEXOrder: Codable {
    let price: String
    let amount: String
    let total: String
    let orderHash: String
    
    enum CodingKeys: String, CodingKey {
        case
        price,
        amount,
        total,
        orderHash = "orderHash"
    }
}
