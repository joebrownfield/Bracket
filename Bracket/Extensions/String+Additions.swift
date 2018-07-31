//
//  String+Additions.swift
//  Bracket
//
//  Created by Joseph Brownfield on 7/31/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit

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

