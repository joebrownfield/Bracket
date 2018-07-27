//
//  WalletInfoTableController.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/26/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit
import CoreData

class WalletInfoTableController: UITableViewController, WalletTableCellDelegate {
    
    let plusIcon: UIButton = {
        let image = UIButton()
        image.setBackgroundImage(UIImage(named: "YellowPlus")?.withRenderingMode(.alwaysTemplate), for: [])
        image.tintColor = MainPageOptions().tabBarColor
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    let plusView = GenericView(color: MainPageOptions().backgroundColor, alpha: 1)
    
    let cellId = "mainCellId"
    let headerCellId = "walletHeaderCellId"
    let walletCellId = "walletCellId"
    let mainPageOptions = MainPageOptions()
    var exchangeOptions: [APIKeyValues] = TickerInformation.sharedInstance.exchangeOptions
    var wallets: [Wallets] = [Wallets]()
    var additionalWallets: Int = 1
    
    let headerSectionHeight: Int = 140
    let plusHeight: Int = 50
    
    var plusIconAnchorConstraint: NSLayoutConstraint?
    var anchorValue: Int = 10
    var navBarHeight: CGFloat = 88

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = mainPageOptions.backgroundColor
        
        tableView.register(WalletTableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.register(AddWalletCell.self, forCellReuseIdentifier: walletCellId)
        tableView.register(WalletHeaderCell.self, forCellReuseIdentifier: headerCellId)
        
        tableView.allowsSelection = false
        
        if exchangeOptions.count < 1 {
            getKeyBaselines(exchangeOptions: &exchangeOptions)
        }
        
        getWallets(wallets: &wallets, exchangeOptions: &exchangeOptions)
        tableView.reloadData()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if plusIconAnchorConstraint?.isActive == nil {
            addPlusIcon()
        }
    }
    
//    func getWallets() {
//
//        getStoredWallets(&wallets)
//        tableView.reloadData()
//
//        localGetExchgKeys(&exchangeOptions)
//        tableView.reloadData()
//    }
    
    func localUpdateApiArray(apiKey: APIKeyValues) {
        updateApiArray(apiKey: apiKey, exchangeOptions: &exchangeOptions)
        alert(message: "Successfully added keys", title: "Success")
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print(CGFloat(anchorValue) - scrollView.contentOffset.y)
        if (CGFloat(anchorValue) - scrollView.contentOffset.y) <= navBarHeight {
            plusIconAnchorConstraint?.constant = navBarHeight
        } else {
            plusIconAnchorConstraint?.constant = CGFloat(anchorValue) - scrollView.contentOffset.y
        }
    }
    
    private func addGestureRecognizers() {
        plusIcon.addTarget(self, action: #selector(plusIconPressed), for: .touchUpInside)
    }
    
    @objc func plusIconPressed(_ sender: UIButton) {
        print(sender)
        additionalWallets += 1
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 1
        case 1:
            return wallets.count + additionalWallets
        default:
            return exchangeOptions.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: headerCellId, for: indexPath) as! WalletHeaderCell
            
            cell.headerSection.text = "Your wallet keys are all stored locally on your phone. Nothing is stored anywhere else so your keys are safe. Nothing will leave your phone. Please enter the API Key and Secret Key for any exchanges you would like to use, or enter in a wallet number to bring in all of the wallet information."
            cell.backgroundColor = mainPageOptions.backgroundColor
            cell.headerSection.backgroundColor = mainPageOptions.backgroundColor
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: walletCellId, for: indexPath) as! AddWalletCell
            if !wallets.isEmpty, wallets.count > indexPath.row, let address = wallets[indexPath.row] as Wallets? {
                cell.apiKeyTextField.text = address.address
            }
            cell.delegate = self
            cell.backgroundColor = mainPageOptions.backgroundColor
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! WalletTableViewCell
            
            cell.apiKeyValue = exchangeOptions[indexPath.row]
            cell.delegate = self
            cell.backgroundColor = mainPageOptions.backgroundColor
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return CGFloat(headerSectionHeight)
        case 1:
            return 80
        default:
            return 120
        }
    }
    
    func reloadPortfolio() {
        updateAllBalances(activeVC: self) {
            
        }
    }
    
    func displayAlert(title: String, message: String) {
        alert(message: message, title: title)
    }
    
    func addPlusIcon() {
        self.view.superview?.addSubview(plusView)
        self.view.superview?.addSubview(plusIcon)
        navBarHeight = (navigationController?.navigationBar.frame.maxY)!
        anchorValue = headerSectionHeight - (plusHeight / 2) + Int(navBarHeight)
        plusIconAnchorConstraint = plusIcon.topAnchor.constraint(equalTo: (self.view.superview?.topAnchor)!)
        plusIconAnchorConstraint?.isActive = true
        plusIconAnchorConstraint?.constant = CGFloat(anchorValue)
        self.view.superview?.setupViewConstraints(format: "H:[v0(" + "\(plusHeight)" + ")]-10-|", views: plusIcon)
        self.view.superview?.setupViewConstraints(format: "V:[v0(" + "\(plusHeight)" + ")]", views: plusIcon)
        
        let plusSpace = plusHeight / 10
        let bkgSize = plusSpace * 6
        let bkgSpacing = plusHeight - ((plusHeight - bkgSize) / 2)
        self.view.superview?.setupViewConstraints(format: "H:[v0]-(-" + "\(bkgSpacing)" + ")-[v1(" + "\(bkgSize)" + ")]", views: plusIcon, plusView)
        self.view.superview?.setupViewConstraints(format: "V:[v0]-(-" + "\(bkgSpacing)" + ")-[v1(" + "\(bkgSize)" + ")]", views: plusIcon, plusView)
        
        addGestureRecognizers()
    }

}
