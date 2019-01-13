//
//  AnniversaryDataModel.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/24.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import Foundation
import Firebase

// MARK: - Enum
enum AnniversaryType: Int, CustomStringConvertible {
    case anniversary
    case birthday
    
    init(category: String) {
        switch category{
        case "anniversary":
            self = .anniversary
            
        case "contactBirthday",
             "manualBirthday": fallthrough
        default:
            // Ver.2.0.0 まではカテゴリーを文字列で管理しており、誕生日を2種類に分けていたが
            // 今後は誕生日とそれ以外の記念日の列挙型とし、連絡先からかどうかはisFromContactにて判断することにした
            self = .birthday
        }
    }
    
    var description: String {
        switch self {
        case .anniversary: return "anniversary"
        case .birthday: return "birthday"
        }
    }
}

/// 記念日データのモデル
struct AnniversaryDataModel {
    let id: String
    let category: AnniversaryType
    let title: String?
    let familyName: String?
    let givenName: String?
    let date: Timestamp
    let iconImage: Data?
    let isHidden: Bool
    // Added Ver.2.1.0
    let isAnnualy: Bool
    let isFromContact: Bool
    
    /// FirestoreがSwiftのカスタムオブジェクトに非対応なので辞書型に変換する必要がある
    var toDictionary: [String: Any] {
        
        var dictionary = [String: Any]()
        dictionary["id"] = id
        dictionary["category"] = category.description
        dictionary["title"] = title
        dictionary["familyName"] = familyName
        dictionary["givenName"] = givenName
        dictionary["date"] = date
        dictionary["isAnnualy"] = isAnnualy
        dictionary["iconImage"] = iconImage
        dictionary["isHidden"] = isHidden
        dictionary["isFromContact"] = isFromContact

        return dictionary
    }
}

extension AnniversaryDataModel {
    
    // 辞書型データからデータモデルを作る
    init?(dictionary: [String: Any]) {
        guard let category = dictionary["category"] as? String else { return nil }
        
        self.id = dictionary["id"] as! String
        self.category = AnniversaryType(category: category)
        self.title = dictionary["title"] as? String
        self.familyName = dictionary["familyName"] as? String
        self.givenName = dictionary["givenName"] as? String
        self.date = dictionary["date"] as! Timestamp
        self.iconImage = dictionary["iconImage"] as? Data
        self.isHidden = dictionary["isHidden"] as! Bool
        // 以下プロパティは、Ver.2.1.0 にて追加。nilの可能性があるためデフォルト値対応を行う
        self.isAnnualy = (dictionary["isAnnualy"] != nil) ? dictionary["isAnnualy"] as! Bool : true
        if let isFromContact = dictionary["isFromContact"] as? Bool {
            self.isFromContact = isFromContact
        } else {
            self.isFromContact = category == "contactBirthday"
        }
    }
}

