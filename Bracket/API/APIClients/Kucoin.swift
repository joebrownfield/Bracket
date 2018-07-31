//
//  Kucoin.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/5/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import Foundation
import Crypto

final class KuCoin {
    static let shared = KuCoin(apiKey: "", secret: "")
    var apiKey = ""
    var secret = ""
    let exchg: Exchanges = .kucoin
    
    public init(apiKey: String, secret: String) {
        self.apiKey = apiKey
        self.secret = secret
    }
}

extension KuCoin {
    func getAllPairings(completion: @escaping (CoinPairings?, String?) -> Void) {
        httpRequest(req: KuCoinCalls.GetAllPairings(), type: CoinPairings.self, completion: completion)
    }
    
    func getCoinPairing(symbol: String, completion: @escaping (CoinPairing?, String?) -> Void) {
        let httpDetails = KuCoinCalls.GetCoinPairing(arguments: symbol)
        httpRequest(req: httpDetails, type: CoinPairing.self, completion: completion)
    }
    
    func getTradingMarkets(completion: @escaping (TradingMarkets?, String?) -> Void) {
        let httpDetails = KuCoinCalls.GetTradingMarkets()
        httpRequest(req: httpDetails, type: TradingMarkets.self, completion: completion)
    }
    
    func getOrderBook(pairing: PairInfo, completion: @escaping (KuCoinOrders?, String?) -> Void) {
        let args = "?symbol=" + pairing.symbol + "&limit=30"
        let httpDetails = KuCoinCalls.GetOrderBook(arguments: args)
        httpRequest(req: httpDetails, type: KuCoinOrders.self, completion: completion)
    }
    
    func placeOrder(amount: String, price: String, symbol: String, type: String, completion: @escaping (KuCoinMakeOrd?, String?) -> Void) {
        let args = "?amount=" + amount + "&price=" + price + "&symbol=" + symbol + "&type=" + type.uppercased()
        let httpDetails = KuCoinCalls.PlaceOrder(arguments: args)
        httpRequest(req: httpDetails, type: KuCoinMakeOrd.self, completion: completion)
    }
    
    func getOrderHistory(completion: @escaping (KuCoinHistory?, String?) -> Void) {
        let httpDetails = KuCoinCalls.GetOrderHistory(arguments: "")
        httpRequest(req: httpDetails, type: KuCoinHistory.self, completion: completion)
    }
    
    func cancelOrder(order: KuCoinOpenInfo, completion: @escaping (KuCoinMakeOrd?, String?) -> Void) {
        let args = "?orderOid=" + order.oid + "&symbol=" + order.coinType + "-" + order.coinTypePair + "&type=" + order.direction.uppercased()
        let httpDetails = KuCoinCalls.CancelOrder(arguments: args)
        httpRequest(req: httpDetails, type: KuCoinMakeOrd.self, completion: completion)
    }
    
    func getOpenOrders(completion: @escaping (KuCoinOpenOrd?, String?) -> Void) {
        let httpDetails = KuCoinCalls.GetOpenOrders()
        httpRequest(req: httpDetails, type: KuCoinOpenOrd.self, completion: completion)
    }
    
    func getCoinPrecision(completion: @escaping (KuCoinPrecision?, String?) -> Void) {
        let httpDetails = KuCoinCalls.CoinPrecision()
        httpRequest(req: httpDetails, type: KuCoinPrecision.self, completion: completion)
    }
    
    func getBalance(completion: @escaping (KuCoinBalances?, String?) -> Void) {
        let httpDetails = KuCoinCalls.GetBalance()
        httpRequest(req: httpDetails, type: KuCoinBalances.self, completion: completion)
    }
    
}

class KuCoinRequest: BaseAPI {
    init(httpMethod: HTTPMethod, endpoint: String?, authActive: Bool) {
        super.init(baseURL: "https://api.kucoin.com", httpMethod: httpMethod, authActive: authActive)
        self.endpoint = (endpoint ?? "")
        self.args = (args ?? "")
    }
    
    var message: String {
        let endpt = endpoint ?? ""
        let timestamp = "/" + "\(nonce)"
        let arguments = (args ?? "").replacingOccurrences(of: "?", with: "")
        let signed = endpt + timestamp + "/" + arguments
        let encodedString = Data(signed.utf8).base64EncodedString()
        return encodedString
    }
    
    override var request: URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = httpMethod.rawValue
        if authActive {
            let signed = HMAC.sign(message: message, algorithm: .sha256, key: KuCoin.shared.secret)
            req.addValue(KuCoin.shared.apiKey, forHTTPHeaderField: "KC-API-KEY")
            req.addValue("\(nonce)", forHTTPHeaderField: "KC-API-NONCE")
            req.addValue(signed!, forHTTPHeaderField: "KC-API-SIGNATURE")
        }
        return req
    }
    
}

class KuCoinCalls {
    class GetAllPairings: KuCoinRequest {
        init() {
            super.init(httpMethod: .get, endpoint: "/v1/open/tick", authActive: false)
        }
    }
    
    class PlaceOrder: KuCoinRequest {
        init(arguments: String) {
            super.init(httpMethod: .post, endpoint: "/v1/order", authActive: true)
            self.args = arguments
        }
    }
    
    class GetOrderHistory: KuCoinRequest {
        init(arguments: String) {
            super.init(httpMethod: .get, endpoint: "/v1/order/dealt", authActive: true)
            self.args = arguments
        }
    }
    
    class CancelOrder: KuCoinRequest {
        init(arguments: String) {
            super.init(httpMethod: .post, endpoint: "/v1/cancel-order", authActive: true)
            self.args = arguments
        }
    }
    
    class GetOpenOrders: KuCoinRequest {
        init() {
            super.init(httpMethod: .get, endpoint: "/v1/order/active-map", authActive: true)
            self.args = "?symbol="
        }
    }
    
    class CoinPrecision: KuCoinRequest {
        init() {
            super.init(httpMethod: .get, endpoint: "/v1/market/open/coins", authActive: false)
        }
    }
    
    class GetCoinPairing: KuCoinRequest {
        init(arguments: String) {
            super.init(httpMethod: .get, endpoint: "/v1/open/tick", authActive: false)
            self.args = "?symbol=" + arguments
        }
    }
    
    class GetTradingMarkets: KuCoinRequest {
        init() {
            super.init(httpMethod: .get, endpoint: "/v1/open/markets", authActive: false)
        }
    }
    
    class GetOrderBook: KuCoinRequest {
        init(arguments: String) {
            super.init(httpMethod: .get, endpoint: "/v1/open/orders", authActive: false)
            self.args = arguments
        }
    }
    
    class GetBalance: KuCoinRequest {
        init() {
            super.init(httpMethod: .get, endpoint: "/v1/account/balance", authActive: true)
        }
    }
}
