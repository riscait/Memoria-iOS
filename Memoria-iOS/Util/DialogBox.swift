//
//  Alert.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/10/28.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

class DialogBox: UIAlertController {

    /// ActionSheetを生成して呼び出し元で表示する
    ///
    /// - Parameters:
    ///   - rootVC: 呼び出し元のViewController
    ///   - title: ActionSheetのタイトル文字列
    ///   - message: ActionSheetの
    ///   - defaultAction: デフォルトActionを選択した時の実行処理
    class func showActionSheet(rootVC: UIViewController, title: String, message: String, defaultTitle: String, defaultAction: @escaping () -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: defaultTitle, style: .default, handler: { action -> Void in
            defaultAction()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        
        rootVC.present(alert, animated: true, completion: nil)
    }
}
