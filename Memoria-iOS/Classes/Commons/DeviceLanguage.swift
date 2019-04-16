//
//  DeviceLanguage.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/25.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import Foundation

enum DeviceLanguage: String {
    case ja
    case en
    
    enum DateOrder {
        case ymd
        case mdy
    }
    /// 端末で設定されている言語を調べる
    ///
    /// - Returns: 端末で設定されている最優先言語
    static func getLanguage() -> DeviceLanguage {
        // 端末の最優先言語を取得
        let firstLanguage = Locale.preferredLanguages.first!
        // "-"の左側が言語を示す
        let languagePrefix = firstLanguage.components(separatedBy: "-").first!
        // 言語を示す文字列からEnumのcaseを作り返却する
        return DeviceLanguage.init(rawValue: String(languagePrefix))!
    }
    
    func getDateOrder() -> DateOrder {
        switch self {
        case .ja:
            return .ymd
        case .en:
            return .mdy
        }
    }
}
