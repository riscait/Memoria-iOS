//
//  AnniversaryRecordConfirmationVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/19.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

import Firebase

class AnniversaryRecordConfirmationVC: UIViewController {

    enum CellContent: Int, CaseIterable {
        case name = 0
        case date
    }
    
    var anniversary: AnniversaryRecordModel!

    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("confirm", comment: "")
    }
    
    /// 登録確認ボタン
    @IBAction func didTapRecordButton(_ sender: PositiveButton) {
        let anniversaryId = UUID().uuidString
        // 登録するデータの辞書
        var additionalAnniversary: [String: Any] = ["id": anniversaryId,
                                              "date": anniversary.date!,
                                              "isHidden" : false,
                                              "category" : anniversary.category.rawValue
        ]
        guard let date = anniversary.date else { return }
//        var anniversary2 = AnniversaryDataModel(id: anniversaryId,
//                                                category: <#AnniversaryType#>,
//                                                title: <#String?#>,
//                                                familyName: <#String?#>,
//                                                givenName: <#String?#>,
//                                                date: Timestamp(date: date),
//                                                isAnnualy: true,
//                                                iconImage: <#Data?#>,
//                                                isHidden: <#Bool#>,
//                                                isFromContact: <#Bool#>)
        
        // 誕生日か記念日かで登録するデータ内容が変わる
        switch anniversary.category {
        case .manualBirthday:  // 誕生日の場合
            additionalAnniversary["givenName"] = anniversary.givenName
            additionalAnniversary["familyName"] = anniversary.familyName
        case .anniversary:  // 記念日の場合
            additionalAnniversary["title"] = anniversary.title
        }
        // データベースに記念日を保存する
        AnniversaryDAO.set(documentPath: anniversaryId, data: additionalAnniversary)
        print("登録しました: \(additionalAnniversary)")
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - UITableViewDataSource

extension AnniversaryRecordConfirmationVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CellContent.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "confirmationCell", for: indexPath)
        
        switch (indexPath.row, anniversary.category) {
        // 誕生日の名前
        case (CellContent.name.rawValue, .manualBirthday):
            cell.textLabel?.text = NSLocalizedString("birthdayNameLabel", comment: "")

            if let familyName = anniversary.familyName {
                if let givenName = anniversary.givenName {
                    cell.detailTextLabel?.text = DeviceLanguage.getLanguage() == .ja
                        ? familyName + " " + givenName  // 日本語なら姓名の順
                        : givenName + " " + familyName  // 日本語以外の場合
                } else {
                    cell.detailTextLabel?.text = familyName
                }
            } else {
                cell.detailTextLabel?.text = anniversary.givenName!
            }

        // 記念日の名前
        case (CellContent.name.rawValue, .anniversary):
            cell.textLabel?.text = NSLocalizedString("anniversaryNameLabel", comment: "")
            cell.detailTextLabel?.text = anniversary.title!

        // 日付
        case (CellContent.date.rawValue, _):
            cell.textLabel?.text = NSLocalizedString("anniversarydateLabel", comment: "")
            cell.detailTextLabel?.text = DateTimeFormat.getYMDString(date: anniversary.date!)
            
        default: break
        }
        return cell
    }
}


// MARK: - UITableViewDelegate

extension AnniversaryRecordConfirmationVC: UITableViewDelegate {
    
}
