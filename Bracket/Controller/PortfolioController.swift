//
//  PortfolioController.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/14/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit
import CoreData

class PortfolioController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    lazy var handleDropdowns: HandleDropdowns = {
        let handlingDropdowns = HandleDropdowns()
        handlingDropdowns.portfolioController = self
        return handlingDropdowns
    }()
    
    let menuButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        button.setImage(UIImage(named: "Menu")?.withRenderingMode(.alwaysTemplate), for: [])
        button.setTitle("", for: [])
        button.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3)
        button.imageView?.contentMode = .scaleAspectFit
        let titleColor = MainPageOptions().navigationTitleColor
        button.tintColor = titleColor
        return button
    }()
    
    let coinBalance = GenericLabel("", .center, fontBold(25), MainPageOptions().labelColor)
    
    let coinValue = GenericLabel("", .center, fontRegular(17), MainPageOptions().labelColor)
    
    let plusIcon: UIButton = {
        let image = UIButton()
        image.setBackgroundImage(UIImage(named: "YellowPlus")?.withRenderingMode(.alwaysTemplate), for: [])
        image.tintColor = MainPageOptions().tabBarColor
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    let headerBackground = GenericView(color: MainPageOptions().backgroundColor, alpha: 1)
    
    let separatorBottom = GenericView(color: MainPageOptions().labelColor, alpha: 0.5)
    
    var exchangeOptions: [APIKeyValues] = TickerInformation.sharedInstance.exchangeOptions
    var wallets: [Wallets] = TickerInformation.sharedInstance.wallets
    
    let headerHeight: Int = 150
    let plusIconHeight: Int = 75
    
    let mainPageOptions = MainPageOptions()
    
    //var ethValue: Double = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupNavigationBar()
        setupSubviews()
        addSubviewConstraints()
        addGestureRecognizers()
        addPullToRefresh()
        
        if exchangeOptions.count < 1 {
            getKeyBaselines(exchangeOptions: &exchangeOptions)
        }
        
        getWallets(wallets: &wallets, exchangeOptions: &exchangeOptions)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadViewData()
        localUpdatePercents(ExchangeBalances.sharedInstance.exchangeBalances)
    }
    
    private func addPullToRefresh() {
        let refreshControl = UIRefreshControl()
        let title = NSLocalizedString("Refreshing data..", comment: "Pull to refresh")
        let attributes: [NSAttributedStringKey : UIColor]?
        if (BeastMode().nightMode) {
            refreshControl.tintColor = .white
            attributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        } else {
            refreshControl.tintColor = .black
            attributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        }
        refreshControl.attributedTitle = NSAttributedString(string: title, attributes: attributes)
        refreshControl.bounds.origin.y = CGFloat(headerHeight * -1)
        refreshControl.addTarget(self, action: #selector(refreshCVData(sender:)), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
    }
    
    @objc func refreshCVData(sender: UIRefreshControl) {
        updateAllBalances(activeVC: self) {
            DispatchQueue.main.async {
                getAllOrderHistory()
            }
            DispatchQueue.main.async {
                self.localUpdatePercents(ExchangeBalances.sharedInstance.exchangeBalances)
                self.reloadViewData()
                sender.endRefreshing()
            }
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Portfolio"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: menuButton)
        menuButton.addTarget(self, action: #selector(menuButtonPressed), for: .touchUpInside)
    }
    
    private func setupSubviews() {
        view.addSubview(headerBackground)
        view.addSubview(coinBalance)
        view.addSubview(coinValue)
        view.addSubview(plusIcon)
        view.addSubview(separatorBottom)
    }
    
    private func addSubviewConstraints() {
        view.setupViewConstraints(format: "H:|[v0]|", views: coinBalance)
        view.setupViewConstraints(format: "H:|[v0]|", views: coinValue)
        view.setupViewConstraints(format: "H:|-10-[v0]-10-|", views: separatorBottom)
        view.setupViewConstraints(format: "H:[v0(" + "\(plusIconHeight)" + ")]-10-|", views: plusIcon)
        
        view.setupViewConstraints(format: "V:|-" + "\(headerHeight / 3)" + "-[v0(20)]-10-[v1]", views: coinBalance, coinValue)
        view.setupViewConstraints(format: "V:[v0(" + "\(plusIconHeight)" + ")]-10-|", views: plusIcon)
        
        view.setupViewConstraints(format: "V:|-" + "\(headerHeight - 1)" + "-[v0(1)]", views: separatorBottom)
        
        view.setupViewConstraints(format: "H:|[v0]|", views: headerBackground)
        view.setupViewConstraints(format: "V:|[v0(" + "\(headerHeight - 1)" + ")]", views: headerBackground)
    }
    
    func getExchgBalances() {
        
    }
    
    private func addGestureRecognizers() {
        plusIcon.addTarget(self, action: #selector(plusIconPressed), for: .touchUpInside)
    }
    
    @objc func menuButtonPressed() {
        DispatchQueue.main.async {
            self.handleDropdowns.showDropdown()
        }
    }
    
    @objc func plusIconPressed(_ sender: UIButton) {
        print(sender)
        let walletViewController = WalletInfoTableController()
        walletViewController.navigationItem.title = "Add Keys"
        navigationController?.pushViewController(walletViewController, animated: true)
    }
    
    func setupCollectionView() {
        
        collectionView?.backgroundColor = mainPageOptions.backgroundColor
        //view.backgroundColor = .blue
        
        collectionView?.register(PortfolioCell.self, forCellWithReuseIdentifier: cellId)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ExchangeBalances.sharedInstance.exchangeBalances.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PortfolioCell
        let eb = ExchangeBalances.sharedInstance.exchangeBalances[indexPath.item]
        cell.coin.text = eb.coinType
        cell.coinAmount.text = eb.balanceStr.numberToStringFormat(2)
        
        let basePrices = (TickerInformation.sharedInstance.currencyPrices.filter { $0.base == "ETH" })
        if eb.price != "", basePrices.count > 0, let basePrice = basePrices[0] as CoinbasePairInfo? {
            let dollarAmount = "\(Double(eb.price)! * Double(basePrice.amount)! * eb.balance)"
            let dollarAmountFormat = dollarAmount.numberToStringFormat(2)
            cell.coinValue.text = "~ " + dollarAmountFormat + " USD"
        } else {
            cell.coinValue.text = ""
        }
        
        if eb.coinType == "BTC" {
            cell.price.text = eb.price
            if eb.price != "" {
                cell.coinValue.text = "(BTC-ETH)"
            }
        } else {
            cell.price.text = eb.price
        }
        
        if eb.change == "" {
            cell.change.text = "-"
            cell.change.backgroundColor = setColor(hValue: "#979797")
        } else {
            cell.change.text = eb.change
            if Double(eb.change.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "%", with: ""))! >= 0 {
                cell.change.backgroundColor = mainPageOptions.darkGreen
            } else {
                cell.change.backgroundColor = mainPageOptions.darkRed
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(CGFloat(headerHeight), 0, CGFloat(plusIconHeight), 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = CGFloat((Int(mainPageOptions.cvHeight / 2) - 4) * 2 + 10)
        let itemSize = CGSize(width: view.frame.width, height: height)
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func reloadViewData() {
        self.collectionView?.reloadData()
        self.updateBalanceLabels()
    }
    
    func updateBalanceLabels() {
        var totalEth: Double = 0
        var totalDollars: Double = 0
        if let basePrice = TickerInformation.sharedInstance.currencyPrices.first(where: { $0.base == "ETH" }) {
            for balance in ExchangeBalances.sharedInstance.exchangeBalances {
                if balance.price != "" {
                    let dollarAmount: Double
                    if balance.coinType == "BTC" {
                        dollarAmount = (Double(basePrice.amount)! / Double(balance.price)! * balance.balance)
                    } else {
                        dollarAmount = (Double(balance.price)! * Double(basePrice.amount)! * balance.balance)
                    }
                    totalDollars += dollarAmount
                    
                    let ethAmount = (Double(balance.price)! * balance.balance)
                    totalEth += ethAmount
                }
            }
        }
        let dollarAmountFormat = totalDollars.toString().numberToStringFormat(2)
        coinValue.text = "~ " + dollarAmountFormat + " USD"
        coinBalance.text = totalEth.toString().numberToStringFormat(7) + " ETH"
    }
    
    func localUpdatePercents(_ coinBalances: [ExchangeBalance]) {
        guard coinBalances.count > 0 else {
            return
        }
        for i in 0...coinBalances.count - 1 {
            let coinBalance = coinBalances[i]
            guard !(["ETH"].contains(coinBalance.coinType)) else { continue }
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
                        var updatedValue = ExchangeBalances.sharedInstance.exchangeBalances[i]
                        updatedValue.change = coinInfo.changeRate
                        let lastDealPrice = "\(coinInfo.lastDealPrice)"
                        updatedValue.price = lastDealPrice.numberToStringFormat(7)
                        ExchangeBalances.sharedInstance.exchangeBalances[i] = updatedValue
                        self.reloadViewData()
                    }
                    
                }
            default:
                break
            }
        }
    }
    
}
