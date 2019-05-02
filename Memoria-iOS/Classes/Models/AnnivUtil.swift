//
//  AnnivUtil.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/03/02.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit

// MARK: - Enum
enum RemainingDays {
    case today
    case tomorrow
    case yesterday
    case near
    case distant
    case past
    
    init(_ remainingDays: Int) {
        self = {
            switch remainingDays {
            case 0:
                return .today
            case 1:
                return .tomorrow
            case -1:
                return .yesterday
            case 2...30:
                return .near
            case ...0:
                return .past
            default:
                return .distant
            }
        }()
    }
}
// MARK: - Struct AnnivUtil
struct AnnivUtil {
    
    // MARK: - Static methods
    
    /// 記念日の種類に応じた、記念日の名前（タイトル）を返す
    ///
    /// - Parameter anniv: 記念日構造体
    /// - Returns: 記念日の名前（タイトル）文字列
    static func getName(from anniv: Anniv) -> String {
        // 記念日の名称。誕生日だったら苗字と名前を繋げて表示
        switch anniv.category {
        case .anniv:
            return anniv.title ?? ""
            
        case .birthday:
            return String(format: "whoseBirthday".localized,
                          arguments: [anniv.familyName ?? "",
                                      anniv.givenName ?? ""])
        }
    }
    
    /// 記念日の種類に応じた、記念日の名前（タイトル）を返す
    ///
    /// - Parameter anniv: 記念日の辞書データ
    /// - Returns: 記念日の名前（タイトル）文字列
    static func getName(from anniv: [String : Any]) -> String {
        // 記念日の分類
        let category = AnnivType(category: anniv["category"] as! String)
        // 記念日の名称。誕生日だったら苗字と名前を繋げて表示
        switch category {
        case .anniv:
            return anniv["title"] as! String
            
        case .birthday:
            return String(format: "whoseBirthday".localized,
                          arguments: [anniv["familyName"] as! String,
                                      anniv["givenName"] as! String])
        }
    }

    /// 次回記念日までの日数を数値で返却する
    ///
    /// - Parameters:
    ///   - fromDate: 記念日の日付
    ///   - isAnnualy: 繰り返す記念日か否か
    /// - Returns: 次の記念日までの日数
    static func getRemainingDays(until annivDate: Date,
                              isAnnualy: Bool) -> Int {
        let calendar = Calendar.current
        // 時間情報をリセットした「今日」の日付情報
        let today = calendar.startOfDay(for: Date())
        // 日付の「月」と「日」を取得
        let monthAndDayDateComponents = calendar.dateComponents([.month, .day], from: annivDate)
        // 繰り返す記念日か否かは問わず、今日や昨日などにぴったり一致するか調べる
        if calendar.isDateInToday(annivDate) { return 0 }
        if calendar.isDateInTomorrow(annivDate) { return 1 }
        if calendar.isDateInYesterday(annivDate) { return -1 }
        // 比較するために時間情報は0:00でリセットする
        let fromDate = calendar.startOfDay(for: annivDate)
        // 毎年繰り返す記念日
        if isAnnualy {
            // 繰り返す記念日であれば年情報は無関係なので、月と日が一致するか調べる
            let isSameMonth = calendar.component(.month, from: fromDate) == calendar.component(.month, from: today)
            let isSameDay = calendar.component(.day, from: fromDate) == calendar.component(.day, from: today)
            
            if isSameMonth, isSameDay {
                return 0
            }
            // ここで次回の記念日年月日を調べるが、当日の場合はら来年の日付になってしまうので、上行であらかじめ当日は別途調べておく必要があった
            let nextDay = calendar.nextDate(after: today, matching: monthAndDayDateComponents, matchingPolicy: .nextTime)!
            // 次回記念日と本日を比較して、次回記念日までの日数を計算
            return calendar.dateComponents([.day], from: today, to: nextDay).day!
        }
        // 繰り返さない一度きりの記念日の場合は、素直に日数の差分を計算するだけでOK
        return calendar.dateComponents([.day], from: today, to: fromDate).day!
    }

    /// 次の記念日までの日数を文字列で取得する
    ///
    /// - Parameter remainingDays: 次回記念日までの日数
    /// - Returns: 後何日か、もしくは何日過ぎたかを文字列で返す
    static func getRemainingDaysString(from remainingDays: Int) -> String {
        switch RemainingDays(remainingDays) {
        case .today:
            return "remainingDaysToday".localized
        case .tomorrow:
            return "remainingDaysTomorrow".localized
        case .yesterday:
            return "remainingDaysYesterday".localized
        case .past:
            return String(format: "elapsedDays".localized, (-remainingDays).description)
        case .near, .distant:
            return String(format: "remainingDays".localized, remainingDays.description)
        }
    }
    
    /// 記念日のアイコン画像を返す、ない場合はデフォルト画像を返す
    static func getIconImage(from anniv: Anniv) -> UIImage {
        if let iconImageData = anniv.iconImage,
            let iconImage = UIImage(data: iconImageData) {
            return iconImage
        } else {
            // アイコンがない場合はデフォルトアイコンを使用
            return anniv.category == .birthday
                ? #imageLiteral(resourceName: "Ribbon") // 誕生日
                : #imageLiteral(resourceName: "giftBox") // それ以外
        }
    }
    static func getIconImage(from anniv: [String : Any]) -> UIImage {
        if let iconImageData = anniv["iconImage"] as? Data,
            let iconImage = UIImage(data: iconImageData) {
            return iconImage
        } else {
            // 記念日の分類
            let category = AnnivType(category: anniv["category"] as! String)
            // アイコンがない場合はデフォルトアイコンを使用
            return category == .birthday
                ? #imageLiteral(resourceName: "Ribbon") // 誕生日
                : #imageLiteral(resourceName: "giftBox") // それ以外
        }
    }
}
