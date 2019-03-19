//
//  AnnivDetailTopCell.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/03/17.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit

/// 詳細画面で記念日の名前やアイコンを表示するメインセル
final class AnnivDetailTopCell: UITableViewCell {
    // MARK: - IBOutlet properties
    @IBOutlet private weak var annivImage: IconImageView!
    @IBOutlet private weak var annivNameLabel: UILabel!
    @IBOutlet private weak var annivDateLabel: UILabel!
    
    func configure(anniv: Anniv) {
        // 記念日のアイコン
        annivImage.image = AnnivUtil.getIconImage(from: anniv)
        // 記念日の名前
        annivNameLabel.text = AnnivUtil.getName(from: anniv)
        // 記念日の日程
        annivDateLabel.text = DateTimeFormat.getYMDString(date: anniv.date.dateValue())
    }
}
