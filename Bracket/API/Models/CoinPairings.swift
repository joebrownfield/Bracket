//
//  CoinPairings.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/5/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import Foundation

public struct CoinPairings: Codable {
    
    let data: [PairInfo]
    let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case
        data,
        success
    }
}

public struct CoinPairing: Codable {
    let data: PairInfo
    let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case
        data,
        success
    }
}

// All Pair Info
public struct PairInfo: Codable {
    
    let changeRate: String
    let coinType: String
    var coinTypePair: String
    var lastDealPrice: Double
    var trading: Bool
    var vol: Double
    var symbol: String
    
    enum CodingKeys: String, CodingKey {
        case
        changeRate,
        coinType,
        coinTypePair,
        lastDealPrice,
        trading,
        vol = "volValue",
        symbol
    }
}

extension PairInfo {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let changeRate = try container.decodeIfPresent(Double.self, forKey: .changeRate) ?? 0.0
        let changePercent = changeRate * 100
        let numberformatter = NumberFormatter()
        numberformatter.numberStyle = .decimal
        numberformatter.alwaysShowsDecimalSeparator = true
        numberformatter.minimumFractionDigits = 2
        numberformatter.maximumFractionDigits = 2
        self.changeRate = numberformatter.string(for: changePercent)! + "%"
        self.coinType = try container.decodeIfPresent(String.self, forKey: .coinType) ?? ""
        self.coinTypePair = try container.decodeIfPresent(String.self, forKey: .coinTypePair) ?? ""
        self.lastDealPrice = try container.decodeIfPresent(Double.self, forKey: .lastDealPrice) ?? 0.0
        self.trading = try container.decodeIfPresent(Bool.self, forKey: .trading) ?? false
        self.vol = try container.decodeIfPresent(Double.self, forKey: .vol) ?? 0.0
        self.symbol = try container.decodeIfPresent(String.self, forKey: .symbol) ?? ""
    }
}

public struct TradingMarkets: Codable {
    
    let data: [String]
    let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case
        data,
        success
    }
}

public struct TokenInfo: Codable {
    let address: String
    let name: String
    let decimals: String
    let symbol: String
    let priceSwitch: Bool
    let price: PriceInfo?
    
    enum CodingKeys: String, CodingKey {
        case
        address,
        name,
        decimals,
        symbol,
        priceSwitch = "price"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let address = try container.decodeIfPresent(String.self, forKey: .address) ?? ""
        self.address = address
        let name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.name = name
        do {
            let decimals = try container.decodeIfPresent(String.self, forKey: .decimals)
            self.decimals = decimals!
        } catch {
            do {
                let decimals = try container.decodeIfPresent(Int.self, forKey: .decimals)
                let dec = decimals!
                self.decimals = "\(dec)"
            } catch {
                self.decimals = "0"
            }
        }
        
        do {
            let priceSwitch = try container.decodeIfPresent(Bool.self, forKey: .priceSwitch) ?? false
            self.priceSwitch = priceSwitch
            self.price = nil
        } catch {
            self.priceSwitch = true
            do {
                let price = try container.decodeIfPresent(PriceInfo.self, forKey: .priceSwitch)
                self.price = price
            } catch {
                self.price = nil
            }
        }
        
        let symbol = try container.decodeIfPresent(String.self, forKey: .symbol) ?? ""
        self.symbol = symbol
    }
}

public struct PriceInfo: Codable {
    let rate: String
    let currency: String
    
    enum CodingKeys: String, CodingKey {
        case
        rate,
        currency
    }
}

public struct CMCData: Codable {
    
    let id: String
    let name: String
    let symbol: String
    let rank: String
    let priceUSD: String?
    let priceBTC: String?
    
    enum CodingKeys: String, CodingKey {
        case
        id,
        name,
        symbol,
        rank,
        priceUSD = "price_usd",
        priceBTC = "price_btc"
    }
    
}

public struct HistoryInfo: Codable {
    
    let amount: Double
    let coinType: String
    let coinTypePair: String
    let createdAt: String
    let dealPrice: Double
    let dealValue: Double
    let direction: String
    let oid: String
    var exchg: String?
    
    enum CodingKeys: String, CodingKey {
        case
        amount,
        coinType = "coinType",
        coinTypePair = "coinTypePair",
        createdAt = "createdAt",
        dealPrice = "dealPrice",
        dealValue = "dealValue",
        direction,
        oid
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let createdDouble = try container.decodeIfPresent(Double.self, forKey: .createdAt) ?? 0.0
        let createdUInt = UInt64(createdDouble)
        let date = Date(timeIntervalSince1970: TimeInterval(createdUInt / 1000))
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        self.createdAt = formatter.string(from: date)
        self.amount = try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0.0
        self.coinType = try container.decodeIfPresent(String.self, forKey: .coinType) ?? ""
        self.coinTypePair = try container.decodeIfPresent(String.self, forKey: .coinTypePair) ?? ""
        self.dealPrice = try container.decodeIfPresent(Double.self, forKey: .dealPrice) ?? 0.0
        self.dealValue = try container.decodeIfPresent(Double.self, forKey: .dealValue) ?? 0.0
        self.direction = try container.decodeIfPresent(String.self, forKey: .direction) ?? ""
        self.oid = try container.decodeIfPresent(String.self, forKey: .oid) ?? ""
    }
    
}

extension Order {
    public init(from decoder: Decoder) throws {
        //let container = try decoder.container(keyedBy: CodingKeys.self)
        var asksArray = try decoder.unkeyedContainer()
        var asks: [String] = []
        while (!asksArray.isAtEnd) {
            let stringValue = try? asksArray.decode(String.self)
            let intValue = try? asksArray.decode(Int.self)
            if intValue != nil {
                asks.append(String(intValue!))
            }
            if stringValue != nil {
                asks.append(stringValue!)
            }
        }
        
        self.init(order: asks)
    }
}

public struct Order: Codable {
    let order: [String]
}
