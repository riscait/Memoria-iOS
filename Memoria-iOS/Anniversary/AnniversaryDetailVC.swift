//
//  AnniversaryDetailVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/09.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

final class AnniversaryDetailVC: UIViewController {

    @IBOutlet weak var iconImageView: IconImageView!
    @IBOutlet weak var anniversaryNameLabel: UILabel!
    @IBOutlet weak var anniversaryDateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    /// AnniversaryVCから受け取るデータ
    var anniversaryId: String!
    var anniversaryName: String?
    var anniversaryDate: String?
    var remainingDays: String?
    var iconImage: UIImage?
    
    var category: String?
    
    var starSign: String?
    var chineseZodiacSign: String?
    
    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 大きいタイトルの表示設定
        navigationItem.largeTitleDisplayMode = .automatic
        
        // IDをもとにDBから記念日データを取得する(非同期処理のコールバックで取得)
        // 非同期なので、クロージャ外の処理よりも後に反映されることになる
        AnniversaryDAO().getAnniversaryData(on: anniversaryId) { anniversary in
            guard let date = (anniversary["date"] as? Timestamp)?.dateValue(),
                let category = anniversary["category"] as? String else { return }
            self.category = category
            self.starSign = ZodiacSign.ZodiacStarSign.getStarSign(date: date)
            self.chineseZodiacSign = ZodiacSign.ChineseZodiacSign.getChineseZodiacSign(date: date)
            
            DispatchQueue.main.async {
                self.anniversaryDateLabel.text = DateTimeFormat().getYMDString(date: date)
                self.tableView.reloadData()
            }
        }
        // navigationbarのタイトル
        navigationItem.title = remainingDays
        // 前画面のセルから引き継いだ情報を表示する
        iconImageView.image = iconImage
        anniversaryNameLabel.text = anniversaryName
        anniversaryDateLabel.text = anniversaryDate
        
        let right = UIBarButtonItem(title: NSLocalizedString("hideAnniversary", comment: ""), style: .plain, target: self, action: #selector(toggleHidden))
        
        navigationItem.rightBarButtonItem = right
    }
    
    /// 非表示にするボタン
    @objc private func toggleHidden() {
        print("非表示にします")
        DialogBox.showAlert(on: self,
                            hasCancel: true,
                            title: NSLocalizedString("hideThisAnniversaryTitle", comment: ""),
                            message: NSLocalizedString("hideThisAnniversaryMessage", comment: ""),
                            defaultAction: hideThisAnniversary)
    }
    
    /// 非表示にするボタンを承諾した時の処理
    func hideThisAnniversary() {
        // ユーザーのユニークIDを読み込む
        guard let uid = Auth.auth().currentUser?.uid else {
            print("UIDが見つかりません！")
            return
        }
        // データベースに連絡先の誕生日情報を保存する
        let database = AnniversaryDAO()
        database.setData(collection: "users",
                         document: uid,
                         subCollection: "anniversary",
                         subDocument: anniversaryId,
                         data: ["isHidden": true],
                         merge: true
        )
        // 一覧画面に戻る
        navigationController?.popViewController(animated: true)
    }
}


// MARK: - UITableViewDataSource

extension AnniversaryDetailVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // セルの数
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルの中身
        let cell = tableView.dequeueReusableCell(withIdentifier: "anniversaryDetailCell", for: indexPath)

        switch (category, indexPath.row) {
        case ("contactBirthday", 0),
             ("manualBirthday", 0):
            cell.textLabel?.text = NSLocalizedString("zodiacStarSign", comment: "")
            cell.detailTextLabel?.text = starSign

        case ("contactBirthday", 1),
             ("manualBirthday", 1):
            cell.textLabel?.text = NSLocalizedString("chineseZodiacSign", comment: "")
            cell.detailTextLabel?.text = chineseZodiacSign
            
        default: break
        }
        return cell
    }
}
