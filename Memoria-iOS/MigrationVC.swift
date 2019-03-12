//
//  MigrationVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/03/12.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit

class MigrationVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func startMigration() {
        Migration.db(on: self) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
