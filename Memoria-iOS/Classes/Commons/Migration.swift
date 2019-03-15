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
    
    static func start(on rootVC: UIViewController, completion: @escaping () -> Void) {
        /* 条件
         1. まだこのマイグレーション判定を通過していない
         2. チュートリアルが終わっている
         */
        print("Ver.2.1.0 のマイグレーションを実行")
        // インジケーター付きアラートダイアログをポップアップ
        DialogBox.showAlertWithIndicator(on: rootVC, message: "startMigration".localized) {
            // ☆ isHiddenしかないドキュメントを消すマイグレーションが必要
            // ① まず、非表示フラグがtrueのデータを検索し、非表示フラグをすべてNullにする
            AnnivDAO.update(searchField: "isHidden", isEqualTo: true, updateField: "isHidden", turns: NSNull()) {
                print("Ver.2.1.0 のisHiddenマイグレーションを開始")
                // ② 非表示フラグがNullかつ、idがある記念日を検索
                AnnivDAO.getQuery(whereField: "isHidden", equalTo: NSNull())?.whereField("id", isGreaterThan: "").getDocuments { (query, error) in
                    if let error = error {
                        print("Ver.2.1.0 のisHiddenマイグレーション中にエラー発生: \(error)")
                        DialogBox.dismissAlertWithIndicator(on: rootVC, completion: nil)
                        completion()
                        return
                    } else {
                        print("\(#function)の実行に成功:")
                    }
                    // ③ 非表示フラグをすべてfalseにする
                    query?.documents.forEach { $0.reference.updateData(["isHidden" : false]) }
                    print("Ver.2.1.0 のisHiddenマイグレーションを終了")
                    DialogBox.updateAlert(with: "nextMigration".localized, on: rootVC) {
                        // ☆ 二つに分けた誕生日を一つにまとめる
                        // ① 非表示ではない記念日を検索
                        AnnivDAO.getFilteredDocuments(whereField: "isHidden", equalTo: false) { (query) in
                            print("Ver.2.1.0 の誕生日タイプマイグレーションを開始")
                            guard query.count > 0 else {
                                print("queryが空っぽです")
                                print("Ver.2.1.0 の誕生日タイプマイグレーションを終了")
                                userDefaults.set(true, forKey: Key.isFinishedMigration210.rawValue)
                                DialogBox.dismissAlertWithIndicator(on: rootVC, completion: nil)
                                completion()
                                return
                            }
                            print("全記念日を調べます")
                            for (index, doc) in query.enumerated() {
                                // 今何個目？
                                let count = index + 1
                                let max = query.count
                                
                                print(count, "個目の記念日")
                                let id = doc.data()["id"] as! String
                                let category = doc.data()["category"] as! String
                                // ② 記念日タイプによって振り分け、各プロパティを更新
                                switch category {
                                case "contactBirthday":
                                    print("\(id) is 'Contact birthday', Migrate to the 'birthday'")
                                    AnnivDAO.update(with: id, field: "category", content: "birthday")
                                    AnnivDAO.update(with: id, field: "isFromContact", content: true)
                                    
                                case "manualBirthday":
                                    print("\(id) is 'Manual birthday', Migrate to the 'birthday'")
                                    AnnivDAO.update(with: id, field: "category", content: "birthday")
                                    AnnivDAO.update(with: id, field: "isFromContact", content: false)
                                    
                                case "birthday":
                                    print("\(id) is 'birthday', Migration is unnecessary")
                                    
                                case "anniversary":
                                    print("\(id) is 'Anniversary', Add new properties")
                                    fallthrough
                                default:
                                    print("\(id) is 'Other anniversary', Add new properties")
                                    AnnivDAO.update(with: id, field: "isFromContact", content: false)
                                }
                                // ③ isAnnualyとmemoはすべてのタイプで更新する
                                AnnivDAO.annivCollection.document(id)
                                    .updateData(["isAnnualy": true, "memo": ""]) { error in
                                        if let error = error {
                                            DialogBox.dismissAlertWithIndicator(on: rootVC, completion: nil)
                                            print("エラー発生: \(error)")
                                            completion()
                                            return
                                            
                                        } else {
                                            print(count, "個目のアップデートを成功")
                                        }
                                        // ダイアログのメッセージを更新
                                        let message = String(format: "underMigration".localized, arguments: [count, max])
                                        DialogBox.updateAlert(with: message, on: rootVC)
                                        
                                        // ④ 最後の記念日更新なら終了する
                                        if count == max {
                                            DialogBox.dismissAlertWithIndicator(on: rootVC, completion: nil)
                                            print("Ver.2.1.0 の誕生日タイプマイグレーションを終了")
                                            userDefaults.set(true, forKey: Key.isFinishedMigration210.rawValue)
                                            completion()
                                        }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
