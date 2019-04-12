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

class SettingVC: UITableViewController, EventTrackable {

    /// TableViewのセル。rowValueはtag番号を示す
    enum SelectableCell: Int {
        case importBirthday = 12
        case deleteBirthday
        case reviewThisApp = 21
        case developer
        case supoort
    }
    
    @IBOutlet weak var accountStateLabel: UILabel!
    @IBOutlet weak var versionAndBuildLabel: UILabel!
    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "settings".localized
        clearsSelectionOnViewWillAppear = false
        versionAndBuildLabel.text = "\(AppInfo.getVersion() ?? "")(\(AppInfo.getBuild() ?? ""))"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreen()
        
        guard let user = Auth.auth().currentUser else { return }
        accountStateLabel.text = user.displayName  // ユーザー名を表示
    }
    
    
    // MARK: - Private method
    
    /// Delete imported birthday
    private func deleteContactBirthday() {
        DialogBox.showDestructiveAlert(on: self,
                                       title: "deleteContactBirthdayTitle".localized,
                                       message: "deleteContactBirthdayMessage".localized,
                                       destructiveTitle: "delete".localized,
                                       destructiveAction: {
                                        AnnivDAO.deleteByQuery(with: "isFromContact", isEqualTo: true, on: self)
        })
    }
    
    /// Import birthday by Contacts
    private func importBirthday() {
        DialogBox.showAlert(on: self,
                            hasCancel: true,
                            title: "importBirthdayTitle".localized,
                            message: "importBirthdayMessage".localized) {
            ContactAccess().checkStatusAndImport(rootVC: self)
        }
    }
    
    
    // MARK: - Table view data source

    /// セルが選択された時
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルの選択解除
        tableView.deselectRow(at: indexPath, animated: true)
        
        //選択されたセルのtagからセルのケースを当てはめる
        guard let cell = tableView.cellForRow(at: indexPath),
            let selectedCell = SelectableCell.init(rawValue: cell.tag) else { return }
        // セルによって処理を振り分け
        switch selectedCell {
        case .importBirthday: importBirthday()
        case .deleteBirthday: deleteContactBirthday()
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
        case 0: return "aboutAccount".localized
        case 1: return "aboutAnniversary".localized
        case 2: return "aboutMemoria".localized
        default: return nil
        }
    }
    
    /// セクションのフッタータイトル
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0, 1: return nil
        case 2: return "copyright".localized
        default: return nil
        }

    }
}
