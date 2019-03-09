//
//  InspectableTextView.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/15.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

@IBDesignable class InspectableTextView: UITextView {
    
    // MARK: - プロパティ
    
    /// プレースホルダー用ラベル
    private lazy var placeholderLabel = UILabel(frame: CGRect(x: 28, y: 2, width: 0, height: 0))
    /// アイコン用イメージビュー
    private lazy var leftImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
    
    /// プレースホルダーに表示する文字列（ローカライズ付き）
    @IBInspectable var localizedString: String = "" {
        didSet {
            guard !localizedString.isEmpty else { return }
            // Localizable.stringsを参照する
            placeholderLabel.text = NSLocalizedString(localizedString, comment: "")
            placeholderLabel.sizeToFit()  // 省略不可
        }
    }
    
    /// 左の画像
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateLeftImage()
        }
    }
    // 左の画像の色
    @IBInspectable var leftImageColor: UIColor = UIColor.lightGray {
        didSet {
            updateLeftImage()
        }
    }


    // MARK: - Viewライフサイクルメソッド
    /// ロード後に呼ばれる
    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
        configurePlaceholder()
        togglePlaceholder()
        updateLeftImage()
    }
    
    /// プレースホルダーを設定する
    private func configurePlaceholder() {
        placeholderLabel.textColor = UIColor.lightGray
        addSubview(placeholderLabel)
    }
    
    /// プレースホルダーの表示・非表示切り替え
    func togglePlaceholder() {
        // テキスト未入力の場合のみプレースホルダーを表示する
        placeholderLabel.isHidden = text.isEmpty ? false : true
    }
    
    func updateLeftImage() {
        if let image = leftImage {
            leftImageView.contentMode = .scaleAspectFit
            leftImageView.image = image
            // 画像に濃淡を使用するには、Assets.xcassetsで画像を選択し、[Render As]プロパティを[Template Image]に変更する必要がある。
            leftImageView.tintColor = leftImageColor
            addSubview(leftImageView)
            self.textContainerInset = UIEdgeInsets(top: 2, left: 24, bottom: 8, right: 0)
        }
    }
}

// MARK: -  UITextView Delegate
extension InspectableTextView: UITextViewDelegate {
    /// テキストが書き換えられるたびに呼ばれる ※privateにはできない
    func textViewDidChange(_ textView: UITextView) {
        togglePlaceholder()
    }
}
