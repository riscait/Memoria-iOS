//
//  GiftRecordSelectAnniversaryVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/26.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

protocol GiftRecordSelectAnniversaryVCDelegate: AnyObject {
    /// TextFieldの文字列を書き換える
    func updateAnniversaryName(with text: String?)
}

/// gift対象記念日を選択するための詳細画面（テーブルセルをタップして遷移してくる）
class GiftRecordSelectAnniversaryVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    // TextFieldの文字列を書き換えるらためのDelegateを宣言
    weak var delegate: GiftRecordSelectAnniversaryVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

// MARK: - Table view data source
