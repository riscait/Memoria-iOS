//
//  Migration.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/01/13.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import Foundation
import Firebase

struct Migration {
    
    enum Key: String {
        case isFinishedTutorial
        case isFinishedMigration210
    }
    
    static let userDefaults = UserDefaults.standard
    
    static func db(on rootVC: UIViewController) {
        
        userDefaults.register(defaults: [Key.isFinishedMigration210.rawValue : false])
        
        /* 条件
         1. まだこのマイグレーション判定を通過していない
         2. チュートリアルが終わっている
         */
        if !userDefaults.bool(forKey: Key.isFinishedMigration210.rawValue),
            userDefaults.bool(forKey: Key.isFinishedTutorial.rawValue){
            print("Ver.2.1.0 のマイグレーションを実行")
            
            // 全ての記念日を取得
            AnniversaryDAO.anniversaryCollection.getDocuments { (query, error) in
                if let error = error {
                    print(error.localizedDescription.localized)
                }
                guard let query = query, query.documents.count > 0 else {
                    print("queryが空っぽです")
                    print("Ver.2.1.0 のマイグレーションを終了")
                    userDefaults.set(true, forKey: Key.isFinishedMigration210.rawValue)
                    return
                }
                DialogBox.showAlertWithIndicator(on: rootVC, message: "startMigration".localized) {
                    print("全記念日を調べます")
                    for (index, doc) in query.documents.enumerated() {
                        // 今何個目？
                        let count = index + 1
                        let max = query.documents.count
                        
                        print(count, "個目の記念日")
                        let id = doc.data()["id"] as! String
                        let category = doc.data()["category"] as! String
                        
                        switch category {
                        case "contactBirthday":
                            print("\(id) is 'Contact birthday', Migrate to the 'birthday'")
                            AnniversaryDAO.update(anniversaryId: id, field: "category", content: "birthday")
                            AnniversaryDAO.update(anniversaryId: id, field: "isFromContact", content: true)
                            
                        case "manualBirthday":
                            print("\(id) is 'Manual birthday', Migrate to the 'birthday'")
                            AnniversaryDAO.update(anniversaryId: id, field: "category", content: "birthday")
                            AnniversaryDAO.update(anniversaryId: id, field: "isFromContact", content: false)
                            
                        case "birthday":
                            print("\(id) is 'birthday', Migration is unnecessary")

                        case "anniversary":
                            print("\(id) is 'Anniversary', Add new properties")
                            fallthrough
                        default:
                            print("\(id) is 'Other anniversary', Add new properties")
                            AnniversaryDAO.update(anniversaryId: id, field: "isFromContact", content: false)
                        }
                        AnniversaryDAO.anniversaryCollection.document(id).updateData(["isAnnualy": true]) { error in
                            if let error = error {
                                print("エラー発生: \(error)")
                            } else {
                                print(count, "個目のisAnnualyアップデートを成功")
                            }
                            // ダイアログに表示するメッセージ
                            let message = String(format: "underMigration".localized, arguments: [count, max])
                            // ダイアログのメッセージを更新
                            DialogBox.updateAlert(with: message, on: rootVC)
                            //
                            if count == max {
                                DialogBox.dismissAlertWithIndicator(on: rootVC, completion: nil)
                                print("Ver.2.1.0 のマイグレーションを終了")
                                userDefaults.set(true, forKey: Key.isFinishedMigration210.rawValue)
                            }
                        }
                    }
                }
            }
        } else {
            print("Ver.2.1.0 のマイグレーションは必要ありません")
            userDefaults.set(true, forKey: Key.isFinishedMigration210.rawValue)
        }
    }
}
