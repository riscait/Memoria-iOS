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
            // インジケーター付きアラートダイアログをポップアップ
            DialogBox.showAlertWithIndicator(on: rootVC, message: "startMigration".localized) {
                // ☆ isHiddenしかないドキュメントを消すマイグレーションが必要
                // ① まず、非表示フラグがtrueのデータを検索し、非表示フラグをすべてNullにする
                AnniversaryDAO.update(searchField: "isHidden", isEqualTo: true, updateField: "isHidden", turns: NSNull()) {
                    print("Ver.2.1.0 のisHiddenマイグレーションを開始")
                    // ② 非表示フラグがNullかつ、idがある記念日を検索
                    AnniversaryDAO.getQuery(whereField: "isHidden", equalTo: NSNull())?.whereField("id", isGreaterThan: "").getDocuments { (query, error) in
                        if let error = error {
                            print("Ver.2.1.0 のisHiddenマイグレーション中にエラー発生: \(error)")
                            DialogBox.dismissAlertWithIndicator(on: rootVC, completion: nil)
                            return
                        } else {
                            print("\(#function)の実行に成功:")
                        }
                        // ③ 非表示フラグをすべてfalseにする
                        query?.documents.forEach { $0.reference.updateData(["isHidden" : false]) }
                        print("Ver.2.1.0 のisHiddenマイグレーションを終了")
                        
                        DialogBox.updateAlert(with: "後半のマイグレーション".localized, on: rootVC) {
                            // ☆ 二つに分けた誕生日を一つにまとめる
                            // ① 非表示ではない記念日を検索
                            AnniversaryDAO.getFilteredAnniversaryDocuments(whereField: "isHidden", equalTo: false) { (query) in
                                print("Ver.2.1.0 の誕生日タイプマイグレーションを開始")
                                guard query.count > 0 else {
                                    print("queryが空っぽです")
                                    print("Ver.2.1.0 の誕生日タイプマイグレーションを終了")
                                    userDefaults.set(true, forKey: Key.isFinishedMigration210.rawValue)
                                    DialogBox.dismissAlertWithIndicator(on: rootVC, completion: nil)
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
                                    // ③ isAnnualyはすべてのタイプで更新する
                                    AnniversaryDAO.anniversaryCollection.document(id).updateData(["isAnnualy": true]) { error in
                                        if let error = error {
                                            DialogBox.dismissAlertWithIndicator(on: rootVC, completion: nil)
                                            print("エラー発生: \(error)")
                                            return
                                            
                                        } else {
                                            print(count, "個目のisAnnualyアップデートを成功")
                                        }
                                        // ダイアログのメッセージを更新
                                        let message = String(format: "underMigration".localized, arguments: [count, max])
                                        DialogBox.updateAlert(with: message, on: rootVC)
                                        
                                        // ④ 最後の記念日更新なら終了する
                                        if count == max {
                                            DialogBox.dismissAlertWithIndicator(on: rootVC, completion: nil)
                                            print("Ver.2.1.0 の誕生日タイプマイグレーションを終了")
                                            userDefaults.set(true, forKey: Key.isFinishedMigration210.rawValue)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            print("Ver.2.1.0 の誕生日タイプマイグレーションは必要ありません")
            userDefaults.set(true, forKey: Key.isFinishedMigration210.rawValue)
        }
    }
}
