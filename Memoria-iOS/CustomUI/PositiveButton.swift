//
//  PositiveButton.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/17.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

// 進むや登録などポジティブなボタン
@IBDesignable final class PositiveButton: UIButton {

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
        self.layer.backgroundColor = #colorLiteral(red: 1, green: 0.6762310863, blue: 0, alpha: 1).cgColor
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
