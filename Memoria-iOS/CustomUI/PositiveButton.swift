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
    
    @IBInspectable var localizedStringKey: String = "" {
        didSet {
            guard !localizedStringKey.isEmpty else { return }
            setTitle(NSLocalizedString(localizedStringKey, comment: ""), for: .normal)
        }
    }
    
    override func draw(_ rect: CGRect) {
        // 背景色
        if state == .disabled {
            layer.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        } else if state == .normal {
            layer.backgroundColor = #colorLiteral(red: 1, green: 0.6762310863, blue: 0, alpha: 1).cgColor
        }
        // 角丸
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
        // 文字色
        setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        // 太字にする
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        
        super.draw(rect)
    }
}
