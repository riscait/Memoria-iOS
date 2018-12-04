//
//  InspectableTextField.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/25.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

@IBDesignable class InspectableTextField: UITextField {

    // プレースホルダーのローカライズ文字列
    @IBInspectable var placeholderLocalizedStringKey: String = "" {
        didSet {
            guard !placeholderLocalizedStringKey.isEmpty else { return }
            placeholder = NSLocalizedString(placeholderLocalizedStringKey, comment: "")
        }
    }
    // 左の画像
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    // 左の画像の色
    @IBInspectable var leftImageColor: UIColor = UIColor.lightGray {
        didSet {
            updateView()
        }
    }
    // 左の余白
    @IBInspectable var leftPadding: CGFloat = 10
    
    // 左画像のための余白
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }
    // 左の画像を更新する
    func updateView() {
        if let image = leftImage {
            leftViewMode = .always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            // 注意：画像に濃淡を使用するには、Assets.xcassetsで画像を選択し、[Render As]プロパティを[Template Image]に変更する必要があります。
            imageView.tintColor = leftImageColor
            leftView = imageView
        } else {
            leftViewMode = .never
            leftView = nil
        }
    }
}
