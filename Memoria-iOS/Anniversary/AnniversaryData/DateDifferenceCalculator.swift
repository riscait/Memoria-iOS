 
 //
//  DateDifferenceCalculator.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/01/22.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import Foundation

struct DateDifferenceCalculator {

    static let calendar = Calendar.current

    static func getDifference(from fromDate: Date, toDate: Date = Date(), isAnnualy: Bool) -> Int {
        // 日付の「月」と「日」を取得
        let monthAndDayDate = calendar.dateComponents([.month, .day], from: fromDate)
        // 当日なら0を返す
        if calendar.isDateInToday(fromDate) {
            return 0
        }
        if calendar.isDateInTomorrow(fromDate) {
            return 1
        }
        if calendar.isDateInYesterday(fromDate) {
            return -1
        }
        // 毎年繰り返す記念日
        if isAnnualy {
            // 今日以降の直近記念日を取得
            let nextDay = calendar.nextDate(after: Date(), matching: monthAndDayDate, matchingPolicy: .nextTime)
            // 次回記念日までの日数を取得
            let remainingDays = calendar.dateComponents([.day], from: Date(), to: nextDay!).day!
            return remainingDays + 1 // 時間を切り上げ
        }
        // 一度きりの記念日
        let dateDifference = calendar.dateComponents([.day], from: toDate, to: fromDate).day!
        return dateDifference
    }
}
