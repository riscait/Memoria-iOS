//
//  AnniversaryRecordConfirmationVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/19.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

class AnniversaryRecordConfirmationVC: UIViewController {

    enum CellContent: Int, CaseIterable {
        case name = 0
        case date
    }
    
    var anniversary: AnniversaryRecord!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension AnniversaryRecordConfirmationVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CellContent.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "confirmationCell", for: indexPath)
        
        switch (indexPath.row, anniversary.type) {
        // 誕生日の名前
        case (CellContent.name.rawValue, .manualBirthday):
            cell.textLabel?.text = "名前"

            if let familyName = anniversary.familyName {
                if let givenName = anniversary.givenName {
                    cell.detailTextLabel?.text = familyName + " " + givenName
                } else {
                    cell.detailTextLabel?.text = familyName
                }
            } else {
                cell.detailTextLabel?.text = anniversary.givenName!
            }

        // 記念日の名前
        case (CellContent.name.rawValue, .anniversary):
            cell.textLabel?.text = "記念日の名前"
            cell.detailTextLabel?.text = anniversary.title!

        // 日付
        case (CellContent.date.rawValue, _):
            cell.textLabel?.text = "日付"
            cell.detailTextLabel?.text = DateTimeFormat().getYMDString(date: anniversary.date!)
            
        default: break
        }
        return cell
    }
}

extension AnniversaryRecordConfirmationVC: UITableViewDelegate {
    
}
