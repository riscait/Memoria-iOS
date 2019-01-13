//
//  Migration.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/01/13.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import Foundation

struct Migration {
    
    enum Key: String {
        case isFinishedMigration210
    }
    
    let userDefaults = UserDefaults.standard
    
    private func DB() {
        
        userDefaults.register(defaults: [Key.isFinishedMigration210.rawValue : false])
        if !userDefaults.bool(forKey: Key.isFinishedMigration210.rawValue) {
            print("Ver.2.1.0 のマイグレーションを実行")
            // 全ての記念日を取得
            AnniversaryDAO.getAll { anniversarys in
                for anniversary in anniversarys {
                    if anniversary.category == .birthday,
                    anniversary.isFromContact
                }
            }
             isAnnualy, isFromContactの値を詰める
             categoryをAnniversaryType変更する
        }
    }
}
