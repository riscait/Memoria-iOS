//
//  AnnivDetailGiftCell.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/03/19.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit

/// 記念日に紐付くギフト情報を表示するセル
final class AnnivDetailGiftCell: UITableViewCell {
    // MARK: - IBOutlet properties
    @IBOutlet private weak var giftImage: IconImageView!
    @IBOutlet private weak var annivOrPersonNameLabel: UILabel!
    @IBOutlet private weak var giftNameLabel: UILabel!
    @IBOutlet private weak var gotOrReceivedLabel: TagLabel!
    
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
