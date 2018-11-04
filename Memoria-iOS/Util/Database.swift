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
class Database {
    var db = Firestore.firestore()

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
