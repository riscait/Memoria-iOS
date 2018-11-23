//
//  AccentButton.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/20.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

/// ここぞという時のボタン
@IBDesignable final class AccentButton: UIButton {
    
    /// ローカライズ文字列
    @IBInspectable var localizedStringKey: String = "" {
        didSet {
            // ローカライズして文字列を表示する
            guard !localizedStringKey.isEmpty else { return }
            setTitle(NSLocalizedString(localizedStringKey, comment: ""), for: .normal)
        }
    }
    
    override func draw(_ rect: CGRect) {
        // 背景色
        self.layer.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1).cgColor
        // 角丸
        self.layer.cornerRadius = 3
        // 文字色
        self.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        // 内側の余白
        let padding: CGFloat = 10.0
        self.contentEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        super.draw(rect)
    }
}
