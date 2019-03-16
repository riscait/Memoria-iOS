//
//  AnnivCell.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/08.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

final class AnnivCell: UICollectionViewCell {
    
    @IBOutlet weak var annivNameLabel: UILabel!
    @IBOutlet weak var annivDateLabel: UILabel!
    @IBOutlet weak var remainingDaysLabel: TagLabel!
    @IBOutlet weak var annivIconImage: IconImageView!
    
    /// セル再利用の準備
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 色をリセットする
        annivNameLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        annivDateLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        contentView.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.8901960784, blue: 0.8901960784, alpha: 1)
        remainingDaysLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        remainingDaysLabel.backgroundColor = #colorLiteral(red: 1, green: 0.6629999876, blue: 0.07800000161, alpha: 1)
        remainingDaysLabel.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .regular)
        contentView.alpha = 1.0
    }
    
    func configure(anniv: Anniv) {
        // 記念日の名前
        annivNameLabel.text = AnnivUtil.getName(from: anniv)
        // 記念日の日程
        annivDateLabel.text = DateTimeFormat.getMonthDayString(date: anniv.date.dateValue())
        // 繰り返す記念日か否か
        let isAnnualy = anniv.isAnnualy
        // 記念日のアイコン
        annivIconImage.image = AnnivUtil.getIconImage(from: anniv)
        // 記念日までの残り日数
        guard let remainingDays = anniv.remainingDays else { return }
        // 過去の記念日かどうか
        let isPastAnniversary = remainingDays < 0 && !isAnnualy
        // 過去の記念日は薄くする
        contentView.alpha = isPastAnniversary ? 0.5 : 1.0
        // 近日中の記念日設定
        if 0...30 ~= remainingDays {
            // 文字
            annivNameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            annivDateLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            remainingDaysLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        if 1...30 ~= remainingDays {
            contentView.backgroundColor = #colorLiteral(red: 0.9737553, green: 0.6467057467, blue: 0, alpha: 1)
            remainingDaysLabel.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        }
        // 当日の記念日設定
        if remainingDays == 0 {
            contentView.backgroundColor = #colorLiteral(red: 0.8235294118, green: 0.0862745098, blue: 0.3921568627, alpha: 1)
            remainingDaysLabel.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            remainingDaysLabel.textColor = #colorLiteral(red: 0.8235294118, green: 0.0862745098, blue: 0.3921568627, alpha: 1)
            remainingDaysLabel.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        }
        // 記念日の残り日数文字列の設定
        remainingDaysLabel.text = remainingDays == -1 ? "remainingDaysYesterday".localized
            : remainingDays == 1 ? "remainingDaysTomorrow".localized
            : remainingDays == 0 ? "remainingDaysToday".localized
            : AnnivUtil.getRemainingDaysString(from: remainingDays)
    }
}
