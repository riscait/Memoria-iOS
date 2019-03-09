//
//  GiftRecordSelectPersonVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/21.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

protocol GiftRecordSelectPersonVCDelegate: AnyObject {
    /// TextFieldの文字列を書き換える
    func updatePersonName(with text: String?)
}

/// gift対象者を選択するための詳細画面（テーブルセルをタップして遷移してくる）
class GiftRecordSelectPersonVC: UIViewController {
    
    // Conform to GiftRecordSelectProtocol
    var displayData = [String]()

    @IBOutlet weak var tableView: UITableView!
    // TextFieldの文字列を書き換えるらためのDelegateを宣言
    weak var delegate: GiftRecordSelectPersonVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchDB()
    }
}

// MARK: - Confirm GiftRecordSelectProtocol
extension GiftRecordSelectPersonVC: GiftRecordSelectProtocol {
    
    func searchDB() {
        AnnivDAO.getFilteredDocuments(whereField: "isHidden", equalTo: false) { (queryDoc) in
            for doc in queryDoc {
                if doc.data()["familyName"] == nil, doc.data()["givenName"] == nil { continue }
                var fullName = [String]()
                if let familyName = doc.data()["familyName"] as? String { fullName.append(familyName) }
                if let givenName = doc.data()["givenName"] as? String { fullName.append(givenName) }
                self.displayData.append(String(format: "fullName".localized, arguments: fullName))
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
extension GiftRecordSelectPersonVC: UITableViewDataSource {
    
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
extension GiftRecordSelectPersonVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let text = tableView.cellForRow(at: indexPath)?.textLabel?.text
        print(#function, text ?? "nil")
        delegate?.updatePersonName(with: text)
        
        popVC()
    }
}
