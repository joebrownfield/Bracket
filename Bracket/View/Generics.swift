//
//  Generics.swift
//  Bracket
//
//  Created by Joseph Brownfield on 7/8/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit

class GenericLabel: UILabel {
    init(_ text: String, _  alignment: NSTextAlignment, _  font: UIFont, _ color: UIColor) {
        super.init(frame: .zero)
        self.text = text
        self.textColor = color
        self.textAlignment = alignment
        self.font = font
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class GenericNumTextField: UITextField {
    init(_ text: String, _ alignment: NSTextAlignment, _ font: UIFont) {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        self.font = font
        self.keyboardType = .numbersAndPunctuation
        self.autocorrectionType = .no
        self.clearButtonMode = .whileEditing
        self.borderStyle = UITextField.BorderStyle.roundedRect
        self.alpha = 0.9
        self.textAlignment = alignment
        self.placeholder = text
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class GenericButton: UIButton {
    init(title: String, radius: CGFloat?, color: UIColor, font: UIFont) {
        super.init(frame: .zero)
        self.setTitle(title, for: [])
        if radius != nil {
            self.layer.cornerRadius = radius!
            self.clipsToBounds = true
        }
        self.backgroundColor = color
        self.titleLabel?.font = font
        self.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.5), for: .highlighted)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GenericView: UIView {
    init(color: UIColor, alpha: CGFloat) {
        super.init(frame: .zero)
        self.backgroundColor = color
        self.alpha = alpha
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}













