//
//  NegativeButton.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/18.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

class NegativeButton: UIButton {

    @IBInspectable var localizedStringKey: String = "" {
        didSet {
            guard !localizedStringKey.isEmpty else { return }
            setTitle(NSLocalizedString(localizedStringKey, comment: ""), for: .normal)
        }
    }

    override func draw(_ rect: CGRect) {
        // 角丸
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
        super.draw(rect)
    }
}
