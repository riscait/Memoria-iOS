//
//  InspectableTextField.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/25.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

@IBDesignable class InspectableTextField: UITextField {

    @IBInspectable var placeholderLocalizedStringKey: String = "" {
        didSet {
            guard !placeholderLocalizedStringKey.isEmpty else { return }
            placeholder = NSLocalizedString(placeholderLocalizedStringKey, comment: "")
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
