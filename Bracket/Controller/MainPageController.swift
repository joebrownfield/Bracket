//
//  MainPageController.swift
//  Bracket
//
//  Created by Joseph Brownfield on 5/31/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit
import SafariServices

class MainPageController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "mainCellId"
    let tickersCellId = "tickersCellId"
    let mainPageOptions = MainPageOptions()
    let bkgColor = MainPageOptions().backgroundColor
    let pairingHeight: Int = MainPageOptions().pairingHeight
    var pairingShowing: NSLayoutConstraint?
    var pairingHidden: NSLayoutConstraint?
    var standardSize: CGFloat?
    var keyboardItemSize: CGFloat?
    
    var filteredPairs: [PairInfo] = [PairInfo]()
    var activePairs: [PairInfo] = [PairInfo]()
    var activeExchg: Exchanges = .none
    
    var keyboardEnabled: Bool = false
    
    let kuCoin = KuCoin(apiKey: AllKeys.kuCoinShared.apiKey, secret: AllKeys.kuCoinShared.secret)
    let idex = IDEX()
    let bittrex = Bittrex()
    
    lazy var pairingBar: PairingBar = {
        let pb = PairingBar()
        pb.mainPageController = self
        return pb
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    let backButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        button.setImage(UIImage(named: "backButton")?.withRenderingMode(.alwaysTemplate), for: [])
        button.setTitle("", for: [])
        button.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3)
        button.imageView?.contentMode = .scaleAspectFit
        let titleColor = MainPageOptions().navigationTitleColor
        button.tintColor = titleColor
        return button
    }()
    
    let backgroundView = UIView()
    //var titleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        addBackgroundBar()
        setupPairingBar()
        setupCollectionView()
        addBackgroundView()
        
        preloadAllData(activeVC: self)
        
        configureSearchBar()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        resetKeys()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
        
        resetKeys()
        
//        let cmcCalls = CMCCalls()
//        cmcCalls.getBaselinePrices { (results, error) in
//            guard let results = results else { return }
//            for result in results {
//                eb.cmcValues.append(result)
//            }
//        }
        
        
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Home"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        self.backButton.alpha = 0
        backButton.isHidden = true
        
        setupSearchIcon()
    }
    
    private func addBackgroundBar() {
        let bkgViewBar = UIView()
        bkgViewBar.backgroundColor = mainPageOptions.tabBarTintColor
        bkgViewBar.frame = CGRect(x: 0, y: -55, width: view.frame.width, height: 55)
        view.addSubview(bkgViewBar)
    }
    
    private func setupPairingBar() {
        view.addSubview(pairingBar)
        
        pairingShowing = pairingBar.heightAnchor.constraint(equalToConstant: CGFloat(pairingHeight))
        pairingShowing?.isActive = false
        pairingHidden = pairingBar.heightAnchor.constraint(equalToConstant: 0)
        pairingHidden?.isActive = true
        
        view.setupViewConstraints(format: "H:|[v0]|", views: pairingBar)
        view.setupViewConstraints(format: "V:[v0]", views: pairingBar)
        
        pairingBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    }
    
    func setupCollectionView() {
        
        collectionView?.backgroundColor = .clear
        view.backgroundColor = bkgColor
        collectionView?.register(TickersCollectionView.self, forCellWithReuseIdentifier: tickersCellId)
        collectionView?.register(MainCell.self, forCellWithReuseIdentifier: cellId)
        
    }
    
    func addBackgroundView() {
        backgroundView.backgroundColor = bkgColor
        backgroundView.addDropShadow()
        view.addSubview(backgroundView)
        view.sendSubview(toBack: backgroundView)
        view.setupViewConstraints(format: "V:|[v0]-" + mainPageOptions.cvSpacing + "-|", views: backgroundView)
        view.setupViewConstraints(format: "H:|-" + mainPageOptions.cvSpacing + "-[v0]-" + mainPageOptions.cvSpacing + "-|", views: backgroundView)
    }
    
    func setActivePairs(index: Int) {
        let pairArray = TickerInformation.sharedInstance.pairings
        activePairs = TickerInformation.sharedInstance.tradingPairs.filter { $0.coinTypePair == pairArray[index] }
        if isFiltering() {
            filterContentForSearchText(searchController.searchBar.text ?? "")
        }
    }
    
    func scrollToMenuIndex(menuIndex: Int) {
        let indexPath = IndexPath(item: menuIndex, section: 0)
        collectionView?.scrollToItem(at: indexPath, at: [], animated: true)
        setActivePairs(index: menuIndex)
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print(targetContentOffset.move().x / view.frame.width)
        let scrollIndex = targetContentOffset.move().x / view.frame.width
        let indexPath = IndexPath(item: Int(scrollIndex), section: 0)
        pairingBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        setActivePairs(index: indexPath.item)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (self.pairingHidden?.isActive)! {
            return mainPageOptions.options.count
        } else {
            return TickerInformation.sharedInstance.pairings.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (self.pairingHidden?.isActive)! {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MainCell
            cell.exchgLabel.text = mainPageOptions.options[indexPath.row].rawValue
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tickersCellId, for: indexPath) as! TickersCollectionView
            cell.awakeFromNib()
            cell.mainPageController = self
            if isFiltering() {
                cell.pairingData = filteredPairs
            } else {
                let pairArray = TickerInformation.sharedInstance.pairings
                var pairingsFiltered = TickerInformation.sharedInstance.tradingPairs.filter { $0.coinTypePair == pairArray[indexPath.item] }
                pairingsFiltered.sort { $0.vol > $1.vol }
                cell.pairingData = pairingsFiltered
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if searchController.isActive, keyboardEnabled {
            let adjustedInset = collectionView.adjustedContentInset
            print("Adjusted Insets")
            print(adjustedInset)
            //return adjustedInset
            return UIEdgeInsetsMake(CGFloat(pairingHeight), 0, 0, 0)
        } else if searchController.isActive {
            print("searchController.isActive")
            return UIEdgeInsetsMake(CGFloat(pairingHeight), 0, 0, 0)
        } else if (self.pairingHidden?.isActive)! {
            return UIEdgeInsetsMake(0, 0, 0, 0)
        } else {
            print("Default")
            return UIEdgeInsetsMake(CGFloat(pairingHeight), 0, 0, 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if standardSize == nil {
            standardSize = view.frame.height
        }
        //collectionView.backgroundColor = .blue
        if searchController.isActive, keyboardEnabled {
            let adjustedInset = collectionView.adjustedContentInset
            let itemSize: CGSize
            if keyboardItemSize == nil {
                keyboardItemSize = standardSize! - adjustedInset.bottom - adjustedInset.top + 14
            }
            itemSize = CGSize(width: view.frame.width, height: keyboardItemSize!)
            return itemSize
        } else if searchController.isActive {
            let itemSize = CGSize(width: view.frame.width, height: standardSize! - 59)
            return itemSize
        } else if (self.pairingHidden?.isActive)! {
            let itemSize = CGSize(width: view.frame.width, height: mainPageOptions.cvHeight)
            return itemSize
        } else {
            let itemSize = CGSize(width: view.frame.width, height: standardSize! - CGFloat(pairingHeight))
            print("Default Size")
            return itemSize
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (self.pairingHidden?.isActive)! {
            
            activeExchg = mainPageOptions.options[indexPath.row]
            
            view.addActivityIndicator("Loading Data")
            
            switch activeExchg {
            case .combination:
                showWebForPair(PairInfo(changeRate: "", coinType: "", coinTypePair: "", lastDealPrice: 1, trading: true, vol: 1, symbol: ""))
            case .idex:
                loadIdexData()
                updatePrecisionArray(exchg: activeExchg)
            case .bittrex:
                loadBittrexData()
                updatePrecisionArray(exchg: activeExchg)
            case .kucoin:
                loadKuCoinData()
                updatePrecisionArray(exchg: activeExchg)
            default:
                break
            }
        } else {
            
        }
        
    }
    
    func showControllerForPairing(_ pair: PairInfo) {
        let tradingViewController = TradingController(getExchng: activeExchg, pair: pair)
        tradingViewController.navigationItem.title = pair.symbol
        navigationController?.pushViewController(tradingViewController, animated: true)
    }
    
    func showWebForPair(_ pair: PairInfo) {
        var UrlString: String!
        switch activeExchg {
        case .combination:
            UrlString = "https://coinmarketcap.com/"
            view.removeActivityIndicator()
        case .idex:
            UrlString = "https://idex.market/eth/" + pair.coinType.lowercased()
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
    
    @objc func backButtonPressed() {
        hidePairingBar()
    }
    
    func setPairingsForCollection(pairs: [PairInfo]) {
        //print(pairs)
        TickerInformation.sharedInstance.tradingPairs = pairs
        let _ = self.pairingBar.collectionView.indexPathsForSelectedItems
//        self.view.removeActivityIndicator()
//        self.collectionView?.reloadData()
    }
    
    func resetKeys() {
        kuCoin.apiKey = AllKeys.kuCoinShared.apiKey
        kuCoin.secret = AllKeys.kuCoinShared.secret
        idex.apiKey = AllKeys.idexShared.apiKey
        idex.secret = AllKeys.idexShared.secret
        bittrex.apiKey = AllKeys.bittrexShared.apiKey
        bittrex.secret = AllKeys.bittrexShared.secret
    }
    
    func loadIdexData() {
        // Getting trading pairs
        TickerInformation.sharedInstance.pairings = self.idex.getTradingMarkets()
        
        // Getting the data for all the pairs
        idex.getAllPairings { (results, error) in
            DispatchQueue.main.async {
                var organizedResults: [PairInfo] = [PairInfo]()
                guard let results = results else {
                    self.view.removeActivityIndicator()
                    return
                }
                for (key, value) in results {
                    if value.vol != 0.0, value.vol > 1 {
                        let coins = key.components(separatedBy: "_")
                        let pairInfo = PairInfo(changeRate: value.changeRate, coinType: coins[1], coinTypePair: coins[0], lastDealPrice: value.lastDealPrice, trading: true, vol: value.vol, symbol: coins[1] + "-" + coins[0])
                        organizedResults.append(pairInfo)
                    }
                }
                self.setPairingsForCollection(pairs: organizedResults)
                self.showPairingBar()
            }
        }
    }
    
    func loadBittrexData() {
        bittrex.getAllPairings { (results, error) in
            DispatchQueue.main.async {
                guard let resultsArray = results?.result else {
                    self.view.removeActivityIndicator()
                    return
                }
                var organizedResults: [PairInfo] = [PairInfo]()
                var pairings = [String]()
                for result in resultsArray {
                    if result.vol != 0.0, result.vol > 1 {
                        let pairInfo = PairInfo(changeRate: result.changeRate, coinType: result.coinType, coinTypePair: result.coinTypePair, lastDealPrice: result.lastDealPrice, trading: result.trading, vol: result.vol, symbol: result.symbol)
                        organizedResults.append(pairInfo)
                        pairings.append(pairInfo.coinTypePair)
                    }
                }
                if pairings.count >= 1 {
                    pairings = Array(Set(pairings)).sorted()
                    TickerInformation.sharedInstance.pairings = pairings
                } else {
                    TickerInformation.sharedInstance.pairings = ["ETH"]
                }
                
                self.setPairingsForCollection(pairs: organizedResults)
                self.showPairingBar()
            }
        }
    }
    
    func loadKuCoinData() {
        // Getting trading pairs
        self.kuCoin.getTradingMarkets { (results, error) in
            DispatchQueue.main.async {
                guard let results = results else {
                    self.view.removeActivityIndicator()
                    return
                }
                TickerInformation.sharedInstance.pairings = results.data
                
                // Getting the data for all the pairs
                self.kuCoin.getAllPairings { (results, error) in
                    DispatchQueue.main.async {
                        guard let results = results else {
                            self.view.removeActivityIndicator()
                            return
                        }
                        self.setPairingsForCollection(pairs: results.data)
                        self.showPairingBar()
                    }
                }
            }
        }
    }
    
    private func showPairingBar() {
        
        fadeOutCollectionViewCell { (Bool) in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.pairingShowing?.isActive = true
                    self.backButton.alpha = 1
                    self.collectionView?.alpha = 1
                    self.showSearchIcon()
                    self.view.layoutIfNeeded()
                }, completion: { (Bool) in
                    self.setActivePairs(index: 0)
                    self.collectionView?.collectionViewLayout.invalidateLayout()
                    self.collectionView?.reloadData()
                    self.view.removeActivityIndicator()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        //self.searchController.isActive = true
                    })
                })
            }
        }
    }
    
    func fadeOutCollectionViewCell(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.backgroundView.alpha = 0
                self.collectionView?.alpha = 0
            }) { (Bool) in
                if let flowLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                    flowLayout.scrollDirection = .horizontal
                    flowLayout.minimumLineSpacing = 0
                }
                if TickerInformation.sharedInstance.tradingPairs.count > 1 {
                    self.collectionView?.isPagingEnabled = true
                }
                self.pairingBar.reloadCollectionView()
                self.backButton.isHidden = false
                self.pairingHidden?.isActive = false
                
//                self.collectionView?.contentInset = UIEdgeInsetsMake(CGFloat(self.pairingHeight), 0, 0, 0)
//                self.collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(CGFloat(self.pairingHeight), 0, 0, 0)
                self.collectionView?.reloadData()
                completion(true)
            }
        }
    }
    
    private func hidePairingBar() {
        DispatchQueue.main.async {
            if let flowLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.scrollDirection = .vertical
                //flowLayout.minimumLineSpacing = 0
            }
            self.collectionView?.isPagingEnabled = false
            self.pairingShowing?.isActive = false
            self.pairingHidden?.isActive = true
            self.collectionView?.reloadData()
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//                self.collectionView?.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
//                self.collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
                self.hideSearchIcon()
                self.backButton.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: { (Bool) in
                self.backButton.isHidden = true
            })
        }
    }
    
    
}

