//
//  PairingBar.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/5/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit

class PairingBar: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPrefetchingEnabled = false
        cv.backgroundColor = MainPageOptions().tabBarTintColor
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let cellId = "pairingCell"
    var mainPageController: MainPageController?
    
    //var pairings: [String] = TickerInformation.sharedInstance.pairings
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.register(PairingCell.self, forCellWithReuseIdentifier: cellId)
        
        addSubview(collectionView)
        
        setupViewConstraints(format: "H:|[v0]|", views: collectionView)
        setupViewConstraints(format: "V:|[v0]|", views: collectionView)
        
    }
    
    func reloadCollectionView() {
        collectionView.reloadData()
        let startingIndex = NSIndexPath(item: 0, section: 0)
        collectionView.selectItem(at: startingIndex as IndexPath, animated: false, scrollPosition: [])
    }
    
    override func layoutSubviews() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TickerInformation.sharedInstance.pairings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PairingCell
        
        cell.pairingLabel.text = TickerInformation.sharedInstance.pairings[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = CGSize(width: frame.width / 4, height: frame.height)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        TickerInformation.sharedInstance.activeIndex = indexPath.item
        mainPageController?.scrollToMenuIndex(menuIndex: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
