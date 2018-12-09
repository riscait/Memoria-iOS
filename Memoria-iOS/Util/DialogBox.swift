//
//  DialogBox.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/10/28.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

final class DialogBox: UIAlertController {

    /// デフォルトアクション一つのアラートダイアログボックスをポップアップ
    ///
    /// - Parameters:
    ///   - rootVC: 呼び出し元のViewController
    ///   - title: Alertのタイトル文字列
    ///   - message: Alertのメッセージ文字列
    ///   - defaultActionTitle: デフォルトアクションの文字列（省略で"OK"）
    ///   - defaultAction: デフォルトアクション選択時の処理
    ///   - hasCancel: キャンセルボタンをつけるかどうか
    class func showAlert(on rootVC: UIViewController,
                         hasCancel: Bool = false,
                         title: String?,
                         message: String?,
                         defaultActionTitle: String = NSLocalizedString("ok", comment: ""),
                         defaultAction: (() -> ())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: defaultActionTitle, style: .default, handler: { action -> Void in
            if let defaultAction = defaultAction {
                defaultAction()
            }
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
    
    /// メッセージとOKボタンだけのシンプルなアラート
    class func showAlert(on rootVC: UIViewController,
                         message: String,
                         defaultAction: (() -> ())? = nil) {
        showAlert(on: rootVC, title: nil, message: message, defaultAction: defaultAction)
    }
    
    /// 破壊的アクションのアラートダイアログボックスをポップアップ
    ///
    /// - Parameters:
    ///   - rootVC: 呼び出し元のViewController
    ///   - title: Alertのタイトル文字列
    ///   - message: Alertのメッセージ文字列
    ///   - destructiveTitle: アクションの文字列（省略で"OK"）
    ///   - destructiveAction: アクション選択時の処理
    class func showDestructiveAlert(on rootVC: UIViewController,
                         title: String?,
                         message: String?,
                         destructiveTitle: String,
                         destructiveAction: @escaping (() -> ())) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: destructiveTitle, style: .destructive, handler: { action -> Void in
            destructiveAction()
        })
        alert.addAction(action)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(cancelAction)
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
                               title: String?,
                               message: String?,
                               defaultActionSet: [String: () -> ()],
                               destructiveActionSet: [String: () -> ()]) {
        // アラートの生成
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        // デフォルトアクションを追加
        for (key, value) in defaultActionSet {
            alert.addAction(UIAlertAction(title: key, style: .default, handler: { action -> Void in
                value()
            }))
        }
        // 破壊的アクションを追加
        for (key, value) in destructiveActionSet {
            alert.addAction(UIAlertAction(title: key, style: .destructive, handler: { action -> Void in
                value()
            }))
        }
        // キャンセルアクションの追加
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        // アラートをポップアップ表示
        rootVC.present(alert, animated: true, completion: nil)
    }
    
    /// くるくる回るインジケーター付きアラート
    ///
    /// - Parameters:
    ///   - rootVC: 呼び出し元のViewController
    ///   - message: Alertのメッセージ文字列
    ///   - completion: 表示完了後の動作
    class func showAlertWithIndicator(on rootVC: UIViewController,
                                      message: String?,
                                      completion: (() -> ())?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.center = CGPoint(x: 25, y: 30)
        alert.view.addSubview(indicator)
        
        indicator.startAnimating()
        rootVC.present(alert, animated: true, completion: completion)
    }
    
    /// 表示中のインジケーター付きアラートのメッセージを更新する
    ///
    /// - Parameters:
    ///   - rootVC: 呼び出し元のViewController
    ///   - message: Alertのメッセージ文字列
    class func updateAlert(with message: String, on rootVC: UIViewController) {
        guard let alert = (rootVC.presentedViewController as? UIAlertController) else { return }
        alert.message = message
    }
    
    /// 表示されているインジケーター付きアラートを消す
    ///
    /// - Parameters:
    ///   - rootVC: <#rootVC description#>
    ///   - completion: <#completion description#>
    class func dismissAlertWithIndicator(on rootVC: UIViewController,
                                         completion: (() -> ())?) {

        guard let alert = (rootVC.presentedViewController as? UIAlertController) else { return }
        alert.dismiss(animated: true, completion: completion)
    }
    
    /// パスワード入力フィールド付きのアラートを表示する
    ///
    /// - Parameters:
    ///   - rootVC: 呼び出し元のViewController
    ///   - title: Alertのタイトル文字列
    ///   - message: Alertのメッセージ文字列
    ///   - placeholder: プレースホルダーの文字列
    ///   - defaultTitle: デフォルトアクションの文字列
    ///   - defaultAction: デフォルトアクション選択時の動作
    class func showPasswordInputAlert(on rootVC: UIViewController,
                                  title: String?,
                                  message: String?,
                                  placeholder: String?,
                                  defaultTitle: String = NSLocalizedString("ok", comment: ""),
                                  defaultAction: @escaping (String) -> ()) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // TextFieldを追加
        alert.addTextField { textField in
            textField.clearButtonMode = .whileEditing
            textField.returnKeyType = .done
            textField.placeholder = placeholder
            textField.isSecureTextEntry = true
            textField.textContentType = .password
        }
        
        let defaultAction = UIAlertAction(title: defaultTitle, style: .default) { action in
            if let textField = alert.textFields?[0] {
                defaultAction(textField.text ?? "")
            }
        }
        alert.addAction(defaultAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel)
        alert.addAction(cancelAction)
        // アラートをポップアップ表示
        rootVC.present(alert, animated: true, completion: nil)
    }
}
