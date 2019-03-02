//
//  AnniversaryUtil.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/03/02.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import Foundation

struct AnniversaryUtil {
    /// 記念日か誕生日かによってタイトルが違うので、ここで判断して返す
    ///
    /// - Parameter anniversary: 記念日データ
    /// - Returns: 記念日名か、人名を文字列で返却
    static func getName(from anniversary: [String : Any]) -> String? {
        // 記念日の分類
        let category = AnniversaryType(category: anniversary["category"] as! String)
        // 記念日の名称。誕生日だったら苗字と名前を繋げて表示
        switch category {
        case .anniversary:
            return anniversary["title"] as? String
            
        case .birthday:
            return String(format: "whoseBirthday".localized,
                          arguments: [anniversary["familyName"] as! String,
                                      anniversary["givenName"] as! String])
        }
    }
    
    static func getRemainingDaysString(from remainingDays: Int) -> String {
        return remainingDays >= 0
            ? String(format: "remainingDays".localized, remainingDays.description)
            : String(format: "elapsedDays".localized, (-remainingDays).description)    }
}
