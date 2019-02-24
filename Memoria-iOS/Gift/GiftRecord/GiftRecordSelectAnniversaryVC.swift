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

    // Conform to GiftRecordSelectProtocol
    var displayData = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    // TextFieldの文字列を書き換えるらためのDelegateを宣言
    weak var delegate: GiftRecordSelectAnniversaryVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.searchController = searchController
        // 検索バーを常に表示する場合はfalse。消すと引っ張って出現してスクロールで隠れるようになる
        navigationItem.hidesSearchBarWhenScrolling = false

        searchDB()
    }
}

// MARK: - Confirm GiftRecordSelectProtocol
extension GiftRecordSelectAnniversaryVC: GiftRecordSelectProtocol {
    
    func searchDB() {
        AnniversaryDAO.getFilteredAnniversaryDocuments(whereField: "isHidden", equalTo: false) { (queryDoc) in
            for doc in queryDoc {
                guard let title = doc.data()["title"] as? String else{ continue }
                self.displayData.append(title)
            }
            self.tableView.reloadData()
        }
    }
    
    func popVC() {
        let navC = navigationController!
        navC.popViewController(animated: true)
    }
}

// MARK: - Table view data source
extension GiftRecordSelectAnniversaryVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        
        cell.textLabel?.text = displayData[indexPath.row]
        return cell
    }
}

// MARK: - Table view delegate
extension GiftRecordSelectAnniversaryVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let text = tableView.cellForRow(at: indexPath)?.textLabel?.text
        print(#function, text ?? "nil")
        delegate?.updateAnniversaryName(with: text)
        
        popVC()
    }
}
