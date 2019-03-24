//
//  GiftListCell.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/03/22.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit

class GiftListCell: UITableViewCell {

    @IBOutlet private weak var giftIconImage: IconImageView!
    @IBOutlet private weak var personNameLabel: UILabel!
    @IBOutlet private weak var annivNameLabel: UILabel!
    @IBOutlet private weak var giftDeliveryDateLabel: UILabel!
    @IBOutlet private weak var giftNameLabel: UILabel!
    @IBOutlet private weak var gotOrReceivedLabel: TagLabel!
    
    func configure(gift: Gift) {
        giftIconImage.image = #imageLiteral(resourceName: "giftBox")
        personNameLabel.text = gift.personName
        annivNameLabel.text = gift.annivName
        if let giftDeliveryDate = gift.date?.dateValue() {
            giftDeliveryDateLabel.text = DateTimeFormat.getYMDString(date: giftDeliveryDate)
        } else {
            giftDeliveryDateLabel.text = "dateTBD".localized
        }
        giftNameLabel.text = gift.goods
        gotOrReceivedLabel.text = gift.isReceived ? "gotGift".localized : "gaveGift".localized
        DispatchQueue.main.async {
            self.gotOrReceivedLabel.backgroundColor = gift.isReceived ? #colorLiteral(red: 1, green: 0.6629999876, blue: 0.07800000161, alpha: 1) : #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        }
    }
}
