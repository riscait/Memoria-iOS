//
//  GiftDataModel.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/31.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import Foundation
import Firebase

struct GiftDataModel {
    let id: String
    let isReceived: Bool
    let personName: String
    let anniversaryName: String
    let date: Timestamp
    let goods: String
    let memo: String
    let isHidden = false
    
    var toDictionary: [String: Any] {
        var dictionary = [String: Any]()
        
        dictionary["id"] = id
        dictionary["isReceived"] = isReceived
        dictionary["personName"] = personName
        dictionary["anniversaryName"] = anniversaryName
        dictionary["date"] = date
        dictionary["goods"] = goods
        dictionary["memo"] = memo
        dictionary["isHidden"] = isHidden
        
        return dictionary
    }
    
//    func toDictionarys() -> [String: Any] {
//
//        var dictionary = [String: Any]()
//
//        dictionary["id"] = id
//        dictionary["personName"] = personName
//        dictionary["anniversaryName"] = anniversaryName
//        dictionary["date"] = date
//        dictionary["goods"] = goods
//        dictionary["memo"] = memo
//
//        return dictionary
//    }
    
//    var prev: String?
//    mutating func next() -> [String: Any]? {
//        switch prev {
//        case nil:
//            prev = "id"
//            return ["id": id]
//        case "id":
//            prev = "personName"
//            return ["": personName]
//        case "personName":
//            prev = "anniversaryName"
//            return ["anniversaryName": anniversaryName]
//        case "anniversaryName":
//            prev = "date"
//            return ["date": date]
//        case "date":
//            prev = "goods"
//            return ["goods": goods]
//        case "goods":
//            prev = "memo"
//            return ["memo": memo]
//        case "memo":
//            prev = "nil"
//            return nil
//
//        default: break
//        }
//        if count == 0 {
//            return nil
//        } else {
//            defer { count -= 1 }
//            return count
//        }
    
}

//extension GiftDataModel: Collection {
//    var startIndex: Int { return 0 }
//    var endIndex: Int { return limit }
//
//    let limit: Int
//
//    func index(after i: Int) -> Int {
//        precondition(i < endIndex, "Can't advance beyond endIndex")
//        return i + 1
//    }
//    subscript(position: Int) -> String {
//        precondition((startIndex ..< endIndex) ~= position, "Index out of bounds,")
//        let num = position + 1
//        switch num {
//
//        }
//    }
//}

//extension GiftDataModel: IteratorProtocol {
//    typealias Element = <#type#>
//
//    mutating func next() -> GiftDataModel.Element? {
//        <#code#>
//    }
//}
//extension GiftDataModel: Sequence {
//    typealias Element = <#type#>
//
//    typealias Iterator = <#type#>
//
//    func makeIterator() -> GiftDataModel.Iterator {
//        <#code#>
//    }
//}
