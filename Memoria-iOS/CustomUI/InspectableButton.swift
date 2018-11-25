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
    @IBInspectable var cornerRadius: CGFloat = 15 {
        didSet {
            self.layer.cornerRadius = cornerRadius
//            clipsToBounds = cornerRadius > 0 ? true : false
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
