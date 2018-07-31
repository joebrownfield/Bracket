//
//  UITextView+Additions.swift
//  Bracket
//
//  Created by Joseph Brownfield on 7/31/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit

extension UITextView {
    convenience init(font: UIFont, textColor: UIColor) {
        self.init()
        self.font = font
        self.textColor = textColor
    }
}
