//
//  Alert.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/10/28.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

class AlertController {

    func showActionSheet(title: String, message: String, defaultAction: @escaping () -> ()) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: "連絡先を読み込む", style: .default, handler: { action -> Void in
            defaultAction()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        
        return alert
    }
}
