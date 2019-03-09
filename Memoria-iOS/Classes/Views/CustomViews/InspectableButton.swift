//
//  InspectableButton.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/24.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

@IBDesignable class InspectableButton: UIButton {
    
    @IBInspectable var localizedStringKey: String = "" {
        didSet {
            guard !localizedStringKey.isEmpty else { return }
            setTitle(NSLocalizedString(localizedStringKey, comment: ""), for: .normal)
        }
    }
    // 角丸にするための数値
    @IBInspectable var cornerRadius: CGFloat = 20 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            clipsToBounds = cornerRadius > 0 ? true : false
        }
    }
    override func draw(_ rect: CGRect) {
        
        // 太字にする
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        if state == .disabled {
            layer.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        }
        super.draw(rect)
    }
}
