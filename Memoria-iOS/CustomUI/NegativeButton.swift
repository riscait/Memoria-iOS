//
//  NegativeButton.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/18.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

class NegativeButton: UIButton {

    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 5
        self.setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: .normal)
        let padding: CGFloat = 15.0
        self.contentEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        super.draw(rect)
    }
}
