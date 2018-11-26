//
//  SettingVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/23.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import SafariServices

class SettingVC: UITableViewController {

    /// TableViewのセル。rowValueはtag番号を示す
    enum SettingCell: Int {
        case importBirthday = 12
        case deleteBirthday
        case reviewThisApp = 21
        case developer
        case supoort
    }
    
    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Settings", comment: "")
        self.clearsSelectionOnViewWillAppear = false
    }

    
    // MARK: - 関数

    private func deleteContactBirthday() {
        AnniversaryDAO().deleteQueryAnniversary(whereField: "category", equalTo: "contactBirthday")
    }
    
    
    // MARK: - Table view data source

    /// セルが選択された時
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルの選択解除
        tableView.deselectRow(at: indexPath, animated: true)
        
        //選択されたセルのtagからセルのケースを当てはめる
        guard let cell = tableView.cellForRow(at: indexPath),
            let selectedCell = SettingCell.init(rawValue: cell.tag) else { return }
        // セルによって処理を振り分け
        switch selectedCell {
        case .importBirthday:
            ContactAccess().checkStatus(rootVC: self)
            
        case .deleteBirthday:
            DialogBox.showDestructiveAlert(on: self,
                                           title: NSLocalizedString("deleteContactBirthdayTitle", comment: ""),
                                           message: NSLocalizedString("deleteContactBirthdayMessage", comment: ""),
                                           destructiveTitle: NSLocalizedString("delete", comment: ""),
                                           destructiveAction: deleteContactBirthday)
            
        case .reviewThisApp:
            if let url = URL(string: "https://itunes.apple.com/app/id1444443848?action=write-review") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        case .developer:
            // SFSafariViewControllerでURLを開く
            let webView = SFSafariViewController(url: URL(string: "https://twitter.com/NercoJP")!)
            self.present(webView, animated: true, completion: nil)

        case .supoort:
            // SFSafariViewControllerでURLを開く
            let webView = SFSafariViewController(url: URL(string: "https://goo.gl/forms/lZ94LyyuyDPjyxbk2")!)
            self.present(webView, animated: true, completion: nil)
        }

    }
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
