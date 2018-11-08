//
//  IconImageView.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/08.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

@IBDesignable
class IconImageView: UIImageView {

    // 角丸にするための数値
    @IBInspectable var cornerRadius: CGFloat = 15 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            clipsToBounds = cornerRadius > 0 ? true : false
        }
    }
    
//    override func draw(_ rect: CGRect) {
//    }
}
