//
//  AnniversaryDAO.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/10/26.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

import Firebase

/// データベースへのアクセスを担うクラス
class AnniversaryDAO {
    
    // MARK: - プロパティ
    
    /// FirestoreDB
    private var db = Firestore.firestore()
    /// Firebase Auth - User ID
    private let uid = Auth.auth().currentUser?.uid
    // Unique collection
    private static let rootCollection = "users"
    private static let subCollection = "anniversary"
    
    /// Taptic Engine
    private var feedbackGenerator: UINotificationFeedbackGenerator?

    // MARK: - データ取得
    
    /// Firestoreから記念日データを取得する
    ///
    /// - Parameter:
    ///   - id: 記念日ID
    ///   - callback: ドキュメントのデータを受け取る
    func get(by id: String,
                            callback: @escaping ([String: Any]) -> Void) {
        guard let uid = uid else { return }
        db.collection("users").document(uid).collection("anniversary").document(id).getDocument { (document, error) in
            if let error = error {
                print("エラー発生: \(error)")
            } else {
                print("\(#function)の実行に成功しました！")
            }
            // ドキュメントのアンラップと存在チェック
            if let document = document, document.exists {
                callback(document.data()!)
            }
        }
    }
    
    /// Anniversaryドキュメントの検索結果Queryを取得する
    ///
    /// - Parameters:
    ///   - whereField: 検索対象
    ///   - equalTo: 検索条件
    /// - Returns: 検索結果
    func getQuery(whereField: String,
                             equalTo: Any) -> Query? {
        guard let uid = uid else { return nil }
        return db.collection("users").document(uid).collection("anniversary").whereField(whereField, isEqualTo: equalTo)
    }
    
    /// getAnniversaryQuery()の検索結果ドキュメントを取得する
    ///
    /// - Parameter:
    ///   - whereField: 検索対象
    ///   - equalTo: 検索条件
    ///   - callback: ドキュメントのデータを受け取る
    func getFilteredAnniversaryDocuments(whereField: String,
                             equalTo: Any,
                             callback: @escaping ([QueryDocumentSnapshot]) -> Void) {
        getQuery(whereField: whereField, equalTo: equalTo)?.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("エラー発生: \(error)")
            } else {
                print("\(#function)の実行に成功しました！")
            }
            // ドキュメントのアンラップと存在チェック
            if let documents = querySnapshot?.documents {
                callback(documents)
            }
        }
    }


    // MARK: - データ登録・更新
    
    /// Firestoreへのデータ登録・更新
    ///
    /// - Parameters:
    ///   - collection: ルートコレクション
    ///   - document: ドキュメント
    ///   - subCollection: サブコレクション
    ///   - subDocument: サブコレクション
    ///   - data: 登録するデータ
    ///   - marge: 既存のドキュメントにデータを統合するか否か
    func setData(collection: String,
                 document: String,
                 subCollection: String,
                 subDocument: String,
                 data: [String: Any],
                 merge: Bool) {
            db.collection(collection).document(document).collection(subCollection)
                .document(subDocument).setData(data, merge: merge) { error in
                    if let error = error {
                        print("エラー発生: \(error)")
                    } else {
                        print("\(#function)の実行に成功しました！")
                    }
            }
    }
    
    /// Firestoreへのデータ登録・更新
    ///
    /// - Parameters:
    ///   - collection: ルートコレクション
    ///   - document: ドキュメント
    ///   - subCollection: サブコレクション
    ///   - subDocument: サブコレクション
    ///   - data: 登録するデータ
    ///   - marge: 上書き対象のデータ(任意)
    func setDataWithMergeTarget(collection: String,
                 document: String,
                 subCollection: String,
                 subDocument: String,
                 data: [String: Any],
                 mergeTarget: [String]) {
            db.collection(collection).document(document).collection(subCollection)
                .document(subDocument).setData(data, mergeFields: mergeTarget) { error in
                    if let error = error {
                        print("エラー発生: \(error)")
                    } else {
                        print("\(#function)の実行に成功しました！")
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
    func updateAnniversary(documentPath: String, field: String, content: Any) {
        guard let uid = uid else { return }
        db.collection("users").document(uid).collection("anniversary").document(documentPath).updateData([field: content]) { error in
            if let error = error {
                print("エラー発生: \(error)")
            } else {
                print("\(#function)の実行に成功しました！")
            }
        }
    }
    
    // MARK: - データ削除
    
    /// 検索して該当したAnniversaryドキュメントを削除する
    ///
    /// - Parameters:
    ///   - whereField: 検索対象
    ///   - equalTo: 検索条件
    func deleteAnniversary(documentPath: String) {
        guard let uid = uid else { return }
        db.collection("users").document(uid).collection("anniversary").document(documentPath).delete() { error in
            if let error = error {
                print("エラー発生: \(error)")
            } else {
                print("\(#function)の実行に成功しました！")
            }
        }
    }

    /// 検索して該当したAnniversaryドキュメントを削除する
    ///
    /// - Parameters:
    ///   - whereField: 検索対象
    ///   - equalTo: 検索条件
    func deleteQueryAnniversary(whereField: String, equalTo: Any,
                                on roorVC: UIViewController, compltion: (() -> Void)? = nil) {
        
        guard let uid = uid else { return }
        db.collection("users").document(uid).collection("anniversary").whereField(whereField, isEqualTo: equalTo).getDocuments { (querySnapshot, error) in
            
            // Instantiate a new feedback-generator
            self.feedbackGenerator = UINotificationFeedbackGenerator()
            self.feedbackGenerator?.prepare()
            
            if let error = error {
                print("エラー発生: \(error)")
                DialogBox.showAlert(on: roorVC, message: NSLocalizedString("deleteAnniversaryFilure", comment: ""))
                self.feedbackGenerator?.notificationOccurred(.error)
                
            } else if let documents = querySnapshot?.documents,
                !documents.isEmpty {
                print("\(#function)の実行に成功しました！", documents.description)
                documents.forEach { $0.reference.delete() }
                DialogBox.showAlert(on: roorVC, message: NSLocalizedString("deleteAnniversarySuccess", comment: ""))
                self.feedbackGenerator?.notificationOccurred(.success)
            } else {
                print("documentsが空")
                DialogBox.showAlert(on: roorVC, message: NSLocalizedString("deleteAnniversaryEmpty", comment: ""))
                self.feedbackGenerator?.notificationOccurred(.warning)
            }
        }
    }
}
