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
    
    /// 日付を「X月X日」のフォーマットにして文字列で返す
    ///
    /// - Parameter date: 日時データ
    /// - Returns: 「M月dd日」フォーマットの文字列
    func getMonthAndDay(date: Date) -> String {
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMdd", options: 0, locale: Locale.current)
        return dateFormatter.string(from: date)
    }
    
    /// 次回の記念日までの残り日数を計算して返す
    ///
    /// - Parameter date: 記念日
    /// - Returns: 記念日までの残り日数
    func getRemainingDays(date: Date) -> Int {
        // 日付の「月」と「日」を取得
        let monthAndDayDate = calendar.dateComponents([.month, .day], from: date)
        // 当日なら0を返す
        if calendar.date(Date(), matchesComponents: monthAndDayDate) {
            return 0
        }
        // 今日以降の直近記念日を取得
        let nextDay = calendar.nextDate(after: Date(), matching: monthAndDayDate, matchingPolicy: .nextTime)
        // 次回記念日までの日数を取得
        let remainingDays = calendar.dateComponents([.day], from: Date(), to: nextDay!).day!
        return remainingDays + 1 // 時間を切り上げ
    }
}
