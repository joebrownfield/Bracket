//
//  EthplorerModel.swift
//  Bracket
//
//  Created by Joseph Brownfield on 7/30/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import Foundation

public struct EthplorerEth: Codable {
    let balance: Double
    
    enum CodingKeys: String, CodingKey {
        case
        balance
    }
}

public struct EthplorerError: Codable {
    let code: Int?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case
        code,
        message
    }
}

public struct EthplorerBalance: Codable {
    let address: String
    let eth: EthplorerEth
    let tokens: [EthplorerTokens]?
    let error: Bool
    
    enum CodingKeys: String, CodingKey {
        case
        address,
        eth = "ETH",
        tokens,
        error
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
        case
        tokenInfo = "tokenInfo",
        balance,
        totalIn = "totalIn",
        totalOut = "totalOut"
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
