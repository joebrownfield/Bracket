//
//  UIView+Additions.swift
//  Bracket
//
//  Created by Joseph Brownfield on 7/31/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit


extension UIView {
    func setupViewConstraints(format: String, views: UIView...) {
        var viewsDictionary = [String : UIView]()
        for (index, view) in views.enumerated() {
            let viewKey = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[viewKey] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: nil, views: viewsDictionary))
    }
    
    func addDropShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
    }
    
    func addActivityIndicator(_ title: String) {
        
        let strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        strLabel.text = title
        strLabel.font = .systemFont(ofSize: 14, weight: .medium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        strLabel.tag = 5
        
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        let screenHeight = UIScreen.main.bounds.height
        effectView.frame = CGRect(x: self.frame.midX - strLabel.frame.width/2, y: screenHeight / 2 - 160, width: 160, height: 46)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        effectView.tag = 5
        
        var activityIndicator = UIActivityIndicatorView()
        activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.tag = 5
        activityIndicator.startAnimating()
        
        effectView.contentView.addSubview(activityIndicator)
        effectView.contentView.addSubview(strLabel)
        self.addSubview(effectView)
        
        self.isUserInteractionEnabled = false
        
    }
    
    func removeActivityIndicator() {
        DispatchQueue.main.async {
            for view in self.subviews {
                if view.tag == 5 {
                    UIView.animate(withDuration: 0.5) {
                        view.removeFromSuperview()
                        self.layoutIfNeeded()
                    }
                }
            }
        }
        
        self.isUserInteractionEnabled = true
        
    }
    
}

