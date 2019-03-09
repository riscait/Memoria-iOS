//
//  AnnivModel.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/24.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import Foundation
import Firebase

// MARK: - Enum
enum AnnivType: Int, CustomStringConvertible {
    case anniv
    case birthday
    
    init(category: String) {
        switch category{
        case "anniversary":
            self = .anniv
            
        case "birthday":
             self = .birthday
            
        default:
            print("既定値以外の記念日タイプ:", category)
            self = .birthday
        }
    }
    
    var description: String {
        switch self {
        case .anniv: return "anniversary"
        case .birthday: return "birthday"
        }
    }
}

/// 記念日データのモデル
struct AnnivModel {
    let id: String
    let category: AnnivType
    let title: String?
    let familyName: String?
    let givenName: String?
    let date: Timestamp
    let iconImage: Data?
    let isHidden: Bool
    // Added Ver.2.1.0
    let isAnnualy: Bool
    let isFromContact: Bool
    let memo: String
    
    
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
        dictionary["memo"] = memo

        return dictionary
    }
}

extension AnnivModel {
    
    // 辞書型データからデータモデルを作る
    init?(dictionary: [String: Any]) {
        guard let category = dictionary["category"] as? String else { return nil }
        
        self.id = dictionary["id"] as! String
        self.category = AnnivType(category: category)
        self.title = dictionary["title"] as? String
        self.familyName = dictionary["familyName"] as? String
        self.givenName = dictionary["givenName"] as? String
        self.date = dictionary["date"] as! Timestamp
        self.iconImage = dictionary["iconImage"] as? Data
        self.isHidden = dictionary["isHidden"] as! Bool
        // 以下プロパティは、Ver.2.1.0 にて追加
        self.isAnnualy = dictionary["isAnnualy"] as! Bool
        self.isFromContact = dictionary["isFromContact"] as! Bool
        self.memo = dictionary["memo"] as! String
    }
}

