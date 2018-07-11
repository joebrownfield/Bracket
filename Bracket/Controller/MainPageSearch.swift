//
//  MainPageSearch.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/13/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit

extension MainPageController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if(keyboardEnabled == false){
            keyboardEnabled = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        keyboardEnabled = false
    }
    
    func configureSearchBar() {
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Symbols"
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.keyboardType = .alphabet
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        searchController.delegate = self
        searchController.searchBar.tintColor = mainPageOptions.navigationTitleColor
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
    }
    
    func setupSearchIcon() {
        let searchIcon = UIImage(named: "searchicon")?.withRenderingMode(.alwaysTemplate)
        let searchBarButtonItem = UIBarButtonItem(image: searchIcon, style: .plain, target: self, action: #selector(showSearch))
        
        navigationItem.rightBarButtonItem = searchBarButtonItem
        
        hideSearchIcon()
    }
    
    func showSearchIcon() {
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationItem.rightBarButtonItem?.tintColor = mainPageOptions.navigationTitleColor
    }
    
    func hideSearchIcon() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.tintColor = .clear
    }
    
    @objc func showSearch() {
        
        if navigationItem.searchController != searchController {
            navigationItem.searchController = searchController
        }
        //searchController.animateTransition(using: UIViewControllerContextTransitioning())
        searchController.isActive = true
        collectionView?.reloadData()
        //view.layoutIfNeeded()
        navigationController?.view.layoutSubviews()
        
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredPairs = activePairs.filter({( pair : PairInfo) -> Bool in
            if searchBarIsEmpty() {
                return true
            } else {
                return pair.symbol.lowercased().contains(searchText.lowercased())
            }
        })
        collectionView?.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
}

extension MainPageController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension MainPageController: UISearchBarDelegate, UISearchControllerDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.resignFirstResponder()
        DispatchQueue.main.async {
            self.searchController.isActive = false
            self.navigationItem.searchController = nil
            self.collectionView?.reloadData()
            self.collectionView?.autoresizesSubviews = true
        }
        
        searchController.dismiss(animated: true) {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                self.view.layoutIfNeeded()
            }
        }
        
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
}
