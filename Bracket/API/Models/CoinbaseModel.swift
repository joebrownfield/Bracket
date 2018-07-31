//
//  CoinbaseModel.swift
//  Bracket
//
//  Created by Joseph Brownfield on 7/30/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import Foundation

public struct CoinbasePairsInfo: Codable {
    let data: CoinbasePairInfo
    
    enum CodingKeys: String, CodingKey {
        case
        data
    }
}

public struct CoinbasePairInfo: Codable {
    let base: String
    let currency: String
    let amount: String
    
    enum CodingKeys: String, CodingKey {
        case
        base,
        currency,
        amount
    }
}
