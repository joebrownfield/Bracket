//
//  Idex.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/5/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import Foundation

final class IDEX {
    static let shared = IDEX(apiKey: "", secret: "")
    var apiKey = ""
    var secret = ""
    let exchg: Exchanges = .idex
    
    public init(apiKey: String, secret: String) {
        self.apiKey = apiKey
        self.secret = secret
    }
}

extension IDEX {
    func getAllPairings(completion: @escaping ([String : IDEXPairInfo]?, String?) -> Void) {
        let httpDetails = IDEXCalls.GetAllPairings()
        httpRequest(req: httpDetails, type: [String : IDEXPairInfo].self, completion: completion)
    }
    
    func getTradingMarkets() -> [String] {
        return ["ETH"]
    }
    
    func getOrderBook(pairing: PairInfo, completion: @escaping (IDEXOrders?, String?) -> Void) {
        let args = "?market=" + pairing.coinTypePair + "_" + pairing.coinType
        let httpDetails = IDEXCalls.GetOrderBook(arguments: args)
        httpRequest(req: httpDetails, type: IDEXOrders.self, completion: completion)
    }
    
}

class IDEXRequest: BaseAPI {
    init(httpMethod: HTTPMethod, endpoint: String?, authActive: Bool) {
        super.init(baseURL: "https://api.idex.market", httpMethod: httpMethod, authActive: authActive)
        self.endpoint = (endpoint ?? "")
    }
}

class IDEXCalls {
    class GetAllPairings: IDEXRequest {
        init() {
            super.init(httpMethod: .post, endpoint: "/returnTicker", authActive: false)
        }
    }
    
    class GetTradingMarkets: IDEXRequest {
        init() {
            super.init(httpMethod: .get, endpoint: "/v1/open/markets", authActive: false)
        }
    }
    
    class GetOrderBook: IDEXRequest {
        init(arguments: String) {
            super.init(httpMethod: .get, endpoint: "/returnOrderBook", authActive: false)
            self.args = arguments
        }
    }
}
