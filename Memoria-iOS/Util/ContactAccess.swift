//
//  ContactAccess.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/10/25.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Contacts
import MessageUI
import StoreKit
import Firebase

class ContactAccess {
    
    // 連絡先のデータを格納するリスト
    private var data: [String: [Any]]?
    private var name: [String]?
    private var birthday: [Date]?
    private var anniversary: [Date]?
    private var image: [UIImage]?
    
    // 連絡先を取得するクラスのインスタンス
    let store = CNContactStore.init()
    
    /// 端末の連絡先アクセス許可状態をチェックする
    ///
    /// - Returns: アクセス可能状態ならTrue、それ以外はfalse
    func checkStatus() -> Bool {
        // 連絡帳へのアクセス許可状態
        let accessStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch accessStatus {
        case .notDetermined:
            print("連絡先へのアクセスは、まだ許可されていないか、機能制限等により利用不可です")
            // 連絡先へのアクセスを許可するかどうかのダイアログボックスを表示する
            store.requestAccess(for: .contacts, completionHandler: {(granted, Error) in
                // 拒否された場合は処理を終了する
                guard granted else {
                    print("連絡先へのアクセスが拒否されました")
                    return
                }
            })
            print("連絡先へのアクセスが許可されました")
            return true
            
        case .restricted:
            print("このアプリケーションは連絡先情報を使用できません")
            // TODO: 連絡先を取得できない旨を表示する
            
        case .denied:
            print("連絡先へのアクセスが拒否されている")
            // TODO: 設定で連絡先へのアクセスを許可してもらう必要がある
            
        case .authorized:
            print("連絡先へのアクセス可能")
            return true
        }
        return false
    }
    
    /// 連絡先にアクセスして、連絡先情報を取得する
    func accessContact() {
        
        // 個々の連絡先のデータを格納する配列
        var contacts = [CNContact]()
        
        do {
            // 誕生日情報を持つ連絡先から「名・姓・誕生日・サムネイル画像」を取得する
            try store.enumerateContacts(with: CNContactFetchRequest(keysToFetch: [CNContactIdentifierKey as CNKeyDescriptor,
                                                                                  CNContactGivenNameKey as CNKeyDescriptor,
                                                                                  CNContactFamilyNameKey as CNKeyDescriptor,
                                                                                  CNContactBirthdayKey as CNKeyDescriptor,
                                                                                  CNContactThumbnailImageDataKey as CNKeyDescriptor])) {
                                                                                    contact, cursor -> Void in
                                                                                    // 誕生日が入力されている連絡先だったら追加
                                                                                    if contact.birthday?.date != nil {
                                                                                        contacts.append(contact)
                                                                                    }
            }
        } catch {
            print("連絡先データの取得に失敗！")
            // TODO: なんらかのエラーアラートを出す
        }
        
        print("\(contacts.count)件の連絡先情報を見つけました！")
        
        for contact in contacts {
            
            guard let birthday = contact.birthday?.date else {
                print("\(contact.familyName, contact.givenName)の誕生日がnilだったため処理を終了します")
                return
            }
            let contactBirthday: [String: Any] = ["id": contact.identifier,
                                       "givenName": contact.givenName,
                                       "familyName": contact.familyName,
                                       "birthday": birthday,
                                       "tImage": contact.thumbnailImageData ?? ""
            ]
            
            // ユーザーのユニークIDを読み出す
            let userDefaults = UserDefaults.standard
            guard let uuid = userDefaults.string(forKey: "uuid") else {
                print("UUIDが見つかりません！")
                return
                
            }

            // データベースに連絡先の誕生日情報を保存する
            let database = Database()
            database.setData(collection: "users",
                             document: uuid,
                             subCollection: "contactBirthday",
                             subDocument: contact.identifier,
                             data: contactBirthday)
        }
    }
}
