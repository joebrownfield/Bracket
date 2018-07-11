//
//  Bittrex.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/5/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import Foundation

class Bittrex {
    var apiKey = ""
    var secret = ""
    let exchg: Exchanges = .bittrex
}

extension Bittrex {
    func getAllPairings(completion: @escaping (BittrexCoinPairings?, String?) -> Void) {
        let httpDetails = BittrexCalls.GetAllPairings()
        httpRequest(req: httpDetails, type: BittrexCoinPairings.self, completion: completion)
    }
    
    func getOrderBook(pairing: PairInfo, completion: @escaping (BittrexOrders?, String?) -> Void) {
        let args = "?market=" + pairing.coinTypePair + "-" + pairing.coinType + "&type=both"
        let httpDetails = BittrexCalls.GetOrderBook(arguments: args)
        httpRequest(req: httpDetails, type: BittrexOrders.self, completion: completion)
    }
    
}

class BittrexRequest: BaseAPI {
    init(httpMethod: HTTPMethod, endpoint: String?, authActive: Bool) {
        super.init(baseURL: "https://bittrex.com/api/v1.1", httpMethod: httpMethod, authActive: authActive)
        self.endpoint = (endpoint ?? "")
        self.args = (args ?? "")
    }
}

class BittrexCalls {
    class GetAllPairings: BittrexRequest {
        init() {
            super.init(httpMethod: .get, endpoint: "/public/getmarketsummaries", authActive: false)
        }
    }
    
    class GetOrderBook: BittrexRequest {
        init(arguments: String) {
            super.init(httpMethod: .get, endpoint: "/public/getorderbook", authActive: false)
            self.args = arguments
        }
    }
}
