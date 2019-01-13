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

    // MARK: - Enum
    
    enum Section: Int {
        case topSection
        case giftSection
    }
    
    // MARK: - Property
    
    @IBOutlet weak var tableView: UITableView!
    
    /// AnniversaryVCから受け取るデータ
    var anniversaryId: String!
    var anniversaryName: String?
    var anniversaryDate: String?
    var remainingDays: String?
    var iconImage: UIImage?
    
    var category: AnniversaryType?
    
    var anniversaryFullDate: String?
    var starSign: String?
    var chineseZodiacSign: String?
    
    var gifts: [[String: Any]]?
    var selectedGiftId: String?

    // 次の画面に渡すようの記念日データ
    var anniversaryData: AnniversaryDataModel?
    
    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 大きいタイトルの表示設定
        navigationItem.largeTitleDisplayMode = .automatic
        
        // IDをもとにDBから記念日データを取得する(非同期処理のコールバックで取得)
        // 非同期なので、クロージャ外の処理よりも後に反映されることになる
        AnniversaryDAO.get(by: anniversaryId) { anniversary in
            
            self.anniversaryData = AnniversaryDataModel(dictionary: anniversary)
            
            guard let date = (anniversary["date"] as? Timestamp)?.dateValue(),
                let category = anniversary["category"] as? String else { return }
            
            self.anniversaryFullDate = DateTimeFormat.getYMDString(date: date)
            self.category = AnniversaryType(category: category)
            
            switch self.category! {
            case .anniversary:
                self.searchPresent(for: anniversary["title"] as! String)
                
            case .birthday:
                self.starSign = ZodiacSign.Star.getStarSign(date: date)
                self.chineseZodiacSign = ZodiacSign.Chinese.getChineseZodiacSign(date: date)
                let fullName = String(format: "fullName".localized,
                                      arguments: [anniversary["familyName"] as! String,
                                                  anniversary["givenName"] as! String])
                self.searchPresent(for: fullName)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        // navigationbarのタイトル
        navigationItem.title = remainingDays
        
        
//        let right = UIBarButtonItem(title: "hideAnniversary".localized, style: .plain, target: self, action: #selector(toggleHidden))
//
//        navigationItem.rightBarButtonItem = right
    }
    
    
    // MARK: - Navigation
    
    /// セグエで他の画面へ遷移するときに呼ばれる
    ///
    /// - Parameters:
    ///   - segue: Segue
    ///   - sender: Any?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        
        if id == "editAnniversarySegue" {
            let navC = segue.destination as! UINavigationController
            let nextVC = navC.topViewController as! AnniversaryEditVC
            nextVC.anniversaryData = anniversaryData
        }
        
        if id == "editGiftSegue" {
            let navC = segue.destination as! UINavigationController
            let nextVC = navC.topViewController as! GiftRecordVC
            let indexPath = tableView.indexPathForSelectedRow
            nextVC.selectedGiftId = gifts?[indexPath!.row]["id"] as? String
            print(nextVC.selectedGiftId ?? "selectedGiftId = nil")
        }
    }

    
    // MARK: - Misc method
    
    // 該当するプレゼントを検索する
    func searchPresent(for searchKey: String) {
        
        guard let category = category else { return }
        
        let whereField: String
        
        switch category {
        case .anniversary:
            whereField = "anniversaryName"

        case .birthday:
            whereField = "personName"
        }
        
        GiftDAO.getQuery(whereField: whereField, equalTo: searchKey)?
        .getDocuments { (querySnapshot, error) in
            if let error = error {
                print(error)
                return
            }
            guard let documents = querySnapshot?.documents else { return }
            self.gifts = [[String: Any]]()
            for document in documents {
                print(document.data())
                self.gifts?.append(["id": document.data()["id"] as! String,
                                    "personName": document.data()["personName"] as! String,
                                    "goods": document.data()["goods"] as! String,
                                    "anniversaryName": document.data()["anniversaryName"] as! String,
                                    "isReceived": document.data()["isReceived"] as! Bool])
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}


// MARK: - UITableView DataSource and Delegate

extension AnniversaryDetailVC: UITableViewDataSource, UITableViewDelegate {
    /// セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return gifts == nil ? 1 : 2
    }
    
    /// セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("プレゼントの個数: ", gifts?.count ?? "プレゼントはありません")
        
        switch Section(rawValue: section)! {
        case .topSection:
            if let category = category {
                return category == .anniversary ? 1 : 3
            } else {
                return 1
            }
            
        case .giftSection:
            return gifts?.count ?? 0
        }
    }
    
    /// セルの中身
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell
        
        let section = Section(rawValue: indexPath.section)!
        
        switch (section, indexPath.row) {
        case (.topSection, 0):
            cell = tableView.dequeueReusableCell(withIdentifier: "topCell", for: indexPath)
            
            let imageView = cell.viewWithTag(1) as! UIImageView
            imageView.image = iconImage
            
            let anniversaryNameLabel = cell.viewWithTag(2) as! UILabel
            anniversaryNameLabel.text = anniversaryName
            
            let anniversaryDateLabel = cell.viewWithTag(3) as! UILabel
            anniversaryDateLabel.text = anniversaryFullDate ?? anniversaryDate
            
        case (.giftSection, _):
            cell = tableView.dequeueReusableCell(withIdentifier: "giftCell", for: indexPath)
            
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "anniversaryDetailCell", for: indexPath)
        }
        
        if let category = category {
            
            switch (category, section, indexPath.row) {
            case (.birthday, .topSection, 1):
                cell.textLabel?.text = "zodiacStarSign".localized
                cell.detailTextLabel?.text = starSign
                
            case (.birthday, .topSection, 2):
                cell.textLabel?.text = "chineseZodiacSign".localized
                cell.detailTextLabel?.text = chineseZodiacSign
                
            case (.birthday, .giftSection, _):
                let anniversaryLabel = cell.viewWithTag(2) as! UILabel
                let goodsLabel = cell.viewWithTag(3) as! UILabel
                let gotOrReceivedLabel = cell.viewWithTag(4) as! TagLabel

                let isReceived = gifts?[indexPath.row]["isReceived"] as! Bool
                
                anniversaryLabel.text = gifts?[indexPath.row]["anniversaryName"] as? String
                goodsLabel.text = gifts?[indexPath.row]["goods"] as? String
                gotOrReceivedLabel.text = isReceived ? "gotGift".localized : "gaveGift".localized
                gotOrReceivedLabel.backgroundColor = isReceived ? #colorLiteral(red: 1, green: 0.6629999876, blue: 0.07800000161, alpha: 1) : #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                
            case (.anniversary, .giftSection, _):
                let personNameLabel = cell.viewWithTag(2) as! UILabel
                let goodsLabel = cell.viewWithTag(3) as! UILabel
                let gotOrReceivedLabel = cell.viewWithTag(4) as! TagLabel
                
                let isReceived = gifts?[indexPath.row]["isReceived"] as! Bool
                
                personNameLabel.text = gifts?[indexPath.row]["personName"] as? String
                goodsLabel.text = gifts?[indexPath.row]["goods"] as? String
                gotOrReceivedLabel.text = isReceived ? "gotGift".localized : "gaveGift".localized
                gotOrReceivedLabel.backgroundColor = isReceived ? #colorLiteral(red: 1, green: 0.6629999876, blue: 0.07800000161, alpha: 1) : #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)

            default: break
            }
        }
        return cell
    }
    
    /// ヘッダー
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let section = Section(rawValue: section)!
        switch section {
        case .giftSection: return "giftHistory".localized
        default: return nil
        }
    }
    
    /// フッター
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        guard let category = category else { return nil }
        
        let section = Section(rawValue: section)!
        switch (section, category) {
        case (.giftSection, .anniversary): return "giftSectionFooterForAnniversary".localized
        case (.giftSection, .birthday): return "giftSectionFooterForBirthday".localized
        default: return nil
        }
    }
    
    /// セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let section = Section(rawValue: indexPath.section)!
        switch (section, indexPath.row) {
        case (.topSection, 0): return 116
        default: return 44
        }
    }
    
    /// ヘッダーの高さ
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let section = Section(rawValue: section)!
        switch section {
        case .topSection:
            return CGFloat.leastNormalMagnitude
        default:
            return 40
        }
    }
    
    /// セルを選択した時の挙動
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
