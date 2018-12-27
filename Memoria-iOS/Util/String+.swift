//
//  String+.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/19.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
