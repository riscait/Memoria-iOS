//
//  UserAccountVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/05.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

import Firebase

class UserAccountVC: UITableViewController, EventTrackable {

    /// TableViewのセル。rowValueはtag番号を示す
    enum SelectableCell: Int {
        case signOut = 91
    }
    
    @IBOutlet weak var currentEmail: UILabel!
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("userAccountSettings", comment: "")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreen()
        
        currentEmail.text = Auth.auth().currentUser?.email
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルの選択解除
        tableView.deselectRow(at: indexPath, animated: true)
        //選択されたセルのtagからセルのケースを当てはめる
        guard let cell = tableView.cellForRow(at: indexPath),
            let selectedCell = SelectableCell.init(rawValue: cell.tag) else { return }
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
        }
    }
    
    /// セクションのヘッダータイトル
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return NSLocalizedString("updateUserAccount", comment: "")
        default: return nil
        }
    }
    
    /// セクションのフッタータイトル
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        default: return nil
        }
        
    }

    // この画面に戻ってくるUnwind Segueで使用
    @IBAction func returnToUserAccountVC(segue: UIStoryboardSegue) {}
}
