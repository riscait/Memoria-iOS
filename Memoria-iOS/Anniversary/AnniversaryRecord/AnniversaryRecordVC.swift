//
//  AnniversaryRecordVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/19.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

class AnniversaryRecordVC: UIViewController {

    @IBOutlet weak var familyName: UITextField!
    @IBOutlet weak var givenName: UITextField!
    @IBOutlet weak var anniversaryTitle: UITextField!
    
    enum SegueId {
        case birthday
        case anniversary
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    // MARK: - Navigation

    /// 画面遷移直前に呼ばれる
    ///
    /// - Parameters:
    ///   - segue: Segue
    ///   - sender: sender
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let id = segue.identifier else { return }
        
        let segueId = id == "toRecordBirthday" ? SegueId.birthday : SegueId.anniversary
        /// 登録用Anniversaryモデル
        let anniversary: AnniversaryRecordModel
        
        switch segueId {
        case .birthday:
            anniversary = AnniversaryRecordModel(givenName: givenName.text, familyName: familyName.text)

        case .anniversary:
            anniversary = AnniversaryRecordModel(title: anniversaryTitle.text!)
        }
        // 次のVCに記念日情報を渡す
        let nextVC = segue.destination as! AnniversaryDateRecordVC
        nextVC.anniversary = anniversary
    }
}
