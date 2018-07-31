//
//  Ethplorer.swift
//  Bracket
//
//  Created by Joseph Brownfield on 7/25/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import Foundation

final class Ethplorer {
    private let apiKey = "freekey"
}

extension Ethplorer {
    func getEthWalletBalance(address: String, completion: @escaping (EthplorerBalance?, String?) -> Void) {
        let args = address + "?apiKey=" + apiKey
        let httpDetails = EthplorerCalls.GetBaselinePrices(arguments: args)
        httpRequest(req: httpDetails, type: EthplorerBalance.self, completion: completion)
    }
    
//    func getEthWalletBalances(pair: String, completion: @escaping (EtherscanPairsInfo?, String?) -> Void) {
//        let args = "/" + pair + "/spot"
//        let httpDetails = EtherscanCalls.GetBaselinePrices(arguments: args)
//        httpRequest(req: httpDetails, type: EtherscanPairsInfo.self, completion: completion)
//    }
    
}

class EthplorerRequests: BaseAPI {
    init(httpMethod: HTTPMethod, endpoint: String?, authActive: Bool) {
        super.init(baseURL: "https://api.ethplorer.io", httpMethod: httpMethod, authActive: authActive)
        self.endpoint = (endpoint ?? "")
    }
}

class EthplorerCalls {
    class GetBaselinePrices: EthplorerRequests {
        init(arguments: String) {
            super.init(httpMethod: .get, endpoint: "/getAddressInfo/", authActive: false)
            self.args = arguments
        }
    }
}
