//
//  KuCoinModel.swift
//  Bracket
//
//  Created by Joseph Brownfield on 7/30/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import Foundation

public struct KuCoinBalances: Codable {
    
    let data: [KuCoinBalance]
    let success: Bool
    let msg: String
    
    enum CodingKeys: String, CodingKey {
        case
        data,
        success,
        msg
    }
    
}

public struct KuCoinBalance: Codable {
    let balance: Double
    let balanceStr: String
    let coinType: String
    let freezeBalance: Double
    let freezeBalanceStr: String
    
    enum CodingKeys: String, CodingKey {
        case
        balance,
        balanceStr,
        coinType,
        freezeBalance,
        freezeBalanceStr
    }
}

public struct KuCoinMakeOrd: Codable {
    
    let data: [String : String]?
    let success: Bool
    let msg: String
    let code: String
    
    enum CodingKeys: String, CodingKey {
        case
        data,
        success,
        msg,
        code
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            let buyValue = try container.decodeIfPresent([String : String].self, forKey: .data)
            self.data = buyValue
        } catch {
            self.data = nil
        }
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.msg = try container.decodeIfPresent(String.self, forKey: .msg) ?? ""
        self.code = try container.decodeIfPresent(String.self, forKey: .code) ?? ""
    }
    
}

public struct KuCoinHistory: Codable {
    
    let data: KuCoinHist
    let success: Bool
    let msg: String
    let code: String
    
    struct KuCoinHist: Codable {
        let datas: [HistoryInfo]
        enum CodingKeys: String, CodingKey {
            case datas
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case
        data,
        success,
        msg,
        code
    }
    
}

public struct KuCoinOpenOrd: Codable {
    
    let data: KuCoinBuySell
    let success: Bool
    let msg: String
    let code: String
    
    enum CodingKeys: String, CodingKey {
        case
        data,
        success,
        msg,
        code
    }
    
}

struct KuCoinBuySell: Codable {
    let buy: [KuCoinOpenInfo]
    let sell: [KuCoinOpenInfo]
    
    enum CodingKeys: String, CodingKey {
        case
        buy = "BUY",
        sell = "SELL"
    }
}

public struct KuCoinOpenInfo: Codable {
    
    let coinType: String
    let coinTypePair: String
    let dealAmount: Double
    let direction: String
    let oid: String
    let pendingAmount: Double
    let price: Double
    var exchg: String?
    
    enum CodingKeys: String, CodingKey {
        case
        coinType = "coinType",
        coinTypePair = "coinTypePair",
        dealAmount = "dealAmount",
        direction,
        oid,
        pendingAmount = "pendingAmount",
        price,
        exchg
    }
    
}

public struct KuCoinPrecision: Codable {
    let data: [PrecisionData]
    let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case
        data,
        success
    }
}

struct PrecisionData: Codable {
    let coin: String
    let tradePrecision: Int
    
    enum CodingKeys: String, CodingKey {
        case
        coin,
        tradePrecision = "tradePrecision"
    }
}

public struct KuCoinOrders: Codable {
    let data: KuCoinOrder
    let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case
        data,
        success
    }
}

public struct KuCoinOrder: Codable {
    let buy: [[String]]
    let sell: [[String]]
    
    enum CodingKeys: String, CodingKey {
        case
        buy = "BUY",
        sell = "SELL"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let numberformatter = NumberFormatter()
        numberformatter.numberStyle = .decimal
        numberformatter.alwaysShowsDecimalSeparator = true
        numberformatter.minimumFractionDigits = 8
        numberformatter.maximumFractionDigits = 8
        let buyValues = try container.decodeIfPresent([[Double]].self, forKey: .buy) ?? [[]]
        var buys: [[String]] = [[String]]()
        for subBuy in buyValues {
            var individualBuy: [String] = [String]()
            for buyValue in subBuy {
                individualBuy.append(numberformatter.string(for: buyValue)!)
            }
            buys.append(individualBuy)
        }
        
        self.buy = buys
        
        let sellValues = try container.decodeIfPresent([[Double]].self, forKey: .sell) ?? [[]]
        var sells: [[String]] = [[String]]()
        for subBuy in sellValues {
            var individualBuy: [String] = [String]()
            for sellValue in subBuy {
                individualBuy.append(numberformatter.string(for: sellValue)!)
            }
            sells.append(individualBuy)
        }
        
        self.sell = sells
    }
}
