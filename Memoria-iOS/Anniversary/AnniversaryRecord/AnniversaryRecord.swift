//
//  AnniversaryRecord.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/19.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import Foundation

struct AnniversaryRecord {
    let type: String
    var title: String?
    var givenName: String?
    var familyName: String?
    var date: Date?
    var icon: Data?

    init(givenName: String, familyName: String) {
        self.type = "manualBirthday"
        self.givenName = givenName
        self.familyName = familyName
    }
    
    init(title: String) {
        self.type = "anniversary"
        self.title = title
    }
}
