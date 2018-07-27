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
        case data
        case success
    }
}

public struct CoinPairing: Codable {
    let data: PairInfo
    let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case data
        case success
    }
}

public struct BittrexCoinPairings: Codable {
    
    let success: Bool
    let message: String
    let result: [BittrexPairInfo]
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case result
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
        case changeRate
        case coinType
        case coinTypePair
        case lastDealPrice
        case trading
        case vol = "volValue"
        case symbol
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

public struct IDEXPairInfo: Codable {
    
    let changeRate: String
    let coinType: String
    var coinTypePair: String
    var lastDealPrice: Double
    var vol: Double
    var symbol: String
    
    enum CodingKeys: String, CodingKey {
        case changeRate = "percentChange"
        case coinType
        case coinTypePair
        case lastDealPrice = "last"
        case vol = "baseVolume"
        case symbol
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

public struct BittrexPairInfo: Codable {
    
    let changeRate: String
    let coinType: String
    var coinTypePair: String
    var lastDealPrice: Double
    var trading: Bool
    var vol: Double
    var symbol: String
    
    enum CodingKeys: String, CodingKey {
        case changeRate = "PrevDay"
        case coinType = "MarketName"
        case coinTypePair
        case lastDealPrice = "Last"
        case trading
        case vol = "BaseVolume"
        case symbol
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

public struct TradingMarkets: Codable {
    
    let data: [String]
    let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case data
        case success
    }
}

public struct CoinbasePairsInfo: Codable {
    let data: CoinbasePairInfo
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}

public struct CoinbasePairInfo: Codable {
    let base: String
    let currency: String
    let amount: String
    
    enum CodingKeys: String, CodingKey {
        case base
        case currency
        case amount
    }
}

public struct IDEXOrders: Codable {
    
    let asks: [IDEXOrder]
    let bids: [IDEXOrder]
    
    enum CodingKeys: String, CodingKey {
        case asks
        case bids
    }
}

public struct IDEXOrder: Codable {
    let price: String
    let amount: String
    let total: String
    let orderHash: String
    
    enum CodingKeys: String, CodingKey {
        case price
        case amount
        case total
        case orderHash = "orderHash"
    }
}

public struct EthplorerBalance: Codable {
    let address: String
    let eth: EthplorerEth
    let tokens: [EthplorerTokens]?
    let error: Bool
    
    enum CodingKeys: String, CodingKey {
        case address
        case eth = "ETH"
        case tokens
        case error
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let address = try container.decodeIfPresent(String.self, forKey: .address) ?? ""
        self.address = address
        let eth = try container.decodeIfPresent(EthplorerEth.self, forKey: .eth) ?? EthplorerEth(balance: 0.0)
        self.eth = eth
        let tokens = try container.decodeIfPresent([EthplorerTokens].self, forKey: .tokens) ?? nil
        self.tokens = tokens
        let error = try container.decodeIfPresent(EthplorerError.self, forKey: .error) ?? EthplorerError(code: 100, message: "")
        if error.code == 100 {
            self.error = false
        } else {
            self.error = true
        }
    }
}

public struct EthplorerTokens: Codable {
    let tokenInfo: TokenInfo
    let balance: Double
    let totalIn: Double
    let totalOut: Double
    
    enum CodingKeys: String, CodingKey {
        case tokenInfo = "tokenInfo"
        case balance
        case totalIn = "totalIn"
        case totalOut = "totalOut"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tokenInfo = try container.decodeIfPresent(TokenInfo.self, forKey: .tokenInfo)
        self.tokenInfo = tokenInfo!
        let balance = try container.decodeIfPresent(Double.self, forKey: .balance) ?? 0.0
        self.balance = balance
        let totalIn = try container.decodeIfPresent(Double.self, forKey: .totalIn) ?? 0.0
        self.totalIn = totalIn
        let totalOut = try container.decodeIfPresent(Double.self, forKey: .totalOut) ?? 0.0
        self.totalOut = totalOut
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
        case address
        case name
        case decimals
        case symbol
        case priceSwitch = "price"
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
        case rate
        case currency
    }
}

public struct EthplorerEth: Codable {
    let balance: Double
    
    enum CodingKeys: String, CodingKey {
        case balance
    }
}

public struct EthplorerError: Codable {
    let code: Int?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case message
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
        case id
        case name
        case symbol
        case rank
        case priceUSD = "price_usd"
        case priceBTC = "price_btc"
    }
    
}

public struct KuCoinBalances: Codable {
    
    let data: [KuCoinBalance]
    let success: Bool
    let msg: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case success
        case msg
    }
    
}

public struct KuCoinBalance: Codable {
    let balance: Double
    let balanceStr: String
    let coinType: String
    let freezeBalance: Double
    let freezeBalanceStr: String
    
    enum CodingKeys: String, CodingKey {
        case balance
        case balanceStr
        case coinType
        case freezeBalance
        case freezeBalanceStr
    }
}

public struct KuCoinMakeOrd: Codable {
    
    let data: [String : String]?
    let success: Bool
    let msg: String
    let code: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case success
        case msg
        case code
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
        case data
        case success
        case msg
        case code
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
        case amount
        case coinType = "coinType"
        case coinTypePair = "coinTypePair"
        case createdAt = "createdAt"
        case dealPrice = "dealPrice"
        case dealValue = "dealValue"
        case direction
        case oid
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

public struct KuCoinOpenOrd: Codable {
    
    let data: KuCoinBuySell
    let success: Bool
    let msg: String
    let code: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case success
        case msg
        case code
    }
    
}

struct KuCoinBuySell: Codable {
    let buy: [KuCoinOpenInfo]
    let sell: [KuCoinOpenInfo]
    
    enum CodingKeys: String, CodingKey {
        case buy = "BUY"
        case sell = "SELL"
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
        case coinType = "coinType"
        case coinTypePair = "coinTypePair"
        case dealAmount = "dealAmount"
        case direction
        case oid
        case pendingAmount = "pendingAmount"
        case price
        case exchg
    }
    
}

public struct KuCoinPrecision: Codable {
    let data: [PrecisionData]
    let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case data
        case success
    }
}

struct PrecisionData: Codable {
    let coin: String
    let tradePrecision: Int
    
    enum CodingKeys: String, CodingKey {
        case coin
        case tradePrecision = "tradePrecision"
    }
}

public struct KuCoinOrders: Codable {
    
    let data: KuCoinOrder
    let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case data
        case success
    }
}

public struct KuCoinOrder: Codable {
    let buy: [[String]]
    let sell: [[String]]
    
    enum CodingKeys: String, CodingKey {
        case buy = "BUY"
        case sell = "SELL"
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

public struct BittrexOrders: Codable {
    
    let result: BittrexOrder
    let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case result
        case success
    }
}

public struct BittrexOrder: Codable {
    let buy: [[String]]
    let sell: [[String]]
    
    enum CodingKeys: String, CodingKey {
        case buy
        case sell
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
