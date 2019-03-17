//
//  AnnivDetailCells.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/03/17.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit

/// 詳細画面で記念日の名前やアイコンを表示するメインセル
final class AnnivDetailTopCell: UITableViewCell {
    // MARK: - IBOutlet properties
    @IBOutlet weak var annivImage: IconImageView!
    @IBOutlet weak var annivNameLabel: UILabel!
    @IBOutlet weak var annivDateLabel: UILabel!
    
    func configure(anniv: Anniv) {
        // 記念日のアイコン
        annivImage.image = AnnivUtil.getIconImage(from: anniv)
        // 記念日の名前
        annivNameLabel.text = AnnivUtil.getName(from: anniv)
        // 記念日の日程
        annivDateLabel.text = DateTimeFormat.getYMDString(date: anniv.date.dateValue())
    }
}
/// 記念日情報にプラスする情報を表示するセル
final class AnnivDetailInfoCell: UITableViewCell {
    
    func configure(anniv: Anniv, row: Int) {
        switch row {
        case 1:
            textLabel?.text = "zodiacStarSign".localized
            detailTextLabel?.text = ZodiacSign.Star.getStarSign(date: anniv.date.dateValue())
        case 2:
            textLabel?.text = "chineseZodiacSign".localized
            detailTextLabel?.text = ZodiacSign.Chinese.getChineseZodiacSign(date: anniv.date.dateValue())
        default: break
        }
    }
}
/// 記念日に紐付くギフト情報を表示するセル
final class AnnivDetailGiftCell: UITableViewCell {
    // MARK: - IBOutlet properties
    @IBOutlet weak var giftImage: IconImageView!
    @IBOutlet weak var annivOrPersonNameLabel: UILabel!
    @IBOutlet weak var giftNameLabel: UILabel!
    @IBOutlet weak var gotOrReceivedLabel: TagLabel!
    
    func configure(annivCategory: AnnivType, gifts: [[String: Any]], row: Int) {
        let isReceived = gifts[row]["isReceived"] as! Bool
        switch annivCategory {
        case .birthday: annivOrPersonNameLabel.text = gifts[row]["anniversaryName"] as? String
        case .anniv: annivOrPersonNameLabel.text = gifts[row]["personName"] as? String
        }
        giftNameLabel.text = gifts[row]["goods"] as? String
        gotOrReceivedLabel.text = isReceived ? "gotGift".localized : "gaveGift".localized
        gotOrReceivedLabel.backgroundColor = isReceived ? #colorLiteral(red: 1, green: 0.6629999876, blue: 0.07800000161, alpha: 1) : #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
    }
}
