//
//  DateFormat.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/10/28.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

struct DateTimeFormat {

    // MARK: - プロパティ
    
    static let dateFormatter = DateFormatter()
    static let calendar = Calendar.current

    
    // MARK: - 関数
    
    /// 日付の好きな部分の数字を返す
    ///
    /// - Parameters:
    ///   - component: 部位の指定（年や月や日などなど）
    ///   - date: 日付（デフォルト値は現在）
    /// - Returns: 指定日付の指定部位を数字で返す
    static func getDateComponent(_ component: Calendar.Component, date: Date = Date()) -> Int {
        return calendar.component(component, from: date)
    }
    
    /// 日付を月日のフォーマットにして文字列で返す
    ///
    /// - Parameter date: 日時データ
    /// - Returns: 「M月d日」フォーマットの文字列
    static func getMonthDayString(date: Date) -> String {
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMd", options: 0, locale: Locale.current)
        return dateFormatter.string(from: date)
    }
    
    /// 日付を各国の年月日のフォーマットにして文字列で返す。年がない場合は月日を返す
    ///
    /// - Parameter date: 日時データ
    /// - Returns: 年月日の順番は国によって違う
    static func getYMDString(date: Date = Date()) -> String {
        // 「年」情報を持っているか否か（1年は年情報がない、ということになる）
        let hasYear = calendar.dateComponents([.year], from: date).year! != 1 ? true : false
        if hasYear {
            dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMMd", options: 0, locale: Locale.current)
            return dateFormatter.string(from: date)
        } else {
            // 「年」情報がなければ月と日だけのフォーマットを返す
            return getMonthDayString(date: date)
        }
    }

    /// (年)月日それぞれを数字で受け取り、日付に変換する
    static func toDateFormat(fromYear year: Int?, month: Int, day: Int) -> Date {
        return calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }
}
