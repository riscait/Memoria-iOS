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
class GiftRecordSelectPersonVC: UIViewController, EventTrackable {
    
    // Conform to GiftRecordSelectProtocol
    var displayData = [String]()

    @IBOutlet weak var tableView: UITableView!
    // TextFieldの文字列を書き換えるらためのDelegateを宣言
    weak var delegate: GiftRecordSelectPersonVCDelegate?
    
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
extension GiftRecordSelectPersonVC: GiftRecordSelectProtocol {
    
    func searchDB() {
        AnnivDAO.getDocumentsAtDualFilter(first: "isHidden", equalTo: false, secondWhereField: "category", secondEqualTo: "birthday") { queryDoc in
            for doc in queryDoc {
                let anniv = Anniv(dictionary: doc.data())
                var fullName = [String]()
                if let familyName = anniv?.familyName { fullName.append(familyName) }
                if let givenName = anniv?.givenName { fullName.append(givenName) }
                self.displayData.append(String(format: "fullName".localized, arguments: fullName))
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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
        delegate?.updatePersonName(with: text)
        
        popVC()
    }
}
