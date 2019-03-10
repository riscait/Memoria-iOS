//
//  Anniv.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/24.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import Foundation
import Firebase

// MARK: - 列挙型
/// 記念日の種類
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

/// 記念日リスト画面のSection
enum AnnivListSection: Int {
    case notFinishedAnniv
    case finishedAnniv
}

// MARK: - 構造体
/// 記念日データのモデル
struct Anniv {
    let id: String
    let category: AnnivType
    let title: String?
    let familyName: String?
    let givenName: String?
    let date: Timestamp
    let iconImage: Data?
    let isHidden: Bool
    // Added V2.1.0
    let isAnnualy: Bool
    let isFromContact: Bool
    let memo: String
    // Added v2.2.0
    var remainingDays: Int?
    
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

extension Anniv {
    // Firestoreのデータは辞書型なので、手動で「Anniv」に変換する
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
        // Added V2.1.0
        self.isAnnualy = dictionary["isAnnualy"] as! Bool
        self.isFromContact = dictionary["isFromContact"] as! Bool
        self.memo = dictionary["memo"] as! String
        // Added V2.2.0
    }
}

