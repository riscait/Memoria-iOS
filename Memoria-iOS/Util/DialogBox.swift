//
//  DialogBox.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/10/28.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

final class DialogBox: UIAlertController {

    /// アラートダイアログボックスをポップアップ
    ///
    /// - Parameters:
    ///   - rootVC: 呼び出し元のViewController
    ///   - title: Alertのタイトル文字列
    ///   - message: Alertのメッセージ文字列
    ///   - defaultTitle: デフォルトアクションの文字列（省略で"OK"）
    ///   - defaultAction: デフォルトアクション選択時の処理
    ///   - hasCancel: キャンセルボタンをつけるかどうか
    class func showAlert(rootVC: UIViewController,
                         title: String,
                         message: String,
                         defaultTitle: String = NSLocalizedString("ok", comment: ""),
                         defaultAction: @escaping (() -> ()),
                         hasCancel: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: defaultTitle, style: .default, handler: { action -> Void in
            defaultAction()
        })
        alert.addAction(defaultAction)

        // キャンセルアクションtrueならキャンセルアクション追加
        if hasCancel {
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
            alert.addAction(cancelAction)
        }
        // アラートをポップアップ表示
        rootVC.present(alert, animated: true, completion: nil)
    }
    
    /// ActionSheetを生成して呼び出し元で表示する
    ///
    /// - Parameters:
    ///   - rootVC: 呼び出し元のViewController
    ///   - title: ActionSheetのタイトル文字列
    ///   - message: ActionSheetのメッセージ文字列
    ///   - defaultActionSet: デフォルトアクション選択時の実行処理（可変長）
    class func showActionSheet(rootVC: UIViewController,
                               title: String, message: String,
                               defaultActionSet: [String: () -> ()]) {
        // アラートの生成
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        // 可変長引数の中身の数だけデフォルトアクションを追加
        for (key, value) in defaultActionSet {
            alert.addAction(UIAlertAction(title: key, style: .default, handler: { action -> Void in
                value()
            }))
        }
        // キャンセルボアクションの追加
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        // アラートをポップアップ表示
        rootVC.present(alert, animated: true, completion: nil)
    }
}
