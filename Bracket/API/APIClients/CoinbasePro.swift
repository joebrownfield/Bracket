//
//  CoinbasePro.swift
//  Bracket
//
//  Created by Joseph Brownfield on 7/27/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import Foundation

final class CoinbasePro {
    static let shared = CoinbasePro(apiKey: "", secret: "")
    var apiKey = ""
    var secret = ""
    let exchg: Exchanges = .coinbase
    
    public init(apiKey: String, secret: String) {
        self.apiKey = apiKey
        self.secret = secret
    }
}
