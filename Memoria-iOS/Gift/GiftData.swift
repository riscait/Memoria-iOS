//
//  GiftData.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/12.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

import Firebase

class GiftData {
    // MARK: - プロパティ
    
    /// FirestoreDB
    var db = Firestore.firestore()
    /// Firebase Auth - User ID
    let uid = Auth.auth().currentUser?.uid

    let rootCollection = "users"
    let subCollection = "gift"
    
    
    // MARK: - データ登録・更新
    
    /// Firestoreへのデータ登録・更新
    ///
    /// - Parameters:
    ///   - documentPath: 一意のID
    ///   - data: 登録するデータ
    ///   - marge: 既存のドキュメントにデータを統合するか否か
    func set(documentPath: String, data: [String: Any], merge: Bool = true) {
        guard let uid = uid else { return }
        db.collection(rootCollection).document(uid).collection(subCollection).document(documentPath)
            .setData(data, merge: merge) { error in
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
    ///   - field: 登録データ名
    ///   - content: 登録データ内容
    func update(documentPath: String, field: String, content: Any) {
        guard let uid = uid else { return }
        db.collection(rootCollection).document(uid).collection(subCollection).document(documentPath)
            .updateData([field: content]) { error in
                if let error = error {
                    print("エラー発生: \(error)")
                } else {
                    print("\(#function)の実行に成功しました！")
                }
        }
    }
    
    
    // MARK: - データ削除
    
    /// ドキュメントを削除する
    ///
    /// - Parameters:
    ///   - documentPath: 一意のID
    func delete(documentPath: String) {
        guard let uid = uid else { return }
        db.collection(rootCollection).document(uid).collection(subCollection).document(documentPath)
            .delete() { error in
                if let error = error {
                    print("エラー発生: \(error)")
                } else {
                    print("\(#function)の実行に成功しました！")
                }
        }
    }

    /// 検索して該当したドキュメントを削除する
    ///
    /// - Parameters:
    ///   - whereField: 検索対象
    ///   - equalTo: 検索条件
    func queryAndDelete(whereField: String, equalTo: Any) {
        guard let uid = uid else { return }
        db.collection(rootCollection).document(uid).collection(subCollection).whereField(whereField, isEqualTo: equalTo).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("エラー発生: \(error)")
            } else if let documents = querySnapshot?.documents {
                documents.forEach { $0.reference.delete() }
                print("\(#function)の実行に成功しました！")
            }
        }
    }
}
