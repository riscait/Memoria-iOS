//
//  ZodiacSign.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/26.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import Foundation

struct ZodiacSign {
    /// 12星座
    enum Star: String {
        case aries
        case taurus
        case gemini
        case cancer
        case leo
        case virgo
        case libra
        case scorpio
        case sagittarius
        case capricorn
        case aquarius
        case pisces
        
        // 値をローカライズして返す
        func localizedString() -> String {
            return self.rawValue.localized
        }
        
        /// 星座を調べる
        ///
        /// - Parameter date: 星座を調べたい日付
        /// - Returns: 星座名
        static func getStarSign(date: Date) -> String {
            
            // 日付の「月」と「日」を取得
            let monthAndDayDate = Calendar.current.dateComponents([.month, .day], from: date)
            
            switch (monthAndDayDate.month!, monthAndDayDate.day!) {
            case (3, 21...31), (4, 1...19):
                return ZodiacSign.Star.aries.localizedString()
            case (4, 20...31), (5, 1...20):
                return ZodiacSign.Star.taurus.localizedString()
            case (5, 21...31), (6, 1...21):
                return ZodiacSign.Star.gemini.localizedString()
            case (6, 22...31), (7, 1...22):
                return ZodiacSign.Star.cancer.localizedString()
            case (7, 23...31), (8, 1...22):
                return ZodiacSign.Star.leo.localizedString()
            case (8, 23...31), (9, 1...22):
                return ZodiacSign.Star.virgo.localizedString()
            case (9, 23...31), (10, 1...23):
                return ZodiacSign.Star.libra.localizedString()
            case (10, 24...31), (11, 1...22):
                return ZodiacSign.Star.scorpio.localizedString()
            case (11, 23...31), (12, 1...21):
                return ZodiacSign.Star.sagittarius.localizedString()
            case (12, 22...31), (1, 1...19):
                return ZodiacSign.Star.capricorn.localizedString()
            case (1, 20...31), (2, 1...18):
                return ZodiacSign.Star.aquarius.localizedString()
            case (2, 19...31), (3, 1...20):
                return ZodiacSign.Star.pisces.localizedString()
            default:
                return "unknown".localized
            }
        }
    }
    
    /// 十二支（干支）
    enum Chinese: String {
        case rat
        case ox
        case tiger
        case rabbit
        case dragon
        case snake
        case horse
        case sheep
        case monkey
        case rooster
        case dog
        case pig
        
        // 値をローカライズして返す
        func localizedString() -> String {
            let headChar = self.rawValue.prefix(1).uppercased()
            let others = self.rawValue.suffix(self.rawValue.count - 1)
            let signString = "chineseZodiacSign\(headChar)\(others)"
            return signString.localized
        }
        
        /// 干支を調べる
        ///
        /// - Parameter date: 干支を調べたい日付
        /// - Returns: 十二支名
        static func getChineseZodiacSign(date: Date) -> String {
            
            // 日付の「年」を取得。1年なら「不明」
            guard let year = Calendar.current.dateComponents([.year], from: date).year, year != 1 else {
                return "unknown".localized
            }
            
            switch year % 12 {
            case 4:
                return ZodiacSign.Chinese.rat.localizedString()
            case 5:
                return ZodiacSign.Chinese.ox.localizedString()
            case 6:
                return ZodiacSign.Chinese.tiger.localizedString()
            case 7:
                return ZodiacSign.Chinese.rabbit.localizedString()
            case 8:
                return ZodiacSign.Chinese.dragon.localizedString()
            case 9:
                return ZodiacSign.Chinese.snake.localizedString()
            case 10:
                return ZodiacSign.Chinese.horse.localizedString()
            case 11:
                return ZodiacSign.Chinese.sheep.localizedString()
            case 0:
                return ZodiacSign.Chinese.monkey.localizedString()
            case 1:
                return ZodiacSign.Chinese.rooster.localizedString()
            case 2:
                return ZodiacSign.Chinese.dog.localizedString()
            case 3:
                return ZodiacSign.Chinese.pig.localizedString()
            default:
                return "unknown".localized
            }
        }
    }
}
