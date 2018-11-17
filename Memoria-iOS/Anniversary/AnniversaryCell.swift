//
//  AnniversaryCell.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/08.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

final class AnniversaryCell: UICollectionViewCell {
    
    @IBOutlet weak var anniversaryId: UILabel!
    @IBOutlet weak var anniversaryNameLabel: UILabel!
    @IBOutlet weak var anniversaryDateLabel: UILabel!
    @IBOutlet weak var remainingDaysLabel: UILabel!
    @IBOutlet weak var anniversaryIconImage: IconImageView!
    
    /// セル再利用の準備
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 文字色をリセットする
        anniversaryNameLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        anniversaryDateLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        // 背景色として使っているグラデをリセットする
        guard let layer = layer.sublayers else { return }
        for layer in layer {
            guard let name = layer.name else { continue }
            if name == "grade" {
                layer.removeFromSuperlayer()
            }
        }
    }
}
