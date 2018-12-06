//
//  SettingVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/23.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import SafariServices

import Firebase

class SettingVC: UITableViewController {

    /// TableViewのセル。rowValueはtag番号を示す
    enum SettingCell: Int {
        case signOut = 9
        case importBirthday = 12
        case deleteBirthday
        case reviewThisApp = 21
        case developer
        case supoort
    }
    
    @IBOutlet weak var accountStateLabel: UILabel!
    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("settings", comment: "")
        clearsSelectionOnViewWillAppear = false
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let user = Auth.auth().currentUser else { return }
        accountStateLabel.text = user.email
    }
    
    // MARK: - 関数
    /// 連絡先から取得した誕生日を削除する
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
        case .signOut:
            DialogBox.showDestructiveAlert(on: self,
                                           title: NSLocalizedString("signOutTitle", comment: ""),
                                           message: NSLocalizedString("signOutMessage", comment: ""),
                                           destructiveTitle: NSLocalizedString("signOutButton", comment: "")) {
                // [START signout]
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                    print("Sign outに成功")
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
            }

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
            let webView = SFSafariViewController(url: URL(string: "https://twitter.com/nercostudio")!)
            self.present(webView, animated: true, completion: nil)

        case .supoort:
            // SFSafariViewControllerでURLを開く
            let webView = SFSafariViewController(url: URL(string: "https://goo.gl/forms/gs08T184CC3TT5lz1")!)
            self.present(webView, animated: true, completion: nil)
        }
    }
    
    /// セクションのヘッダータイトル
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return NSLocalizedString("aboutAccount", comment: "")
        case 1: return NSLocalizedString("aboutAnniversary", comment: "")
        case 2: return NSLocalizedString("aboutMemoria", comment: "")
        default: return nil
        }
    }
    
    /// セクションのフッタータイトル
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0, 1: return nil
        case 2: return NSLocalizedString("copyright", comment: "")
        default: return nil
        }

    }
}
