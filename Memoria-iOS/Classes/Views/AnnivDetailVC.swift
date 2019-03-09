//
//  AnnivDetailVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/09.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

final class AnnivDetailVC: UIViewController {

    // MARK: - Enum
    
    enum Section: Int {
        case topSection
        case giftSection
    }
    
    // MARK: - Property
    
    @IBOutlet weak var tableView: UITableView!
    
    /// AnnivVCから受け取るデータ
    var anniv: [String: Any]!
    
    var category: AnnivType?
    
    var gifts: [[String: Any]]?
    var selectedGiftId: String?

    /// Firestoreのコレクションを監視するリスナー登録
    var listenerRegistration: ListenerRegistration?

    // 次の画面に渡す用の記念日データを持っておく
    var annivModel: AnnivModel?

    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 大きいタイトルの表示設定
        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // リスナー登録
        registerListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // リスナーを破棄
        listenerRegistration?.remove()
    }

    /// 記念日データ変更監視用リスナー登録
    private func registerListener() {
        let filteredCollection = AnnivDAO.getQuery(whereField: "id", equalTo: anniv["id"] as! String)
        // anniversaryコレクションの変更を監視するリスナー登録
        listenerRegistration = filteredCollection?.addSnapshotListener { snapshot, error in
            print("AnniversaryDetailVCでリスナー登録")
            guard let anniversary = snapshot?.documents.first?.data() else {
                print("ドキュメント取得エラー: \(error!)")
                return
            }
            // 編集画面に渡す用のデータをセット
            self.annivModel = AnnivModel(dictionary: anniversary)
            // 記念日データから日付を取り出す
            if let date = (anniversary["date"] as? Timestamp)?.dateValue() {
                let remainingDays = DateDifferenceCalculator.getDifference(from: date, isAnnualy: anniversary["isAnnualy"] as? Bool ?? true)
                self.navigationItem.title = AnnivUtil.getRemainingDaysString(from: remainingDays)
            }
            // テーブルのデータ更新のために渡す
            self.anniv = anniversary
            
            guard let category = anniversary["category"] as? String else { return }
            self.category = AnnivType(category: category)
            
            switch self.category! {
            case .anniv:
                self.searchGift(with: anniversary["title"] as! String)
                
            case .birthday:
                let fullName = String(format: "fullName".localized,
                                      arguments: [anniversary["familyName"] as! String,
                                                  anniversary["givenName"] as! String])
                self.searchGift(with: fullName)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
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
            let nextVC = navC.topViewController as! AnnivEditVC
            nextVC.annivModel = annivModel
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
    
    // 該当するギフトを検索する
    func searchGift(with searchKey: String) {
        
        guard let category = category else { return }
        
        let whereField: String
        
        switch category {
        case .anniv:
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

extension AnnivDetailVC: UITableViewDataSource, UITableViewDelegate {
    /// セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return gifts == nil ? 1 : 2
    }
    
    /// セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .topSection:
            if let category = category {
                return category == .anniv ? 1 : 3
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
        
        let anniversaryDate = (anniv["date"] as! Timestamp).dateValue()
        
        switch (section, indexPath.row) {
        case (.topSection, 0):
            cell = tableView.dequeueReusableCell(withIdentifier: "topCell", for: indexPath)
            // 記念日のアイコン
            let imageView = cell.viewWithTag(1) as! UIImageView
            imageView.image = AnnivUtil.getIconImage(from: anniv)
            // 記念日の名前
            let anniversaryNameLabel = cell.viewWithTag(2) as! UILabel
            anniversaryNameLabel.text = AnnivUtil.getName(from: anniv)
            // 記念日の日程
            let anniversaryDateLabel = cell.viewWithTag(3) as! UILabel
            anniversaryDateLabel.text = DateTimeFormat.getYMDString(date: anniversaryDate)
            
        case (.giftSection, _):
            cell = tableView.dequeueReusableCell(withIdentifier: "giftCell", for: indexPath)
            
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "annivDetailCell", for: indexPath)
        }
        
        if let category = category {
            
            switch (category, section, indexPath.row) {
            case (.birthday, .topSection, 1):
                cell.textLabel?.text = "zodiacStarSign".localized
                cell.detailTextLabel?.text = ZodiacSign.Star.getStarSign(date: anniversaryDate)
                
            case (.birthday, .topSection, 2):
                cell.textLabel?.text = "chineseZodiacSign".localized
                cell.detailTextLabel?.text = ZodiacSign.Chinese.getChineseZodiacSign(date: anniversaryDate)
                
            case (.birthday, .giftSection, _):
                let anniversaryLabel = cell.viewWithTag(2) as! UILabel
                let goodsLabel = cell.viewWithTag(3) as! UILabel
                let gotOrReceivedLabel = cell.viewWithTag(4) as! TagLabel

                let isReceived = gifts?[indexPath.row]["isReceived"] as! Bool
                
                anniversaryLabel.text = gifts?[indexPath.row]["anniversaryName"] as? String
                goodsLabel.text = gifts?[indexPath.row]["goods"] as? String
                gotOrReceivedLabel.text = isReceived ? "gotGift".localized : "gaveGift".localized
                gotOrReceivedLabel.backgroundColor = isReceived ? #colorLiteral(red: 1, green: 0.6629999876, blue: 0.07800000161, alpha: 1) : #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                
            case (.anniv, .giftSection, _):
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
        case (.topSection, _):
            if let memo = annivModel?.memo, memo != "" {
                return "memo:".localized + memo
            }
            return nil
        case (.giftSection, .anniv): return "giftSectionFooterForAnniversary".localized
        case (.giftSection, .birthday): return "giftSectionFooterForBirthday".localized
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
