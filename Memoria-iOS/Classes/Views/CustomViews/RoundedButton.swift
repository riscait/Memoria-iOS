//
//  PositiveButton.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/17.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

// 進むや登録などポジティブなボタン
@IBDesignable final class RoundedButton: UIButton {
    
    /// 多言語化のための文字列キー
    @IBInspectable var localizedStringKey: String = "" {
        didSet {
            guard !localizedStringKey.isEmpty else { return }
            setTitle(NSLocalizedString(localizedStringKey, comment: ""), for: .normal)
        }
    }
    /// ボタンの枠線太さ
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    /// 枠線の色
    @IBInspectable var borderColor: UIColor = .gray {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    override func draw(_ rect: CGRect) {
        // 状態変化
        switch state {
        case .disabled:
            layer.opacity = 0.5
        default:
            layer.opacity = 1
        }
        // 角丸
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
        // 太字にする
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        
        super.draw(rect)
    }
}
