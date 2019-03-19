//
//  AnnivDetailInfoCell.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/03/19.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit

/// 記念日情報にプラスする情報を表示するセル
final class AnnivDetailInfoCell: UITableViewCell {
    /// 記念日詳細画面の記念日情報セクションで表示するセル内容
    enum contentType {
        case zodiacStarSign
        case chineseZodiacSign
    }
    /// セルの設定を行う
    func configure(anniv: Anniv, contentType: contentType) {
        switch contentType {
        case .zodiacStarSign:
            textLabel?.text = "zodiacStarSign".localized
            detailTextLabel?.text = ZodiacSign.Star.getStarSign(date: anniv.date.dateValue())
        case .chineseZodiacSign:
            textLabel?.text = "chineseZodiacSign".localized
            detailTextLabel?.text = ZodiacSign.Chinese.getChineseZodiacSign(date: anniv.date.dateValue())
        }
    }
}
