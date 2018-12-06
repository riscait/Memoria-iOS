//
//  UserAccountVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/05.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

import Firebase

class UserAccountVC: UITableViewController {

    /// TableViewのセル。rowValueはtag番号を示す
    enum Cell: Int {
//        case updateEmail = 11
        case updatePassword = 12
    }
    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("userAccountSettings", comment: "")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルの選択解除
        tableView.deselectRow(at: indexPath, animated: true)
        //選択されたセルのtagからセルのケースを当てはめる
        guard let cell = tableView.cellForRow(at: indexPath),
            let selectedCell = Cell.init(rawValue: cell.tag) else { return }
        // セルによって処理を振り分け
        switch selectedCell {
        case .updatePassword:
            DialogBox.showAlert(on: self,
                                hasCancel: true,
                                title: nil,
                                message: "passwordChangeConfirmationMessage") {
                                    let auth = Auth.auth()
                                    // メール送信と、そのコールバック処理
                                    auth.sendPasswordReset(withEmail: (auth.currentUser?.email)!) { error in
                                        if let error = error {
                                            print("エラー発生: \(error)")
                                            return
                                        }
                                        // パスワードリセットメールを送信したことをお知らせする
                                        DialogBox.showAlert(on: self, message: "sentPasswordReset")
                                    }
            }
        }
    }
    
    // この画面に戻ってくるUnwind Segueで使用
    @IBAction func returnToUserAccountVC(segue: UIStoryboardSegue) {}
}
