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
        // 文字色
        self.setTitleColor(#colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1), for: .normal)

        super.draw(rect)
    }
}
