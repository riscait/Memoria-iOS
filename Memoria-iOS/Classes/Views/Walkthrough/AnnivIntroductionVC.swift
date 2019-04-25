//
//  AnnivIntroductionVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/04/22.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit

final class AnnivIntroductionVC: UIViewController, EventTrackable {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreen()
    }

    @IBAction private func didTapAddBirthdayButton(_ sender: UIButton) {
        // 連絡先アクセス用のクラスをインスタンス化
        let contactAccess = ContactAccess()
        // 連絡先情報の使用が許可されているか調べてから誕生日をとりこむ
        contactAccess.checkStatusAndImport(rootVC: self) {
            self.trackEvent(eventName: "Imported birthdays from Contact")
            Log.info("誕生日がインポートされました")
        }
    }
}
