//
//  InspectableStackView.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/01/06.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit

@IBDesignable class InspectableStackView: UIStackView {
    
    @IBInspectable var bottomBorderHeight: CGFloat = 0.0 {
        didSet {
            updateView()
        }
    }

    func updateView() {
        if bottomBorderHeight > 0.0 {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0, y: frame.height, width: frame.width, height: bottomBorderHeight)
            bottomBorder.backgroundColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
            layer.addSublayer(bottomBorder)
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
