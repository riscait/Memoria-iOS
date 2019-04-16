//
//  GiftDAO.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/12.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

import Firebase

/// データベースへのアクセスを担うクラス
class GiftDAO {
    
    // MARK: - プロパティ
    
    /// FirestoreDB
    private static var db = Firestore.firestore()
    /// Firebase Auth - User ID
    private static let uid = Auth.auth().currentUser?.uid
    // Unique collection
    private static let usersCollection = db.collection("users")
    static let giftCollection = usersCollection.document(uid!).collection("gift")

    
    // MARK: - データ取得
    
    /// Firestoreから記念日データを取得する
    ///
    /// - Parameter:
    ///   - id: Gift ID
    ///   - callback: ドキュメントのデータを受け取る
    static func get(by id: String, callback: @escaping ([String: Any]) -> Void) {
        giftCollection.document(id).getDocument { (document, error) in
            if let error = error {
                Log.warn(error.localizedDescription)
            }
            // ドキュメントのアンラップと存在チェック
            if let document = document, document.exists {
                callback(document.data()!)
            }
        }
    }
    
    /// giftドキュメントの検索結果Queryを取得する
    ///
    /// - Parameters:
    ///   - whereField: 検索対象
    ///   - equalTo: 検索条件
    /// - Returns: 検索結果
    static func getQuery(whereField: String,
                             equalTo: Any,
                             orderBy: String? = nil,
                             descending: Bool? = nil) -> Query? {
        if let orderBy = orderBy {
            if let descending = descending {
                return giftCollection.whereField(whereField, isEqualTo: equalTo).order(by: orderBy, descending: descending)
            }
            return giftCollection.whereField(whereField, isEqualTo: equalTo).order(by: orderBy)
        }
        return giftCollection.whereField(whereField, isEqualTo: equalTo)
    }


    // MARK: - データ登録
    
    /// Firestoreへのデータ登録・更新
    ///
    /// - Parameters:
    ///   - documentPath: 一意のID
    ///   - data: 登録するデータ
    ///   - marge: 既存のドキュメントにデータを統合するか否か
    static func set(documentPath: String,
                    data: Gift,
                    merge: Bool = true) {
        giftCollection.document(documentPath).setData(data.toDictionary, merge: merge) { error in
                if let error = error {
                    Log.warn(error.localizedDescription)
                }
        }
    }
    
    
    // MARK: - データ更新
    
    /// 登録済みのデータを更新する
    ///
    /// - Parameters:
    ///   - documentPath: 一意のID
    ///   - field: 更新データ名
    ///   - content: 更新データ内容
    static func update(documentPath: String, field: String, content: Any) {
        giftCollection.document(documentPath)
            .updateData([field: content]) { error in
                if let error = error {
                    Log.warn(error.localizedDescription)
                }
        }
    }
    
    
    // MARK: - データ削除
    
    /// ドキュメントを削除する
    ///
    /// - Parameters:
    ///   - documentPath: 一意のID
    static func delete(documentPath: String) {
        giftCollection.document(documentPath)
            .delete() { error in
                if let error = error {
                    Log.warn(error.localizedDescription)
                }
        }
    }

    /// 検索して該当したドキュメントを削除する
    ///
    /// - Parameters:
    ///   - whereField: 検索対象
    ///   - equalTo: 検索条件
    static func queryAndDelete(whereField: String, equalTo: Any) {
        giftCollection.whereField(whereField, isEqualTo: equalTo).getDocuments { (querySnapshot, error) in
            if let error = error {
                Log.warn(error.localizedDescription)
            } else if let documents = querySnapshot?.documents {
                documents.forEach { $0.reference.delete() }
            }
        }
    }
    
    static func delete(at index: Int) {
        giftCollection.whereField("isHidden", isEqualTo: false).getDocuments { (querySnapshot, error) in
            if let error = error {
                Log.warn(error.localizedDescription)
            } else if let documents = querySnapshot?.documents {
                documents[index].reference.delete()
            }
        }
    }
}
