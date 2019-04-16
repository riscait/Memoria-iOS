//
//  Log.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/03/20.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import Foundation

struct Log {
    // ログの出力レベル
    enum Level: String {
        case info  // 情報を出力
        case warn  // 警告。直ちに危険なわけではないが、好ましくない挙動の時に使用
        case error  // エラー発生。アプリをクラッシュさせる
    }
    
    static func info(file: String = #file, function: String = #function, line: Int = #line, _ items: Any...) {
        printToConsole(level: .info, file: file, function: function, line: line, items: items)
    }
    
    static func warn(file: String = #file, function: String = #function, line: Int = #line, _ items: Any...) {
        printToConsole(level: .warn, file: file, function: function, line: line, items: items)
    }
    
    static func error(file: String = #file, function: String = #function, line: Int = #line, _ message: String) {
        printToConsole(level: .error, file: file, function: function, line: line, items: message)
        assertionFailure(message)
    }
}

private extension Log {
    
    /// その瞬間の日時をフォーマットしていで文字列取得する
    private static var dateString: String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    /// ログの出力を行なったクラス名を特定し、文字列を取得する
    private static func className(from filePath: String) -> String {
        let fileName = filePath.components(separatedBy: "/").last
        return fileName?.components(separatedBy: ".").first ?? ""
    }
    
    /// デバッグ環境のみ、コンソールに出力する
    private static func printToConsole(level: Level, file: String, function: String, line: Int, items: Any...) {
        #if DEBUG
        print("[LOG \(level.rawValue.uppercased())]", "\(items) [\(dateString)][\(className(from: file)).\(function)Line#\(line)]")
        #endif
    }
}
