
//
//  HiddenListVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/24.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

class HiddenListVC: UITableViewController {

    @IBOutlet var hiddenTableView: UITableView!
    
    var selectedRow: Int!
    /// 正直まだよく理解していないリスナー登録？
    var listenerRegistration: ListenerRegistration?

    var anniversarys = [[String:Any]]()
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("hiddenList", comment: "")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
    }
    
    /// Viewが表示される直前に呼ばれる（タブ切り替え等も含む）
    override func viewWillAppear(_ animated: Bool) {
        
        // anniversaryコレクションの変更を監視する
        listenerRegistration = AnniversaryDAO()
            .getAnniversaryQuery(whereField: "isHidden", equalTo: true)?
            .addSnapshotListener { documentSnapshot, error in
                
                guard let documentSnapshot = documentSnapshot else {
                    print("ドキュメント取得エラー: \(error!)")
                    return
                }
                self.anniversarys = []
                // 記念日データが入ったドキュメントの数だけ繰り返す
                for doc in documentSnapshot.documents {
                    // ドキュメントから記念日データを取り出す
                    var data = doc.data()
                    // 記念日データをローカル配列に記憶
                    self.anniversarys.append(data)
                    print("非表示の記念日: \(data["familyName"] ?? "") \(data["givenName"] ?? "")")
                }
                // 並び替えて返却する
                //            self.anniversarys.sort(by: {($0["remainingDays"] as! Int) < ($1["remainingDays"] as! Int)})
                
                self.tableView.reloadData()
        }
        super.viewWillAppear(animated)
    }
    
    /// Viewが非表示になる直前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // リスナー登録を破棄する
        if let listenerRegistration = listenerRegistration {
            listenerRegistration.remove()
        }
    }

    /// セルの編集ボタンが押された
    @IBAction func didTapEditButton(_ sender: InspectableButton) {
        guard let indexPath = hiddenTableView.indexPath(for: sender.superview!.superview as! UITableViewCell) else { return }
        print("\(indexPath)の編集ボタンが押されました")
        
        let defaultActionSet = [NSLocalizedString("redisplay", comment: ""): redisplayThisAnniversary]
        let destructiveActionSet = [NSLocalizedString("delete", comment: ""): deleteThisAnniversary]
        // 選択されたセルの行番号
        selectedRow = indexPath.row
        // ActionSheetを表示
        DialogBox.showActionSheet(rootVC: self, title: nil, message: nil,
                                  defaultActionSet: defaultActionSet,
                                  destructiveActionSet: destructiveActionSet)
    }
    
    /// 選択したセルの記念日を削除する
    func deleteThisAnniversary() {
        let documentPath = anniversarys[selectedRow]["id"] as! String
        AnniversaryDAO().deleteAnniversary(documentPath: documentPath)
    }
    /// 選択したセルの記念日を再表示する
    func redisplayThisAnniversary() {
        let documentPath = anniversarys[selectedRow]["id"] as! String
        AnniversaryDAO().updateAnniversary(documentPath: documentPath, field: "isHidden", content: false)
    }

    
    // MARK: - Table view data source

    /// セクション数
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    /// 行数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return anniversarys.count
    }

    /// セルの内容
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hiddenAnniversaryCell", for: indexPath)

        let iconImageView = cell.viewWithTag(1) as! UIImageView
        let titleLabel = cell.viewWithTag(2) as! UILabel

        let anniversary = anniversarys[indexPath.row]
        
        if anniversary["category"] as! String == "contactBirthday" ||
           anniversary["category"] as! String == "manualBirthday" {
            // 誕生日の場合
            titleLabel.text = String(format: NSLocalizedString("whoseBirthday", comment: ""),
                                     arguments: [anniversary["familyName"] as! String, anniversary["givenName"] as! String])

        } else {
            // 記念日の場合
            titleLabel.text = anniversary["title"] as? String
        }

        if let iconImage = anniversary["iconImage"] as? Data {
            iconImageView.image = UIImage(data: iconImage)
            
        } else {
            // デフォルトアイコン
            iconImageView.image = anniversary["category"] as! String == "contactBirthday" ||
                anniversary["category"] as! String == "manualBirthday"
                ? #imageLiteral(resourceName: "Ribbon") // 誕生日
                : #imageLiteral(resourceName: "PresentBox") // それ以外
        }

        return cell
    }
    
    /// セクションごとのヘッダータイトル
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("titleForHeaderInSection", comment: "")

        default:
            return nil
        }
    }
}
