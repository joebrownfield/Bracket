//
//  CoreDataHelpers.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/27/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit
import CoreData

func getStoredExchgKeys() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let keyFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ExchgKeys")
    do {
        let keys = try managedContext.fetch(keyFetch)
        for key in keys {
            let keyValue = key as! ExchgKeys
            let mainPageOptions = MainPageOptions()
            let exchg = mainPageOptions.options.filter { $0.rawValue == keyValue.exchange }
            if exchg.count > 0 {
                let apiKey = APIKeyValues(exchange: exchg[0], apiKey: keyValue.apiKey, secretKey: keyValue.secret)
                updateExchangeKeys(apiKey: apiKey)
            }
        }
    } catch let error as NSError {
        print(error)
    }
}

func updateExchangeKeys(apiKey: APIKeyValues) {
    let exchg = apiKey.exchange!
    
    switch exchg {
    case .idex:
        AllKeys.idexShared.apiKey = apiKey.apiKey!
        AllKeys.idexShared.secret = apiKey.secretKey!
    case .bittrex:
        break
        //Bittrex.sharedInstance.apiKey = apiKey.apiKey!
        //Bittrex.sharedInstance.secret = apiKey.secretKey!
    case .kucoin:
        AllKeys.kuCoinShared.apiKey = apiKey.apiKey!
        AllKeys.kuCoinShared.secret = apiKey.secretKey!
    default:
        break
    }
}

func getKeyBaselines(exchangeOptions: inout [APIKeyValues]) {
    let mainPageOptions = MainPageOptions()
    let options = mainPageOptions.options.filter { $0 != .combination }
    for option in options {
        exchangeOptions.append(APIKeyValues(exchange: option, apiKey: "", secretKey: ""))
    }
}

func getWallets(wallets: inout [Wallets], exchangeOptions: inout [APIKeyValues]) {
    
    getStoredWallets(&wallets)
    
    getExchgKeys(&exchangeOptions)
    
    TickerInformation.sharedInstance.wallets = wallets
    TickerInformation.sharedInstance.exchangeOptions = exchangeOptions
    
}

func getStoredWallets(_ wallets: inout [Wallets]) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let keyFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Wallets")
    do {
        let keys = try managedContext.fetch(keyFetch)
        for key in keys {
            print(key)
            let keyValue = key as! Wallets
            wallets.append(keyValue)
        }
    } catch let error as NSError {
        print(error)
    }
}

func getExchgKeys(_ exchangeOptions: inout [APIKeyValues]) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let keyFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ExchgKeys")
    do {
        let keys = try managedContext.fetch(keyFetch)
        for key in keys {
            let keyValue = key as! ExchgKeys
            if let index = exchangeOptions.index(where: { $0.exchange?.rawValue == keyValue.exchange }) {
                updateApiArray(apiKey: APIKeyValues(exchange: exchangeOptions[index].exchange, apiKey: keyValue.apiKey, secretKey: keyValue.secret), exchangeOptions: &exchangeOptions)
            }
        }
    } catch let error as NSError {
        print(error)
    }
}


func updateApiArray(apiKey: APIKeyValues, exchangeOptions: inout [APIKeyValues]) {
    if let index = exchangeOptions.index(where: { $0.exchange == apiKey.exchange }) {
        exchangeOptions[index].apiKey = apiKey.apiKey
        exchangeOptions[index].secretKey = apiKey.secretKey
        
        updateExchangeKeys(apiKey: apiKey)
        
    }
}

func getExchgOpenOrders(exchg: Exchanges, completion: @escaping () -> Void) {
    switch exchg {
    case .kucoin:
        let kuCoin = KuCoin(apiKey: AllKeys.kuCoinShared.apiKey, secret: AllKeys.kuCoinShared.secret)
        kuCoin.getOpenOrders { (results, error) in
            guard let result = results?.data else {
                completion()
                return
            }
            var combined: [KuCoinOpenInfo] = TickerInformation.sharedInstance.openOrders.filter { $0.exchg != exchg.rawValue }
            for buy in result.buy {
                var newBuy = buy
                newBuy.exchg = exchg.rawValue
                combined.append(newBuy)
            }
            for sell in result.sell {
                var newSell = sell
                newSell.exchg = exchg.rawValue
                combined.append(newSell)
            }
            print(combined)
            TickerInformation.sharedInstance.openOrders = combined
            completion()
        }
    case .bittrex:
        completion()
    default:
        completion()
    }
}

func getAllOpenOrders() {
    for exchg in MainPageOptions().options {
        getExchgOpenOrders(exchg: exchg) {
            
        }
    }
}

func updateAllBalances(activeVC: UIViewController, completion: @escaping () -> Void ) {
    let kuCoin = KuCoin(apiKey: AllKeys.kuCoinShared.apiKey, secret: AllKeys.kuCoinShared.secret)
    
    let eb = ExchangeBalances.sharedInstance
    
    getAllOpenOrders()
    
    for exchg in MainPageOptions().options {
        switch exchg {
        case .idex:
            guard AllKeys.idexShared.apiKey != "" else {
                completion()
                break
            }
            break
        case .bittrex:
            guard AllKeys.bittrexShared.apiKey != "" else {
                completion()
                break
            }
            break
        case .kucoin:
            guard AllKeys.kuCoinShared.apiKey != "" else {
                completion()
                break
            }
            kuCoin.getBalance { (results, error) in
                DispatchQueue.main.async {
                    guard let data = results?.data else {
                        displayBalanceLoadAlert(activeVC, exchg)
                        completion()
                        return
                    }
                    let balance = data.filter { $0.balance > 15 || $0.freezeBalance > 15 || ["ETH","BTC"].contains($0.coinType) }
                    eb.exchangeBalances = eb.exchangeBalances.filter { $0.exchange.rawValue != kuCoin.exchg.rawValue }
                    for bal in balance {
                        let price: String
                        if bal.coinType == "ETH" {
                            price = "1.0000000"
                        } else {
                            price = ""
                        }
                        eb.exchangeBalances.append(ExchangeBalance(exchange: kuCoin.exchg, balance: bal.balance, balanceStr: bal.balanceStr, coinType: bal.coinType, freezeBalance: bal.freezeBalance, freezeBalanceStr: bal.freezeBalanceStr, change: "", price: price))
                    }
                    completion()
                }
            }
        default:
            break
        }
    }
    
}

func displayBalanceLoadAlert(_ activeVC: UIViewController, _ exchg: Exchanges) {
    let message = "Error loading " + exchg.rawValue + " balance"
    activeVC.alert(message: message, title: "Error")
}

func preloadAllData(activeVC: UIViewController) {
    activeVC.view.addActivityIndicator("Loading Data")
    
    let basePairs = Coinbase().basePairs
    TickerInformation.sharedInstance.currencyPrices = [CoinbasePairInfo]()
    getCoinbaseBasePrices(basePair: basePairs[0]) {
        getCoinbaseBasePrices(basePair: basePairs[1], completion: {
            DispatchQueue.main.async {
                getStoredExchgKeys()
                DispatchQueue.main.async {
                    updateAllPrecisions()
                }
                DispatchQueue.main.async {
                    getAllOrderHistory()
                }
                updateAllBalances(activeVC: activeVC, completion: {
                    updateChangePercent(ExchangeBalances.sharedInstance.exchangeBalances, completion: {
                        activeVC.view.removeActivityIndicator()
                    })
                })
                
            }
        })
    }
}

func getAllOrderHistory() {
    for exchg in MainPageOptions().options {
        getExchgOrderHistory(exchg)
    }
}

func getExchgOrderHistory(_ exchg: Exchanges) {
    switch exchg {
    case .kucoin:
        let kuCoin = KuCoin(apiKey: AllKeys.kuCoinShared.apiKey, secret: AllKeys.kuCoinShared.secret)
        kuCoin.getOrderHistory { (results, error) in
            guard let results = results, results.success == true else { return }
            TickerInformation.sharedInstance.exchgOrderHist = TickerInformation.sharedInstance.exchgOrderHist.filter { $0.exchg != exchg.rawValue }
            let data = results.data.datas
            for order in data {
                var newOrder = order
                newOrder.exchg = exchg.rawValue
                TickerInformation.sharedInstance.exchgOrderHist.append(newOrder)
            }
        }
    default:
        break
    }
}

func updateAllPrecisions() {
    for exchg in MainPageOptions().options {
        updatePrecisionArray(exchg: exchg)
    }
}

func updatePrecisionArray(exchg: Exchanges) {
    switch exchg {
    case .kucoin:
        let precisionArray = TickerInformation.sharedInstance.coinPrecisions
        if precisionArray.count < 1 {
            let kuCoin = KuCoin(apiKey: AllKeys.kuCoinShared.apiKey, secret: AllKeys.kuCoinShared.secret)
            kuCoin.getCoinPrecision() { (results, error) in
                guard let result = results?.data else {
                    return
                }
                var updatedValues: [String : Int] = [String : Int]()
                for resultValue in result {
                    updatedValues[resultValue.coin] = resultValue.tradePrecision
                }
                TickerInformation.sharedInstance.coinPrecisions = updatedValues
            }
        }
    default:
        break
    }
}

func updateChangePercent(_ coinBalances: [ExchangeBalance], completion: @escaping () -> Void) {
    guard coinBalances.count > 0 else {
        completion()
        return
    }
    for i in 0...coinBalances.count - 1 {
        let coinBalance = coinBalances[i]
        guard !(["ETH"].contains(coinBalance.coinType)) else { continue }
        switch coinBalance.exchange {
        case .kucoin:
            let kuCoin = KuCoin(apiKey: AllKeys.kuCoinShared.apiKey, secret: AllKeys.kuCoinShared.secret)
            let symbol: String
            if coinBalance.coinType == "BTC" {
                symbol = "ETH-BTC"
            } else {
                symbol = coinBalance.coinType + "-" + "ETH"
            }
            kuCoin.getCoinPairing(symbol: symbol) { (results, error) in
                guard let results = results, let coinInfo = results.data as PairInfo? else { return }
                DispatchQueue.main.async {
                    var updatedValue = ExchangeBalances.sharedInstance.exchangeBalances[i]
                    updatedValue.change = coinInfo.changeRate
                    let lastDealPrice = "\(coinInfo.lastDealPrice)"
                    updatedValue.price = lastDealPrice.numberToStringFormat(7)
                    ExchangeBalances.sharedInstance.exchangeBalances[i] = updatedValue
                    
                }
                
            }
        default:
            break
        }
    }
    completion()
}

func globalUpdateBal(exchg: Exchanges, coinType: String, amount: Double) {
    guard ExchangeBalances.sharedInstance.exchangeBalances.count > 0 else { return }
    for i in 0...ExchangeBalances.sharedInstance.exchangeBalances.count - 1 {
        var eb = ExchangeBalances.sharedInstance.exchangeBalances[i]
        if eb.coinType == coinType {
            eb.balance += amount
            let decimals: Int
            if TickerInformation.sharedInstance.coinPrecisions[coinType] != nil {
                decimals = TickerInformation.sharedInstance.coinPrecisions[coinType]!
            } else {
                decimals = 2
            }
            eb.balanceStr = eb.balance.toString().numberToStringFormat(decimals)
            ExchangeBalances.sharedInstance.exchangeBalances[i] = eb
        }
    }
}
