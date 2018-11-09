//
//  AnniversaryDetailVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/09.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

final class AnniversaryDetailVC: UIViewController {

    @IBOutlet weak var iconImageView: IconImageView!
    @IBOutlet weak var anniversaryNameLabel: UILabel!
    @IBOutlet weak var anniversaryDateLabel: UILabel!
    
    /// AnniversaryVCから受け取るデータ
    var anniversaryName: String?
    var anniversaryDate: String?
    var remainingDays: String?
    var iconImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 大きいタイトルをやめる
//         navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.title = remainingDays
        iconImageView.image = iconImage
        anniversaryNameLabel.text = anniversaryName
        anniversaryDateLabel.text = anniversaryDate
        
        let right = UIBarButtonItem(title: "非表示にする", style: .plain, target: self, action: #selector(toggleHidden))
        
        navigationItem.rightBarButtonItem = right
    }
    
    @objc private func toggleHidden() {
        print("非表示処理")
    }
}
