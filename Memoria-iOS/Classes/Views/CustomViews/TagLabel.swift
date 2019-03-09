//
//  TagLabel.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/10.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

/// タグのような見た目のカスタムUILabel
@IBDesignable class TagLabel: UILabel {

    // 角丸にするための数値
    @IBInspectable var cornerRadius: CGFloat = 15 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            clipsToBounds = cornerRadius > 0 ? true : false
        }
    }

    /// 余白設定
    @IBInspectable var padding = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right
        return contentSize
    }

//    override func draw(_ rect: CGRect) {
//    }
}
