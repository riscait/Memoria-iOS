//
//  TimelineVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/04/02.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit

final class TimelineVC: UIViewController, EventTrackable {

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: 未実装画面
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreen()
    }
}
