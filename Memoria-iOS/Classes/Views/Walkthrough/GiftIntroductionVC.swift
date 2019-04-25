//
//  GiftIntroductionVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/04/22.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit

final class GiftIntroductionVC: UIViewController, EventTrackable {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreen()
    }

    @IBAction private func didTapStartButton(_ sender: UIButton) {
        // チュートリアル終了フラグを立てる
        UserDefaults.standard.set(true, forKey: "isFinishedTutorial")
        dismiss(animated: true, completion: nil)
    }
}
