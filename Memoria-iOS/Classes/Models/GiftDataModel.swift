//
//  GiftDataModel.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/31.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import Foundation
import Firebase

/// ギフトデータのモデル
struct GiftDataModel {
    let id: String
    let isReceived: Bool
    let personName: String
    let annivName: String
    let date: Timestamp?
    let goods: String
    let memo: String
    let isHidden = false
    let iconImage: Data?
    
    /// FirestoreがSwiftのカスタムオブジェクトに非対応なので辞書型に変換する必要がある
    var toDictionary: [String: Any] {
        
        var dictionary = [String: Any]()
        dictionary["id"] = id
        dictionary["isReceived"] = isReceived
        dictionary["personName"] = personName
        dictionary["anniversaryName"] = annivName
        dictionary["date"] = date ?? NSNull()
        dictionary["goods"] = goods
        dictionary["memo"] = memo
        dictionary["isHidden"] = isHidden
        dictionary["iconImage"] = iconImage ?? NSNull()
        
        return dictionary
    }
}
