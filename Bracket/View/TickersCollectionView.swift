//
//  TickersCell.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/10/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit

class TickersCollectionView: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = MainPageOptions().backgroundColor
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    var pairingData: [PairInfo] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    let cellId = "tickersCell"
    var mainPageController: MainPageController?
    
    let mainPageOptions = MainPageOptions()
    
    let pairingHeight: Int = MainPageOptions().pairingHeight
    
    let numberformatter = NumberFormatter()
    let priceformatter = NumberFormatter()
    
    override func addViews() {
        
        addSubview(collectionView)
        
        //backgroundColor = .green
        
        setupViewConstraints(format: "H:|[v0]|", views: collectionView)
        setupViewConstraints(format: "V:|[v0]|", views: collectionView)
        
        collectionView.register(TickersCell.self, forCellWithReuseIdentifier: cellId)
        
        numberformatter.numberStyle = .decimal
        numberformatter.alwaysShowsDecimalSeparator = true
        numberformatter.minimumFractionDigits = 2
        numberformatter.maximumFractionDigits = 2
        
        priceformatter.numberStyle = .decimal
        priceformatter.alwaysShowsDecimalSeparator = true
        priceformatter.minimumFractionDigits = 8
        priceformatter.maximumFractionDigits = 8
        
        fetchPairingData()
        
    }
    
    override func awakeFromNib() {
        collectionView.reloadData()
    }
    
    func fetchPairingData() {
        
//        let fullPairingList = TickerInformation.sharedInstance.tradingPairs
//        let activeIndex = TickerInformation.sharedInstance.activeIndex
//        let pairings = TickerInformation.sharedInstance.pairings
//        print(fullPairingList)
//        print(activeIndex)
//        print(pairings)
//        pairingData = fullPairingList.filter { $0.coinTypePair == pairings[activeIndex] }
//        print(pairingData[0])
//        self.collectionView.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pairingData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TickersCell
        let pairingItem = pairingData[indexPath.item]
        cell.symbol.text = pairingItem.symbol
        cell.volume.text = "Vol: " + numberformatter.string(for: pairingItem.vol)!
        let lastDealPrice = priceformatter.string(for: pairingItem.lastDealPrice)!
        cell.price.text = lastDealPrice
        let basePrices = (TickerInformation.sharedInstance.currencyPrices.filter { $0.base == pairingItem.coinTypePair })
        if basePrices.count > 0, let basePrice = basePrices[0] as CoinbasePairInfo? {
            let dollarAmount = "\(Double(lastDealPrice)! * Double(basePrice.amount)!)"
            let dollarAmountFormat = dollarAmount.numberToStringFormat(2)
            cell.dollarAmount.text = "~ " + dollarAmountFormat + " USD"
        } else {
            cell.dollarAmount.text = ""
        }
        let changeRate = pairingItem.changeRate
        cell.change.text = changeRate
        if Double(changeRate.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "%", with: ""))! >= 0 {
            cell.change.backgroundColor = mainPageOptions.darkGreen
        } else {
            cell.change.backgroundColor = mainPageOptions.darkRed
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = CGSize(width: frame.width, height: mainPageOptions.cvHeight)
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pairingItem = pairingData[indexPath.item]
        mainPageController?.showControllerForPairing(pairingItem)
    }
    
}
