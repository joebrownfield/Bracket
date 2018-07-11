//
//  TradingController.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/21/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit
import SafariServices

class TradingController: UIViewController, UITextFieldDelegate {
    
    //==================================================================
    // Variables
    //==================================================================
    let kuCoin = KuCoin(apiKey: AllKeys.kuCoinShared.apiKey, secret: AllKeys.kuCoinShared.secret)
    let idex = IDEX()
    let bittrex = Bittrex()
    
    lazy var sellBook: OrderBook = {
        let sellOrderBook = OrderBook()
        sellOrderBook.bookType = OrderBookType.sell.rawValue
        sellOrderBook.orderBookController = self
        return sellOrderBook
    }()
    
    lazy var buyBook: OrderBook = {
        let buyOrderBook = OrderBook()
        buyOrderBook.bookType = OrderBookType.buy.rawValue
        buyOrderBook.orderBookController = self
        return buyOrderBook
    }()
    
    lazy var openOrderBook: OpenOrdersView = {
        let openOrderBook = OpenOrdersView()
        openOrderBook.orderBookController = self
        return openOrderBook
    }()
    
    lazy var orderTracker: UIView = {
        let orderTrack = UIView()
        orderTrack.layer.cornerRadius = 5
        orderTrack.layer.masksToBounds = true
        return orderTrack
    }()
    
    struct OrderBookAsksBids {
        var asks = [Order]()
        var bids = [Order]()
    }
    
    var orderBooks: OrderBookAsksBids = OrderBookAsksBids(asks: [Order](), bids: [Order]())
    
    let priceLabel = GenericLabel("Price", .center, fontRegular(12), MainPageOptions().navigationTitleColor)
    
    let marketSizeLabel = GenericLabel("Amount", .center, fontRegular(12), MainPageOptions().navigationTitleColor)
    
    let orderSpreadLabel: UILabel = {
        let label = GenericLabel("Spread:     ", .center, fontLight(10), MainPageOptions().navigationTitleColor)
        label.backgroundColor = .clear
        return label
    }()
    
    let availableBaseLabel = GenericLabel("", .left, fontRegular(12), MainPageOptions().navigationTitleColor)
    
    let availableAmountLabel = GenericLabel("", .left, fontRegular(12), MainPageOptions().navigationTitleColor)
    
    let lastPriceLabel = GenericLabel("", .left, fontRegular(18), MainPageOptions().navigationTitleColor)
    
    let totalLabel = GenericLabel("Total", .left, fontLight(12), MainPageOptions().navigationTitleColor)
    
    let totalAmountLabel = GenericLabel("", .right, fontLight(12), MainPageOptions().navigationTitleColor)
    
    let tradeOrderUnderlineText: UILabel = {
        let label = GenericLabel(TradeTabTypes.trade.rawValue, .center, fontRegular(15), MainPageOptions().tabBarColor)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let openOrderUnderlineText: UILabel = {
        let label = GenericLabel(TradeTabTypes.openOrders.rawValue, .center, fontRegular(15), MainPageOptions().navigationTitleColor)
        label.alpha = 0.5
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let tradeOrderUnderline = GenericUnderline(color: MainPageOptions().tabBarColor, alpha: 1)
    
    let openOrderUnderline = GenericUnderline(color: MainPageOptions().navigationTitleColor, alpha: 0.1)
    
    let quoteCurrencyPrice = GenericNumTextField("Price", .center, fontLight(15))
    
    let baseCurrencyAmount = GenericNumTextField("Amount", .center, fontLight(15))
    
    let totalAmountLabelsView: UIView = UIView()
    
    let marketOrderButton = GenericButton(title: MarketOrderTypes.buy.rawValue, radius: 3, color: MainPageOptions().darkGreen, font: fontLight(15))
    
    let viewChartsButton: UIButton = {
        let button = GenericButton(title: "View Charts", radius: 3, color: UIColor.clear, font: fontLight(15))
        button.layer.borderWidth = 1
        let color = MainPageOptions().labelColor
        button.layer.borderColor = color.cgColor
        button.setTitleColor(color, for: .normal)
        button.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.5), for: .highlighted)
        return button
    }()
    
    let buySellControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: [MarketOrderTypes.buy.rawValue,MarketOrderTypes.sell.rawValue])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = MainPageOptions().darkGreen
        segmentedControl.layer.cornerRadius = 5
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: MainPageOptions().tabBarUnselected], for: .normal)
        return segmentedControl
    }()
    
    //Tracker variables which will be used in the different functions in this View Controller
    var activeOrderLabel: String = TradeTabTypes.trade.rawValue
    var textFieldArray: [UITextField] = [UITextField]()
    var loadTimer: Timer = Timer()
    let mainPageOptions = MainPageOptions()
    var prevTextValue: String = ""
    var baseDecimals: Int = 4
    var quoteDecimals: Int = 8
    
    //The starting ticker for which we will use when the app loads
    var activePair: PairInfo?
    var activeExchg: Exchanges = .none
    var openOrders: [KuCoinOpenInfo] = [KuCoinOpenInfo]()
    
    //===============================================================
    // Finished declarations
    //===============================================================
    
    convenience init(getExchng: Exchanges, pair: PairInfo) {
        self.init()
        activePair = pair
        activeExchg = getExchng
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Since all of this app was done without Storyboarding, I have to add all of the sub views to the main view
        // so all this is doing is just adding those in
        addSubviewsToView()
        
        // Also, since I am not using the Storyboard, I have to set up the constraints. This is helpful though because I can
        // use screen size and other constraints to make the views dynamic for whatever screen the user is viewing it on
        addConstraintsToSubviews()
        
        // We want some user interaction so we are adding user interaction events to some of the views added above
        addGesturesAndTargets()
        
        // More styling, not a lot in the below function
        setupViewColorAndStyle()
        
        // Set up base values like price and currency
        setupBaseValues()
        
        // Getting the order book of the pair that was selected
        reloadOpenOrders(isTimer: false)
        
        // Hiding the keyboard when touching anywhere besides keyboard
        self.setupHideKeyboardOnTap()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //Stop when leaving view
        loadTimer.invalidate()
        loadTimer = Timer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Reload order books
        loadTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(reloadOnTimer), userInfo: nil, repeats: true)
    }
    
    private func addSubviewsToView() {
        view.addSubview(sellBook)
        view.addSubview(buyBook)
        view.addSubview(priceLabel)
        view.addSubview(marketSizeLabel)
        view.addSubview(orderSpreadLabel)
        view.addSubview(availableBaseLabel)
        view.addSubview(availableAmountLabel)
        view.addSubview(quoteCurrencyPrice)
        view.addSubview(baseCurrencyAmount)
        view.addSubview(totalAmountLabelsView)
        view.addSubview(marketOrderButton)
        view.addSubview(tradeOrderUnderlineText)
        view.addSubview(tradeOrderUnderline)
        view.addSubview(openOrderUnderlineText)
        view.addSubview(openOrderUnderline)
        view.addSubview(orderTracker)
        view.addSubview(buySellControl)
        view.addSubview(viewChartsButton)
        view.addSubview(lastPriceLabel)
        
        totalAmountLabelsView.addSubview(totalLabel)
        totalAmountLabelsView.addSubview(totalAmountLabel)
        
        view.addSubview(openOrderBook)
        
        
    }
    
    func updateAvailableAmounts(pair: PairInfo) {
        availableBaseLabel.text = "Available " + pair.coinTypePair + ":"
        availableAmountLabel.text = "Available " + pair.coinType + ":"
        if let balance = getBalanceValue(activeExchg, pair.coinType), let dec = TickerInformation.sharedInstance.coinPrecisions[pair.coinType] {
            availableAmountLabel.text = availableAmountLabel.text! + "  " +  balance.balanceStr.numberToStringFormat(dec)
        } else {
            availableAmountLabel.text = availableAmountLabel.text! + "  " + "0.0000"
        }
        
        if let balance = getBalanceValue(activeExchg, pair.coinTypePair), let dec = TickerInformation.sharedInstance.coinPrecisions[pair.coinTypePair] {
            availableBaseLabel.text = availableBaseLabel.text! + "  " + balance.balanceStr.numberToStringFormat(dec)
        } else {
            availableBaseLabel.text = availableBaseLabel.text! + "  " +  "0.0000"
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkTextFieldChanges(textField)
        prevTextValue = textField.text ?? ""
    }
    
    func checkTextFieldChanges(_ textField: UITextField) {
        //For limit orders, there has to be a price in order to calculate the amounts
        if quoteCurrencyPrice.text?.removeNonNumericCharacters() == "", textField != quoteCurrencyPrice {
            //Alert to pick a price first
            alert(message: AlertMessages.limitMessage.rawValue, title: AlertMessages.limitTitle.rawValue)
            textField.text = ""
            return
        }
        textField.text = textField.text?.removeNonNumericCharacters()
        //I am using a double here because we don't have a need to have precision past 10 decimal places
        let doubleValue = (textField.text! as NSString).doubleValue
        switch textField {
        case baseCurrencyAmount:
            convertBaseToQuoteAmount(doubleValue)
        case quoteCurrencyPrice:
            //Since we just need it to check the fields and repopulate, it doesn't matter which field (quote or base) we use
            //because we just need to update the two below text fields
            if baseCurrencyAmount.text != "" {
                checkTextFieldChanges(baseCurrencyAmount)
            }
        default:
            break
        }
    }
    
    func convertBaseToQuoteAmount(_ baseAmount: Double) {
        runOrderChecks(textField: TextFieldNames.baseAmount.rawValue, enteredAmount: baseAmount)
    }
    
    func convertQuoteToBaseAmount(_ quoteAmount: Double) {
        alert(message: "Check Function", title: "Title")
    }
    
    func runOrderChecks(textField: String, enteredAmount: Double) {
        
        var currencyAmount = enteredAmount
        let prevDouble = (prevTextValue as NSString).doubleValue
        let quoteCurrency = quoteCurrencyPrice.text?.removeNonNumericCharacters() as NSString?
        let quoteCurrencyValue = (quoteCurrency?.doubleValue)!
        if textField == TextFieldNames.baseAmount.rawValue {
            var maxAmount = getAvailCurr(quoteCurrencyValue)
            if prevDouble.rounded() >= maxAmount.rounded() {
                maxAmount = 0
            }
            if maxAmount != 0, maxAmount < enteredAmount {
                currencyAmount = maxAmount
                baseCurrencyAmount.text = currencyAmount.toString().numberToStringFormat(baseDecimals)
            }
            let quoteAmount = quoteCurrencyValue * currencyAmount
            let quoteAmountText = "\(quoteAmount)"
            totalAmountLabel.text = quoteAmountText.numberToStringFormat(quoteDecimals) + " " + (activePair?.coinTypePair)!
        } else if textField == TextFieldNames.quoteAmount.rawValue {
            let baseAmount = currencyAmount / quoteCurrencyValue
            let baseAmountText = "\(baseAmount)"
            baseCurrencyAmount.text = baseAmountText.numberToStringFormat(quoteDecimals)
        }
        
    }
    
    func getAvailCurr(_ price: Double) -> Double {
        if buySellControl.selectedSegmentIndex == 0 {
            return getAvailCurrency(self.availableBaseLabel.text!, price, MarketOrderTypes.buy)
        } else {
            return getAvailCurrency(self.availableAmountLabel.text!, price, MarketOrderTypes.sell)
        }
    }
    
    func getAvailCurrency(_ label: String, _ price: Double, _ type: MarketOrderTypes) -> Double {
        guard let baseAmtArray = label.components(separatedBy: ": ") as [String]?, baseAmtArray.count > 1, let baseAmt = baseAmtArray[1] as String? else { return 0 }
        let amount = baseAmt.toDouble()
        if amount > 0.01 {
            if type == MarketOrderTypes.buy {
                return amount / price
            } else {
                return amount
            }
        } else {
            return 0
        }
    }
    
    private func reloadOrderBooks() {
        
        self.sellBook.orderBookCollectionView.reloadData()
        self.buyBook.orderBookCollectionView.reloadData()
        
        if self.orderBooks.asks.count > 1 {
            self.sellBook.orderBookCollectionView.scrollToItem(at: IndexPath(item: self.orderBooks.asks.count - 1, section: 0), at: UICollectionViewScrollPosition.bottom, animated: false)
        }
    }
    
    private func reloadLabelValues(pair: PairInfo, asks: [Order], bids: [Order]) {
        
        reloadPlaceholderTexts(pair.coinType,pair.coinTypePair)
        self.priceLabel.text = "Price (" + pair.coinTypePair + ")"
        
        guard let lowAskPrice = Double(asks[0].order[0]) as Double?, let lowBidPrice = Double(bids[0].order[0]) as Double? else {
            return
        }
        let marketSpread = "\(lowAskPrice - lowBidPrice)"
        self.orderSpreadLabel.text = "Spread:     " + marketSpread.numberToStringFormat(7)
    }
    
    func reloadPlaceholderTexts(_ baseCurrency: String, _ quoteCurrency: String) {
        quoteCurrencyPrice.placeholder = "Price"
        quoteCurrencyPrice.text = ""
        
        totalAmountLabel.text = reloadTotalAmount(currency: quoteCurrency)
        
        baseCurrencyAmount.placeholder = "Amount"
        baseCurrencyAmount.text = ""
    }
    
    func reloadTotalAmount(currency: String) -> String {
        return "0.0000000 " + currency
    }
    
    @objc func orderTypeChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            setBackgroundColors(color: mainPageOptions.darkGreen)
            marketOrderButton.setTitle(MarketOrderTypes.buy.rawValue, for: [])
            clearTextFieldValues()
        } else {
            setBackgroundColors(color: mainPageOptions.darkRed)
            marketOrderButton.setTitle(MarketOrderTypes.sell.rawValue, for: [])
            clearTextFieldValues()
        }
    }
    
    @objc func buyOrSellPressed(sender: UIButton) {
        //Dismiss the keyboard if it's up
        self.view.endEditing(true)
        
        self.view.isUserInteractionEnabled = false
        
        //Submit a buy or sell order
        submitBuyOrSellOrder()
        
        // Updating the order tracker at the bottom with the order we submitted
        // probably not going to use
        updateOrderHistory()
        
        // If successful, reload balance
        reloadBalance()
        
    }
    
    @objc func viewChartsPressed() {
        showWebForPair(activePair!)
    }
    
    func showWebForPair(_ pair: PairInfo) {
        var UrlString: String!
        switch activeExchg {
        case .idex:
            UrlString = "https://idex.market/eth/" + pair.coinType.lowercased()
        case .bittrex:
            UrlString = "https://bittrex.com/Market/Index?MarketName=" + pair.coinTypePair.uppercased() + "-" + pair.coinType.uppercased()
        case .kucoin:
            UrlString = "https://www.kucoin.com/#/trade.pro/" + pair.symbol
        default:
            return
        }
        if let url = URL(string: UrlString) {
            let safariViewController = SFSafariViewController(url: url)
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.present(safariViewController, animated: true, completion: nil)
            }
        }
    }
    
    func submitBuyOrSellOrder() {
        guard (checkTextFieldEntries()), let price = quoteCurrencyPrice.text?.toDouble(), let amount = baseCurrencyAmount.text?.toDouble(), let pair = activePair else {
            return
        }
        
        let orderType = marketOrderButton.currentTitle
        let coinPrecisions = TickerInformation.sharedInstance.coinPrecisions
        let coinTypeP = coinPrecisions[pair.coinType]!
        let coinTypePairP = coinPrecisions[pair.coinTypePair]!
        
        placeOrder(exchg: activeExchg, price: price, amount: amount, pair: activePair!, coinTypeP: coinTypeP, coinTypePairP: coinTypePairP, orderType: orderType!)
        
    }
    
    func placeOrder(exchg: Exchanges, price: Double, amount: Double, pair: PairInfo, coinTypeP: Int, coinTypePairP: Int, orderType: String) {
        switch exchg {
        case .kucoin:
            let cAmount = amount.toString().numberToStringFormat(coinTypeP)
            let cPrice = price.toString().numberToStringFormat(coinTypePairP)
            kuCoin.placeOrder(amount: cAmount, price: cPrice, symbol: pair.symbol, type: orderType) { (results, error) in
                guard let results = results else { return }
                guard results.data != nil else {
                    DispatchQueue.main.async {
                        self.alert(message: results.msg, title: "Error")
                        self.view.isUserInteractionEnabled = true
                    }
                    return
                }
                if (results.success) {
                    DispatchQueue.main.async {
                        self.view.isUserInteractionEnabled = true
                        if orderType.lowercased() == MarketOrderTypes.buy.rawValue.lowercased() {
                            globalUpdateBal(exchg: self.activeExchg, coinType: (self.activePair?.coinTypePair)!, amount: (price * amount * -1))
                        } else {
                            globalUpdateBal(exchg: self.activeExchg, coinType: (self.activePair?.coinType)!, amount: (amount * -1))
                        }
                        self.reloadOpenOrders(isTimer: false)
                        self.alert(message: "Order successfully placed", title: "Success")
                    }
                }
            }
        default:
            self.view.isUserInteractionEnabled = true
            break
        }
    }
    
    @objc func reloadOnTimer() {
        print("Reloading")
        reloadOpenOrders(isTimer: true)
    }
    
    func reloadOpenOrders(isTimer: Bool) {
        getOrderBook(activePair!, isTimer)
        updateAvailableAmounts(pair: activePair!)
        getExchgOpenOrders(exchg: activeExchg) {
            DispatchQueue.main.async {
                self.checkForOpenOrders()
                self.openOrderBook.orderBookCollectionView.reloadData()
            }
        }
    }
    
    func checkForOpenOrders() {
        openOrders.removeAll()
        let allOpenOrders = TickerInformation.sharedInstance.openOrders
        for order in allOpenOrders {
            if order.coinType == activePair?.coinType {
                openOrders.append(order)
            }
        }
        openOrderBook.orderBookCollectionView.reloadData()
    }
    
    func checkTextFieldEntries() -> Bool {
        //make sure some data was entered into the text fields
        for textField in textFieldArray {
            if let fieldAmount = textField.text as NSString?, let fieldAmountValue = fieldAmount.doubleValue as Double? {
                if fieldAmountValue <= 0 {
                    alert(message: AlertMessages.unfilledFieldsMessage.rawValue, title: AlertMessages.unfilledFieldsTitle.rawValue)
                    return false
                }
            }
        }
        
        return true
    }
    
    func reloadBalance() {
        
    }
    
    func clearTextFieldValues() {
        for textField in textFieldArray {
            textField.text = ""
        }
        totalAmountLabel.text = reloadTotalAmount(currency: (activePair?.coinTypePair)!)
    }
    
    @objc func tradeOpenOrderChange(sender: UITapGestureRecognizer) {
        guard let touchedLabel = sender.view as? UILabel, touchedLabel.text != activeOrderLabel else {
            return
        }
        activeOrderLabel = touchedLabel.text!
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1) {
                self.clearTextFieldValues()
                if touchedLabel.text == TradeTabTypes.trade.rawValue {
                    self.showTradeViews()
                    self.tradeOrderUnderline.alpha = 1
                    self.tradeOrderUnderlineText.alpha = 1
                    self.tradeOrderUnderline.backgroundColor = self.mainPageOptions.tabBarColor
                    self.tradeOrderUnderlineText.textColor = self.mainPageOptions.tabBarColor
                    self.openOrderUnderline.alpha = 0.2
                    self.openOrderUnderlineText.alpha = 0.5
                    self.openOrderUnderline.backgroundColor = self.mainPageOptions.navigationTitleColor
                    self.openOrderUnderlineText.textColor = self.mainPageOptions.navigationTitleColor
                } else {
                    self.hideTradeViews()
                    self.tradeOrderUnderline.alpha = 0.2
                    self.tradeOrderUnderlineText.alpha = 0.5
                    self.tradeOrderUnderline.backgroundColor = self.mainPageOptions.navigationTitleColor
                    self.tradeOrderUnderlineText.textColor = self.mainPageOptions.navigationTitleColor
                    self.openOrderUnderline.alpha = 1
                    self.openOrderUnderlineText.alpha = 1
                    self.openOrderUnderline.backgroundColor = self.mainPageOptions.tabBarColor
                    self.openOrderUnderlineText.textColor = self.mainPageOptions.tabBarColor
                }
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func hideTradeViews() {
        openOrderBook.isHidden = false
        sellBook.isHidden = true
        buyBook.isHidden = true
        priceLabel.isHidden = true
        marketSizeLabel.isHidden = true
        orderSpreadLabel.isHidden = true
        availableBaseLabel.isHidden = true
        availableAmountLabel.isHidden = true
        quoteCurrencyPrice.isHidden = true
        baseCurrencyAmount.isHidden = true
        totalAmountLabelsView.isHidden = true
        marketOrderButton.isHidden = true
        orderTracker.isHidden = true
        buySellControl.isHidden = true
        viewChartsButton.isHidden = true
        lastPriceLabel.isHidden = true
    }
    
    func showTradeViews() {
        openOrderBook.isHidden = true
        sellBook.isHidden = false
        buyBook.isHidden = false
        priceLabel.isHidden = false
        marketSizeLabel.isHidden = false
        orderSpreadLabel.isHidden = false
        availableBaseLabel.isHidden = false
        availableAmountLabel.isHidden = false
        quoteCurrencyPrice.isHidden = false
        baseCurrencyAmount.isHidden = false
        totalAmountLabelsView.isHidden = false
        marketOrderButton.isHidden = false
        orderTracker.isHidden = false
        buySellControl.isHidden = false
        viewChartsButton.isHidden = false
        lastPriceLabel.isHidden = false
    }
    
    func setBackgroundColors(color: UIColor) {
        marketOrderButton.backgroundColor = color
        buySellControl.tintColor = color
    }
    
    func getOrderBook(_ pair: PairInfo, _ isTimer: Bool) {
        
        switch activeExchg {
        case .idex:
            loadIdexData(pair) { (asks, bids) in
                self.reloadEntireView(asks: asks, bids: bids, isTimer: isTimer)
            }
        case .bittrex:
            loadBittrexData(pair) { (asks, bids) in
                self.reloadEntireView(asks: asks, bids: bids, isTimer: isTimer)
            }
            break
        case .kucoin:
            loadKucoinData(pair) { (asks, bids) in
                self.reloadEntireView(asks: asks, bids: bids, isTimer: isTimer)
            }
        default:
            break
        }
        
    }
    
    func sortOrderBooks(_ asks: inout [Order], _ bids: inout [Order]) -> (Double, Double, Double, Double) {
        asks = asks.filter { $0.order[0] != "" }
        bids = bids.filter { $0.order[0] != "" }
        asks.sort { Double($0.order[0])! < Double($1.order[0])! }
        bids.sort { Double($0.order[0])! > Double($1.order[0])! }
        let askSum = asks.reduce(0, { $0 + (Double($1.order[0])! * Double($1.order[2])!) })
        let bidSum = bids.reduce(0, { $0 + (Double($1.order[0])! * Double($1.order[2])!) })
        let askVolumeSum = asks.reduce(0, { $0 + (Double($1.order[2])!) })
        let bidVolumeSum = bids.reduce(0, { $0 + (Double($1.order[2])!) })
        return (askSum, bidSum, askVolumeSum, bidVolumeSum)
    }
    
    private func reloadEntireView(asks: [Order], bids: [Order], isTimer: Bool) {
        DispatchQueue.main.async {
            if (isTimer) {
                self.sellBook.orderBookCollectionView.reloadData()
                self.buyBook.orderBookCollectionView.reloadData()
            } else {
                self.reloadOrderBooks()
                self.reloadLabelValues(pair: self.activePair!, asks: asks, bids: bids)
            }
        }
    }
    
    func updateOrderHistory() {
        
    }
    
    private func addConstraintsToSubviews() {
        
        //Grouping together the text fields so operations can be done on all of them at once
        textFieldArray = [quoteCurrencyPrice, baseCurrencyAmount]
        
        //Making a maximum spacing so on an iPad it doesn't look bad
        let (screenWidth, bookWidth, buttonHeight, textFieldSpacing, textFieldHeight, textLabelHeights, textFieldWidth, textFieldSides) = getTextFieldInfo()
        
        // Setting up the text labels for the total amount in base currency
        totalAmountLabelsView.setupViewConstraints(format: "H:|[v0(28)][v1]|", views: totalLabel, totalAmountLabel)
        totalAmountLabelsView.setupViewConstraints(format: "V:|[v0]|", views: totalLabel)
        totalAmountLabelsView.setupViewConstraints(format: "V:|[v0]|", views: totalAmountLabel)
        
        //Setting up the sellBook and buyBook placements
        view.setupViewConstraints(format: "H:[v0(\(bookWidth))]-10-|", views: sellBook)
        view.setupViewConstraints(format: "H:[v0(\(bookWidth))]-10-|", views: buyBook)
        view.setupViewConstraints(format: "H:[v0(\( (screenWidth / 2) - 20 ))]|", views: lastPriceLabel)
        
        //Organizing the whole block on the right side of the screen for the order book
        view.setupViewConstraints(format: "V:[v0]-10-[v3(20)]-10-[v2(\(textLabelHeights))]-5-[v1]", views: buySellControl, sellBook, priceLabel, lastPriceLabel)
        view.setupViewConstraints(format: "V:[v0]-20-[v1]|", views: sellBook, buyBook)
        sellBook.heightAnchor.constraint(equalTo: buyBook.heightAnchor, multiplier: 1).isActive = true
        view.setupViewConstraints(format: "V:[v0]-10-[v1(\(textLabelHeights))]", views: lastPriceLabel, marketSizeLabel)
        
        //        view.setupViewConstraints(format: "H:[v0(\(bookWidth / 2))]-10-|", views: marketSizeLabel)
        view.setupViewConstraints(format: "H:[v0(\(bookWidth / 2 - 10))]-10-|", views: marketSizeLabel)
        view.setupViewConstraints(format: "H:[v0(\(bookWidth / 2))][v1]", views: priceLabel, marketSizeLabel)
        
        //Configuring the text fields
        for sideSubView in [quoteCurrencyPrice, baseCurrencyAmount, totalAmountLabelsView, marketOrderButton, availableBaseLabel, viewChartsButton, availableAmountLabel] {
            view.setupViewConstraints(format: "H:|-\(textFieldSides)-[v0(\(textFieldWidth + 5))]", views: sideSubView)
        }
        
        view.setupViewConstraints(format: "V:[v1]-\(textFieldSpacing)-[v4(15)]-\(textFieldSpacing)-[v5(15)]-\(textFieldSpacing)-[v0]-\(textFieldSpacing)-[v2(\(textFieldHeight))]-5-[v3(30)]", views: quoteCurrencyPrice, buySellControl, baseCurrencyAmount, totalAmountLabelsView, availableBaseLabel, availableAmountLabel)
        
        //Configuring the market order and limit order buttons
        view.setupViewConstraints(format: "V:[v0]-\(textFieldSpacing)-[v1(\(buttonHeight))]-15-[v2]", views: totalAmountLabelsView, marketOrderButton, viewChartsButton)
        
        
        view.setupViewConstraints(format: "H:|[v0(" + "\(screenWidth / 2)" + ")][v1]|", views: tradeOrderUnderlineText, openOrderUnderlineText)
        view.setupViewConstraints(format: "H:|[v0(" + "\(screenWidth / 2)" + ")][v1]|", views: tradeOrderUnderline, openOrderUnderline)
        view.setupViewConstraints(format: "V:|[v0(40)][v1(2)]", views: tradeOrderUnderlineText, tradeOrderUnderline)
        view.setupViewConstraints(format: "V:|[v0(40)][v1(2)]", views: openOrderUnderlineText, openOrderUnderline)
        
        
        //Order spread, the label in between the two sides of the order book
        view.setupViewConstraints(format: "H:[v0(\(bookWidth))]|", views: orderSpreadLabel)
        view.setupViewConstraints(format: "V:[v0]-1-[v1]-1-[v2]", views: sellBook, orderSpreadLabel, buyBook)
        
        //Order Tracker
        view.setupViewConstraints(format: "H:|-5-[v1]-5-[v0]", views: sellBook, orderTracker)
        view.setupViewConstraints(format: "V:[v0]-\(textFieldSpacing)-[v1]|", views: marketOrderButton, orderTracker)
        
        openOrderBook.isHidden = true
        openOrderBook.backgroundColor = .clear
        view.setupViewConstraints(format: "H:|[v0]|", views: openOrderBook)
        view.setupViewConstraints(format: "V:[v0][v1]|", views: openOrderUnderline, openOrderBook)
        
        //Buy and Sell segmented control
        view.setupViewConstraints(format: "H:|-15-[v0]-15-|", views: buySellControl)
        view.setupViewConstraints(format: "V:[v0]-7-[v1(29)]", views: tradeOrderUnderlineText, buySellControl)
        
        quoteCurrencyPrice.heightAnchor.constraint(equalToConstant: CGFloat(textFieldHeight)).isActive = true
        
    }
    
    func setupViewColorAndStyle() {
        view.backgroundColor = mainPageOptions.backgroundColor
    }
    
    private func setupBaseValues() {
        guard let pair = activePair else {
            return
        }
        let lastDealPrice = "\(pair.lastDealPrice)"
        if pair.coinTypePair == "BTC" {
            lastPriceLabel.text = lastDealPrice.numberToStringFormat(8)
        } else {
            lastPriceLabel.text = lastDealPrice.numberToStringFormat(7)
        }
        
        baseDecimals = TickerInformation.sharedInstance.coinPrecisions[pair.coinType] ?? 4
        quoteDecimals = TickerInformation.sharedInstance.coinPrecisions[pair.coinTypePair] ?? 8
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.sellBook.orderBookCollectionView.isUserInteractionEnabled = false
        self.buyBook.orderBookCollectionView.isUserInteractionEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.sellBook.orderBookCollectionView.isUserInteractionEnabled = true
        self.buyBook.orderBookCollectionView.isUserInteractionEnabled = true
    }
    
    private func addGesturesAndTargets() {
        buySellControl.addTarget(self, action: #selector(orderTypeChanged), for: .valueChanged)
        marketOrderButton.addTarget(self, action: #selector(buyOrSellPressed), for: .touchUpInside)
        viewChartsButton.addTarget(self, action: #selector(viewChartsPressed), for: .touchUpInside)
        
        tradeOrderUnderlineText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tradeOpenOrderChange)))
        openOrderUnderlineText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tradeOpenOrderChange)))
        
        for textField in textFieldArray {
            textField.delegate = self
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
        
    }
    
}
