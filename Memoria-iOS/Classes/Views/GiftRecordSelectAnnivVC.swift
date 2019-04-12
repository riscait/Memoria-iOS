//
//  GiftRecordSelectAnnivVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/26.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

protocol GiftRecordSelectAnnivVCDelegate: AnyObject {
    /// TextFieldの文字列を書き換える
    func updateAnnivName(with text: String?)
}

/// gift対象記念日を選択するための詳細画面（テーブルセルをタップして遷移してくる）
class GiftRecordSelectAnnivVC: UIViewController, EventTrackable {

    // Conform to GiftRecordSelectProtocol
    var displayData = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    // TextFieldの文字列を書き換えるためのDelegateを宣言
    weak var delegate: GiftRecordSelectAnnivVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        searchDB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreen()
    }
}

// MARK: - Confirm GiftRecordSelectProtocol
extension GiftRecordSelectAnnivVC: GiftRecordSelectProtocol {
    
    func searchDB() {
        // 非表示ではない記念日を検索する
        AnnivDAO.getDocumentsAtDualFilter(first: "isHidden", equalTo: false, secondWhereField: "category", secondEqualTo: "anniversary") { (queryDoc) in
            for doc in queryDoc {
                if let title = doc.data()["title"] as? String {
                    self.displayData.append(title)
                }
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
extension GiftRecordSelectAnnivVC: UITableViewDataSource {
    
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
extension GiftRecordSelectAnnivVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let text = tableView.cellForRow(at: indexPath)?.textLabel?.text
        print(#function, text ?? "nil")
        delegate?.updateAnnivName(with: text)
        
        popVC()
    }
}
