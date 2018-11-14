//
//  Database.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/10/26.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

/// データベースへのアクセスを担うクラス
class AnniversaryDAO {
    
    var db = Firestore.firestore()

    let uuid = UserDefaults.standard.string(forKey: "uuid")!

    /// 記念日データを取得する
    ///
    /// - Parameter:
    ///   - id: 記念日ID
    ///   - callback: ドキュメントのデータを受け取る
    func getAnniversary(on id: String, callback: @escaping ([String: Any]) -> Void) {
        db.collection("users").document(uuid).collection("anniversary").document(id).getDocument { (document, error) in
            // ドキュメントのアンラップと存在チェック
            if let document = document, document.exists {
                callback(document.data()!)
            }
        }
    }
    
    // 未使用
    func setData(collection: String,
                 document: String,
                 subCollection: String,
                 subDocument: String,
                 data: [String: Any]) {
        db.collection(collection).document(document).collection(subCollection)
            .document(subDocument).setData(data) { error in
                if let error = error {
                    print("ドキュメント追加時にエラー発生: \(error)")
                } else {
                    print("ドキュメントの追加に成功しました！")
                }
        }
    }
}
