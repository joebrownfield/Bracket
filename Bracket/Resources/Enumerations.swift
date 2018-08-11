//
//  Enumerations.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/5/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import Foundation

//---------------------------------------
// HTTP Method Enums
//---------------------------------------
enum HTTPMethod: String {
    case get
    case post
}

enum OrderBookType: String {
    case buy = "Buy"
    case sell = "Sell"
}

enum BuyOrSell: String {
    case buy
    case sell
}

enum MarketOrderTypes: String {
    case market = "Market"
    case limit = "Limit"
    case marketOrder = "Market Order"
    case limitOrder = "Limit Order"
    case buy = "Buy"
    case sell = "Sell"
}

enum TradeTabTypes: String {
    case trade = "Trade"
    case openOrders = "Open Orders"
}

enum DropdownOptions: String {
    case history = "View Order History"
    case open = "View Open Orders"
    case nightMode = "Toggle Night Mode"
}

enum AlertMessages: String {
    case limitTitle = "Error"
    case limitMessage = "Please input a price first"
    case maxOrderBookTitle = "Maximum Reached"
    case maxOrderBookMessage = "The amount entered fills the entire order book, the amounts reflect the entire order book."
    case unfilledFieldsTitle = "Invalid Values"
    case unfilledFieldsMessage = "Please fill out all of the fields before placing an order"
    case noSellsTitle = "No Sell Orders"
    case noSells = "There are no orders in the sell book"
    case noBuysTitle = "No Buy Orders"
    case noBuys = "There are no orders in the buy book"
    case largeOrderTitle = "Order Too Large"
    case largeOrder = "Please contact a sales representative to place an order this high."
}

enum TextFieldNames: String {
    case baseAmount = "Base Amount"
    case quoteAmount = "Quote Amount"
}

enum WalletSaveErrors: String {
    case success = "This wallet address has successfully been saved."
    case genericError = "Error saving wallet."
    case duplicate = "You have already saved this wallet address."
    case empty = "Please enter a value for the wallet address."
    case incorrect = "Please check your wallet address as it is incorrect."
}
