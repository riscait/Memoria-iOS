//
//  InspectableLabel.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/19.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

@IBDesignable class InspectableLabel: UILabel {

    @IBInspectable var localizedStringKey: String = "" {
        didSet {
            guard !localizedStringKey.isEmpty else { return }
            
            text = NSLocalizedString(localizedStringKey, comment: "")
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        text = NSLocalizedString(localizedStringKey, comment: "")
        super.draw(rect)
    }
}
