//
//  WelcomContactVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/19.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

class WelcomContactVC: UIViewController, EventTrackable {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreen()
    }
    
    @IBAction func didTapImportButton(_ sender: Any) {
        // 連絡先アクセス用のクラスをインスタンス化
        let contactAccess = ContactAccess()
        // 連絡先情報の使用が許可されているか調べてから誕生日をとりこむ
        contactAccess.checkStatusAndImport(rootVC: self) {
            // チュートリアル終了フラグを立てる
            UserDefaults.standard.set(true, forKey: "isFinishedTutorial")
            self.dismiss(animated: true, completion: nil)
            print("Anniversary画面へ")
        }
    }
    
    /// Segueが実行されるときの処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // チュートリアル終了フラグを立てる
        UserDefaults.standard.set(true, forKey: "isFinishedTutorial")
        print("Anniversary画面へ")
    }
}
