//
//  Coinbase.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/24/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import Foundation

final class Coinbase {
    static let shared: Coinbase = Coinbase()
    let basePairs: [String] = ["BTC-USD","ETH-USD"]
}

extension Coinbase {
    func getBaselinePrices(pair: String, completion: @escaping (CoinbasePairsInfo?, String?) -> Void) {
        let args = "/" + pair + "/spot"
        let httpDetails = CoinbaseCalls.GetBaselinePrices(arguments: args)
        httpRequest(req: httpDetails, type: CoinbasePairsInfo.self, completion: completion)
    }
    
}

class CoinbaseRequest: BaseAPI {
    init(httpMethod: HTTPMethod, endpoint: String?, authActive: Bool) {
        super.init(baseURL: "https://api.coinbase.com/v2", httpMethod: httpMethod, authActive: authActive)
        self.endpoint = (endpoint ?? "")
    }
}

final class CoinbaseCalls {
    class GetBaselinePrices: CoinbaseRequest {
        init(arguments: String) {
            super.init(httpMethod: .get, endpoint: "/prices", authActive: false)
            self.args = arguments
        }
    }
}

class CMCRequest: BaseAPI {
    init(httpMethod: HTTPMethod, endpoint: String?, authActive: Bool) {
        super.init(baseURL: "https://api.coinmarketcap.com", httpMethod: httpMethod, authActive: authActive)
        self.endpoint = (endpoint ?? "")
    }
}

final class CMCCalls {
    
    func getBaselinePrices(completion: @escaping ([CMCData]?, String?) -> Void) {
        let httpDetails = CMCCalls.GetBaselinePrices()
        httpRequest(req: httpDetails, type: [CMCData].self, completion: completion)
    }
    
    class GetBaselinePrices: CMCRequest {
        init() {
            super.init(httpMethod: .get, endpoint: "/v1/ticker/?limit=0", authActive: false)
        }
    }
}
