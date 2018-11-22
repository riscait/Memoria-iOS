//
//  WelcomContactVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/19.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

class WelcomContactVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func didTapImportButton(_ sender: Any) {
        // 連絡先アクセス用のクラスをインスタンス化
        let contactAccess = ContactAccess()
        // 連絡先情報の使用が許可されているか調べてから誕生日をとりこむ
        contactAccess.checkStatus(rootVC: self, deniedHandler: showAlert)
//        contactAccess.importContact() {
//            print("連絡先アクセスのコールバック開始")
//            print("\($0)件データを取得")
//        }
    }
    
    /// 設定アプリへの遷移を促すダイアログをポップアップ
    private func showAlert() {
        DialogBox.showAlert(on: self, title: "設定で許可してください", message: "誕生日をとりこむためには連絡先への許可が必要です。", defaultAction: openSettingApp, hasCancel: true)
    }
    
    /// 設定アプリのプライバシーを開く
    private func openSettingApp() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    /// Segueが実行されるときの処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAnniversary" {
            // チュートリアル終了フラグを立てる
           print("Anniversary画面へ")
            UserDefaults().set(true, forKey: "isFinishedTutorial")
        }
    }
}
