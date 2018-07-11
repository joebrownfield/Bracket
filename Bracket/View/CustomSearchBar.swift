//
//  CustomSearchBar.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/11/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import UIKit

class CustomSearchBar: UISearchBar {

    
    var preferredFont: UIFont!
    var preferredTextColor: UIColor!
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        if let index = getSearchFieldIndex() {
            let searchField: UITextField = subviews[0].subviews[index] as! UITextField
            
            // Set its frame.
            searchField.frame = CGRect(x: 5.0, y: 5.0, width: frame.size.width - 10, height: frame.size.height - 10)
            
            // Set the font and text color of the search field.
            searchField.font = preferredFont
            searchField.textColor = preferredTextColor
            
            // Set the background color of the search field.
            searchField.backgroundColor = barTintColor
        }
        
        let startPoint = CGPoint(x: 0, y: frame.size.height)
        let endPoint = CGPoint(x: frame.size.width, y: frame.size.height)
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = preferredTextColor.cgColor
        shapeLayer.lineWidth = 2.5
        
        layer.addSublayer(shapeLayer)
        
        super.draw(rect)
        
    }
    
    init(frame: CGRect, font: UIFont, textColor: UIColor) {
        super.init(frame: frame)
        
        self.frame = frame
        preferredFont = font
        preferredTextColor = textColor
        
        searchBarStyle = .prominent
        isTranslucent = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getSearchFieldIndex() -> Int! {
        var index: Int!
        let searchBarView = subviews[0]
        
        for i in 0...searchBarView.subviews.count {
            if searchBarView.subviews[i].isKind(of: UITextField.self) {
                index = i
                return index
            }
        }
        return index
    }

}
