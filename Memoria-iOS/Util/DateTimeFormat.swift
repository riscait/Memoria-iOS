//
//  DateFormat.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/10/28.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

class DateTimeFormat {

    let dateFormatter = DateFormatter()
    let calendar = Calendar.current

    func getDateFormatter(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> DateFormatter {
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        
        return dateFormatter
    }
    
    /// 日付を「XX月XX日」のフォーマットにして文字列で返す
    ///
    /// - Parameter date: 日時データ
    /// - Returns: 「XX月XX日」フォーマットの文字列
    func getMonthAndDay(date: Date) -> String {
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MM月dd日"
        return dateFormatter.string(from: date)
    }
    
    /// 次回の記念日までの残り日数を計算して返す
    ///
    /// - Parameter date: 記念日
    /// - Returns: 記念日までの残り日数
    func getRemainingDays(date: Date) -> Int {
        // 記念日の「月」と「日」を取得
        let components = calendar.dateComponents([.month, .day], from: date)
        // 今日以降の直近記念日を取得
        let nextDay = calendar.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime)
        // 次回記念日までの日数を取得
        let remainingDays = calendar.dateComponents([.day], from: Date(), to: nextDay!).day!
        return remainingDays
    }
}
