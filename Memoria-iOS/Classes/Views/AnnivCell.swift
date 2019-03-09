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
        backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.8901960784, blue: 0.8901960784, alpha: 1)
        remainingDaysLabel.backgroundColor = #colorLiteral(red: 1, green: 0.6629999876, blue: 0.07800000161, alpha: 1)
        contentView.alpha = 1.0
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
