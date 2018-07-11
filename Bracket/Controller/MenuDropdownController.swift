//
//  MenuDropdownController.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/25/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit

class DropdownController {
    var activeCoinPairs = [String]()
    var asks = [Order]()
    var bids = [Order]()
}

class HandleDropdowns: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let dropdownCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.tag = 5
        collectionView.addDropShadow()
        collectionView.layer.cornerRadius = 5
        collectionView.alpha = 0.9
        return collectionView
    }()
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        view.tag = 5
        view.frame = UIScreen.main.bounds
        return view
    }()
    
    var portfolioController: PortfolioController?
    var dropdownController: [DropdownOptions] = [.history, .history, .open, .nightMode]
    
    let reuseIdentifier = "dropdownCell"
    let cellHeight: CGFloat = {
        if UIScreen.main.bounds.width < 400 {
            return 40
        } else {
            return 50
        }
    }()
    var dropdownActive: Bool = false
    
    func showDropdown() {
        
        // Creating a drop down and also dimming the screen while the user selects the currency pair they want to trade with
        guard dropdownActive == false else {
            dropdownActive = false
            dismissDropdown()
            return
        }
        if let orderBookView = portfolioController?.view {
            orderBookView.addSubview(backgroundView)
            backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissDropdown)))
            orderBookView.addSubview(dropdownCV)
            let height = Int(cellHeight * CGFloat(dropdownController.count))
            let width = 150
            let startingValue = Int(UIScreen.main.bounds.width - CGFloat(width))
            dropdownCV.frame = CGRect(x: startingValue, y: 0 - height - Int(cellHeight), width: width, height: height)
            dropdownActive = true
            UIView.animate(withDuration: 0.5) {
                self.dropdownCV.frame = CGRect(x: startingValue, y: 0 - Int(self.cellHeight), width: width, height: height)
                self.backgroundView.alpha = 0.5
            }
        }
    }
    
    @objc func dismissDropdown() {
        handleDropdownDismiss {
            
        }
    }
    
    func handleDropdownDismiss(completion: @escaping () -> Void) {
        dropdownActive = false
        let height = Int(cellHeight * CGFloat(dropdownController.count))
        let width = 150
        let startingValue = Int(UIScreen.main.bounds.width - CGFloat(width))
        UIView.animate(withDuration: 0.5, animations: {
            self.dropdownCV.frame = CGRect(x: startingValue, y: 0 - height - Int(self.cellHeight), width: width, height: height)
            self.backgroundView.alpha = 0
        }) { (completed) in
            if let orderBookView = self.portfolioController?.view {
                for subView in orderBookView.subviews {
                    if subView.tag == 5 {
                        subView.removeFromSuperview()
                    }
                }
            }
            completion()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dropdownController.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MenuDropdownCell
        let pairingText = dropdownController[indexPath.item]
        cell.pairingLabel.text = pairingText.rawValue
        if indexPath.item == dropdownController.count - 1 {
            cell.separatorBottom.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = dropdownController[indexPath.item]
        handleDropdownDismiss {
            DispatchQueue.main.async {
                switch selectedItem {
                case .history:
                    let walletViewController = OrdersViewController(bookType: selectedItem.rawValue)
                    walletViewController.navigationItem.title = "Order History"
                    self.portfolioController?.navigationController?.pushViewController(walletViewController, animated: true)
                case .open:
                    let walletViewController = OrdersViewController(bookType: selectedItem.rawValue)
                    walletViewController.navigationItem.title = "Open Orders"
                    self.portfolioController?.navigationController?.pushViewController(walletViewController, animated: true)
                case .nightMode:
                    self.portfolioController?.alert(message: "Can only toggle by changing the code.", title: "Coming Soon")
                }
            }
        }
    }
    
    override init() {
        super.init()
        
        dropdownCV.dataSource = self
        dropdownCV.delegate = self
        
        dropdownCV.register(MenuDropdownCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
    }
    
}
