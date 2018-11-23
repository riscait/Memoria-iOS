//
//  AnniversaryRecordModel.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/19.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import Foundation

struct AnniversaryRecordModel {
    
    /// 記念日の種類
    ///
    /// - manualBirthday: 手動登録の誕生日
    /// - anniversary: 誕生日以外の記念日
    enum Category: String {
        case manualBirthday
        case anniversary
    }
    
    let category: Category
    var title: String?
    var givenName: String?
    var familyName: String?
    var date: Date?
    var icon: Data?

    init(givenName: String?, familyName: String?) {
        self.category = .manualBirthday
        self.givenName = givenName
        self.familyName = familyName
    }
    
    init(title: String) {
        self.category = .anniversary
        self.title = title
    }
}
