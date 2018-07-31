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
    guard let exchg = apiKey.exchange else { return }
    
    switch exchg {
    case .idex:
        IDEX.shared.apiKey = apiKey.apiKey!
        IDEX.shared.secret = apiKey.secretKey!
    case .bittrex:
        Bittrex.shared.apiKey = apiKey.apiKey!
        Bittrex.shared.secret = apiKey.secretKey!
    case .kucoin:
        KuCoin.shared.apiKey = apiKey.apiKey!
        KuCoin.shared.secret = apiKey.secretKey!
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
        KuCoin.shared.getOpenOrders { (results, error) in
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

func setEbValue(eb: ExchangeBalance) {
    if let index = ExchangeBalances.sharedInstance.exchangeBalances.index(where: { $0.exchange == Exchanges.wallet && $0.coinType == eb.coinType && $0.address == eb.address }) {
        ExchangeBalances.sharedInstance.exchangeBalances[index] = eb
    } else {
        ExchangeBalances.sharedInstance.exchangeBalances.append(eb)
    }
}

func getAllWalletInfo() {
    
    let ethplorer = Ethplorer()
    var wallets = [Wallets]()
    getStoredWallets(&wallets)
    TickerInformation.sharedInstance.wallets = wallets
    
    for wallet in wallets {
        guard let address = wallet.address else { continue }
        ethplorer.getEthWalletBalance(address: address) { (results, error) in
            guard let results = results, let tokens = results.tokens, let eth = results.eth as EthplorerEth? else { return }
            if eth.balance > 0.01 {
                let balanceString = eth.balance.toString().numberToStringFormat(7)
                let eb = ExchangeBalance(exchange: .wallet, balance: eth.balance, balanceStr: balanceString, coinType: "ETH", freezeBalance: 0, freezeBalanceStr: "", change: "", price: "1.0000000", address: address)
                setEbValue(eb: eb)
            }
            for token in tokens {
                guard (token.tokenInfo.priceSwitch), let decimals = token.tokenInfo.decimals as String?, decimals != "0", decimals != "" else { continue }
                // I know this is not the best way to do this, and I will use other libraries or convert the numbers to integer values that can be handled
                // but for now for testing I am just doing pow(10, decimals)
                let balance = token.balance / pow(10, decimals.toDouble())
                guard balance > 1 else { continue }
                let balanceString = balance.toString().numberToStringFormat(7)
                let price: String
                if let basePrice = TickerInformation.sharedInstance.currencyPrices.first(where: { $0.base == "ETH" }), token.tokenInfo.price?.currency == "USD" {
                    let priceValue = (token.tokenInfo.price?.rate.toDouble())! / basePrice.amount.toDouble()
                    price = "\(priceValue)"
                } else {
                    price = ""
                }
                let eb = ExchangeBalance(exchange: .wallet, balance: balance, balanceStr: balanceString, coinType: token.tokenInfo.symbol, freezeBalance: 0, freezeBalanceStr: "", change: "", price: price.numberToStringFormat(7), address: address)
                setEbValue(eb: eb)
            }
        }
    }
}

func updateAllBalances(activeVC: UIViewController, completion: @escaping () -> Void ) {
    
    getAllOpenOrders()
    
    getAllWalletInfo()
    
    let mainPageOptions = MainPageOptions().options
    
    var overallCompletion: Int = 0
    
    for exchg in mainPageOptions {
        getExchgBalance(activeVC: activeVC, exchg: exchg) { (success) in
            overallCompletion += 1
            if (success) {
                let eb = ExchangeBalances.sharedInstance.exchangeBalances.filter { $0.exchange == exchg }
                if let exchangeBalance = eb.first {
                    updateChangePercent(exchangeBalance)
                }
            }
            if overallCompletion == mainPageOptions.count {
                completion()
            }
        }
    }
    
}

func getExchgBalance(activeVC: UIViewController, exchg: Exchanges, completion: @escaping (Bool) -> Void) {
    let eb = ExchangeBalances.sharedInstance
    
    switch exchg {
    case .idex:
        guard IDEX.shared.apiKey != "" else {
            completion(false)
            break
        }
        completion(false)
        break
    case .bittrex:
        guard Bittrex.shared.apiKey != "" else {
            completion(false)
            break
        }
        completion(false)
        break
    case .kucoin:
        let kuCoin = KuCoin.shared
        guard kuCoin.apiKey != "" else {
            completion(false)
            break
        }
        kuCoin.getBalance { (results, error) in
            DispatchQueue.main.async {
                guard let data = results?.data else {
                    displayBalanceLoadAlert(activeVC, exchg)
                    completion(false)
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
                    eb.exchangeBalances.append(ExchangeBalance(exchange: kuCoin.exchg, balance: bal.balance, balanceStr: bal.balanceStr, coinType: bal.coinType, freezeBalance: bal.freezeBalance, freezeBalanceStr: bal.freezeBalanceStr, change: "", price: price, address: ""))
                }
                completion(true)
            }
        }
    default:
        completion(false)
        break
    }
}

func displayBalanceLoadAlert(_ activeVC: UIViewController, _ exchg: Exchanges) {
    let message = "Error loading " + exchg.rawValue + " balance"
    DispatchQueue.main.async {
        activeVC.view.removeActivityIndicator()
        activeVC.alert(message: message, title: "Error")
    }
}

func getCoinbaseBasePrices(basePair: String, completion: @escaping () -> Void ) {
    let coinbase = Coinbase()
    coinbase.getBaselinePrices(pair: basePair) { (results, error) in
        guard let pairs = results else {
            completion()
            return
        }
        TickerInformation.sharedInstance.currencyPrices.append(pairs.data)
        completion()
    }
}

func preloadAllData(activeVC: UIViewController) {
    activeVC.view.addActivityIndicator("Loading Data")
    
    let basePairs = Coinbase.shared.basePairs
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
                    activeVC.view.removeActivityIndicator()
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
        KuCoin.shared.getOrderHistory { (results, error) in
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
            KuCoin.shared.getCoinPrecision() { (results, error) in
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

func updateChangePercent(_ coinBalance: ExchangeBalance) {
    
    guard !(["ETH"].contains(coinBalance.coinType)) else { return }
    switch coinBalance.exchange {
    case .kucoin:
        let symbol: String
        if coinBalance.coinType == "BTC" {
            symbol = "ETH-BTC"
        } else {
            symbol = coinBalance.coinType + "-" + "ETH"
        }
        KuCoin.shared.getCoinPairing(symbol: symbol) { (results, error) in
            guard let results = results, let coinInfo = results.data as PairInfo? else { return }
            DispatchQueue.main.async {
                if let index = ExchangeBalances.sharedInstance.exchangeBalances.index(where: { $0.exchange == coinBalance.exchange && $0.coinType == coinBalance.coinType }) {
                    var updatedValue = ExchangeBalances.sharedInstance.exchangeBalances[index]
                    updatedValue.change = coinInfo.changeRate
                    let lastDealPrice = "\(coinInfo.lastDealPrice)"
                    updatedValue.price = lastDealPrice.numberToStringFormat(7)
                    ExchangeBalances.sharedInstance.exchangeBalances[index] = updatedValue
                }
            }
            
        }
    default:
        break
    }
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
