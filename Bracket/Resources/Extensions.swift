//
//  Extensions.swift
//  Bracket
//
//  Created by Joseph Brownfield on 5/31/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import Foundation
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
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
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

extension String {
    func numberToStringFormat(_ decimalPlaces: Int) -> String {
        guard let doubleValue = Double(self) as Double? else {
            return ""
        }
        let decimalModified: Int = {
            if doubleValue < 1, decimalPlaces == 2 {
                return 4
            } else {
                return decimalPlaces
            }
        }()
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.alwaysShowsDecimalSeparator = true
        numberFormatter.minimumFractionDigits = decimalModified
        numberFormatter.maximumFractionDigits = decimalModified
        guard let formattedString = numberFormatter.string(for: doubleValue) else {
            return ""
        }
        return formattedString.replacingOccurrences(of: ",", with: "")
    }
    
    func toDouble() -> Double {
        let whiteSpaces = self.replacingOccurrences(of: " ", with: "")
        let stringValue = whiteSpaces.replacingOccurrences(of: ",", with: "")
        let doubleValue = Double(stringValue)!
        return doubleValue
    }
    
    func addOneToValue(_ decimals: Int) -> String {
        let multipliedDouble = self.toDouble() * pow(10, Double(decimals))
        let doubleValue: Double
        if multipliedDouble > 500 {
            doubleValue = (multipliedDouble + 2) / pow(10, Double(decimals))
        } else {
            doubleValue = (multipliedDouble + 1) / pow(10, Double(decimals))
        }
        return doubleValue.toString().numberToStringFormat(decimals)
    }
    
    func subtractOneFrom(_ decimals: Int) -> String {
        let multipliedDouble = self.toDouble() * pow(10, Double(decimals))
        let doubleValue: Double
        if multipliedDouble > 500 {
            doubleValue = (multipliedDouble - 2) / pow(10, Double(decimals))
        } else {
            doubleValue = (multipliedDouble - 1) / pow(10, Double(decimals))
        }
        return doubleValue.toString().numberToStringFormat(decimals)
    }
    
    func dropdownValueFormat() -> NSMutableAttributedString {
        let ticker = self.replacingOccurrences(of: "-", with: "/")
        let attribText = NSMutableAttributedString(string: ticker + "\u{2304}", attributes: [:])
        return attribText
    }
    
    func removeNonNumericCharacters() -> String {
        let regexPattern = "[^0-9.]"
        let decimalString = "."
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: .caseInsensitive)
            let numericOnlyString = regex.stringByReplacingMatches(in: self, options: .withTransparentBounds, range: NSMakeRange(0, self.count), withTemplate: "")
            if self.contains(decimalString), let range = self.range(of: decimalString) {
                //There is probably a better way to do this but for the sake of time I am just doing it this way
                //to make sure you can't have multiple decimal places in the price
                let changeFirstDecimal = numericOnlyString.replacingOccurrences(of: decimalString, with: "D", options: .literal, range: range)
                let removeOtherDecimals = changeFirstDecimal.replacingOccurrences(of: decimalString, with: "")
                let replaceDecimal = removeOtherDecimals.replacingOccurrences(of: "D", with: ".")
                return replaceDecimal
            } else {
                return numericOnlyString
            }
        } catch {
            return ""
        }
    }
    
    func convertEth(decimals: Int) -> Double {
        //***************** Since we are just displaying a rounded balance and not sending transactions ATM
        //***************** no integer manipulation is being done and we are just getting a rounded value
        // But once Web3 is involved there will be a lot of steps done to handle the integer counts of different currencies
        guard self.count >= decimals - 7 else { return 0 }
        let roundNumber: Int = {
            if self.count > decimals + 4 {
                return decimals - 3
            } else {
                return decimals - 8
            }
        }()
        let newString = self[startIndex..<index(startIndex, offsetBy: self.count - roundNumber)]
        print(newString)
        guard let doubleValue = Double(newString) else { return 0 }
        return doubleValue / pow(10, Double(18 - roundNumber))
    }
}

extension Double {
    func toString() -> String {
        return "\(self)"
    }
}

extension UIViewController {
    func alert(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(dismiss)
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }
    
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
    
}

extension UITextView {
    convenience init(font: UIFont, textColor: UIColor) {
        self.init()
        self.font = font
        self.textColor = textColor
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

func fontLight(_ size: CGFloat) -> UIFont {
    guard let fontLight = UIFont(name: "Lato-Light", size: size) else {
        return UIFont.systemFont(ofSize: size)
    }
    return fontLight
}

func fontRegular(_ size: CGFloat) -> UIFont {
    guard let fontLight = UIFont(name: "Lato-Regular", size: size) else {
        return UIFont.systemFont(ofSize: size)
    }
    return fontLight
}

func fontBold(_ size: CGFloat) -> UIFont {
    guard let fontLight = UIFont(name: "Lato-Bold", size: size) else {
        return UIFont.systemFont(ofSize: size)
    }
    return fontLight
}

func setColor(hValue: String) -> UIColor {
    var color = hValue
    if color.hasPrefix("#") {
        color.removeFirst()
    }
    if color.count < 6 {
        return .white
    }
    var rgb: UInt32 = 0
    Scanner(string: color).scanHexInt32(&rgb)
    return UIColor(red: CGFloat((rgb & 0xFF0000) >> 16) / 255, green: CGFloat((rgb & 0x00FF00) >> 8) / 255, blue: CGFloat((rgb & 0x0000FF)) / 255, alpha: 1)
}
