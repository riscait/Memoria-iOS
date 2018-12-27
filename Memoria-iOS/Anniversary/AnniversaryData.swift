//
//  AnniversaryData.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/24.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import Foundation
import Firebase

struct AnniversaryData {
    let id: String
    let category: String
    let title: String
    let familyName: String
    let givenName: String
    let date: Timestamp
    let iconImage: Data
}
