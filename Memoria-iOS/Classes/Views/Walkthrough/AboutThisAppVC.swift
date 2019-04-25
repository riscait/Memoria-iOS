//
//  AboutThisAppVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/04/22.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit

final class AboutThisAppVC: UIViewController, EventTrackable {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreen()
    }
}
