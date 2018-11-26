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
    enum ZodiacStarSign: String {
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
            return NSLocalizedString(self.rawValue, comment: "")
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
                return ZodiacSign.ZodiacStarSign.aries.localizedString()
            case (4, 20...31), (5, 1...20):
                return ZodiacSign.ZodiacStarSign.taurus.localizedString()
            case (5, 21...31), (6, 1...21):
                return ZodiacSign.ZodiacStarSign.gemini.localizedString()
            case (6, 22...31), (7, 1...22):
                return ZodiacSign.ZodiacStarSign.cancer.localizedString()
            case (7, 23...31), (8, 1...22):
                return ZodiacSign.ZodiacStarSign.leo.localizedString()
            case (8, 23...31), (9, 1...22):
                return ZodiacSign.ZodiacStarSign.virgo.localizedString()
            case (9, 23...31), (10, 1...23):
                return ZodiacSign.ZodiacStarSign.libra.localizedString()
            case (10, 24...31), (11, 1...22):
                return ZodiacSign.ZodiacStarSign.scorpio.localizedString()
            case (11, 23...31), (12, 1...21):
                return ZodiacSign.ZodiacStarSign.sagittarius.localizedString()
            case (12, 22...31), (1, 1...19):
                return ZodiacSign.ZodiacStarSign.capricorn.localizedString()
            case (1, 20...31), (2, 1...18):
                return ZodiacSign.ZodiacStarSign.aquarius.localizedString()
            case (2, 19...31), (3, 1...20):
                return ZodiacSign.ZodiacStarSign.pisces.localizedString()
            default:
                return NSLocalizedString("unknown", comment: "")
            }
        }
    }
    
    /// 十二支（干支）
    enum ChineseZodiacSign: String {
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
            print(signString)
            return NSLocalizedString(signString, comment: "")
        }
        
        /// 干支を調べる
        ///
        /// - Parameter date: 干支を調べたい日付
        /// - Returns: 十二支名
        static func getChineseZodiacSign(date: Date) -> String {
            
            // 日付の「年」を取得。1年なら「不明」
            guard let year = Calendar.current.dateComponents([.year], from: date).year, year != 1 else {
                return NSLocalizedString("unknown", comment: "")
            }
            
            switch year % 12 {
            case 4:
                return ZodiacSign.ChineseZodiacSign.rat.localizedString()
            case 5:
                return ZodiacSign.ChineseZodiacSign.ox.localizedString()
            case 6:
                return ZodiacSign.ChineseZodiacSign.tiger.localizedString()
            case 7:
                return ZodiacSign.ChineseZodiacSign.rabbit.localizedString()
            case 8:
                return ZodiacSign.ChineseZodiacSign.dragon.localizedString()
            case 9:
                return ZodiacSign.ChineseZodiacSign.snake.localizedString()
            case 10:
                return ZodiacSign.ChineseZodiacSign.horse.localizedString()
            case 11:
                return ZodiacSign.ChineseZodiacSign.sheep.localizedString()
            case 0:
                return ZodiacSign.ChineseZodiacSign.monkey.localizedString()
            case 1:
                return ZodiacSign.ChineseZodiacSign.rooster.localizedString()
            case 2:
                return ZodiacSign.ChineseZodiacSign.dog.localizedString()
            case 3:
                return ZodiacSign.ChineseZodiacSign.pig.localizedString()
            default:
                return NSLocalizedString("unknown", comment: "")
            }
        }
    }
}
