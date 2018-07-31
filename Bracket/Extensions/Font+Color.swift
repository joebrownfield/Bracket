//
//  Font+Color.swift
//  Bracket
//
//  Created by Joseph Brownfield on 7/31/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit

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
