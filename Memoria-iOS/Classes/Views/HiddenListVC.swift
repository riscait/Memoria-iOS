
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
    /// リスナー登録
    var listenerRegistration: ListenerRegistration?
    
    var annivs: [[String: Any]]?
    
    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Title of this screen
        title = "hiddenList".localized
    }
    
    /// Viewが表示される直前に呼ばれる（タブ切り替え等も含む）
    override func viewWillAppear(_ animated: Bool) {
        
        // anniversaryコレクションの変更を監視する
        listenerRegistration = AnnivDAO.getQuery(whereField: "isHidden", equalTo: true)?
            .addSnapshotListener { documentSnapshot, error in
                
                guard let documentSnapshot = documentSnapshot else {
                    print("ドキュメント取得エラー: \(error!)")
                    return
                }
                self.annivs = [[String: Any]]()
                print("documents are \(documentSnapshot.documents)")
                // 記念日データが入ったドキュメントの数だけ繰り返す
                for doc in documentSnapshot.documents {
                    // ドキュメントから記念日データを取り出す
                    var data = doc.data()
                    print("data is... ", data)
                    // 記念日データをローカル配列に記憶
                    self.annivs?.append(data)
                    print("非表示の記念日: \(data["familyName"] ?? "") \(data["givenName"] ?? "")\(data["title"] ?? "")")
                }
                // 並び替えて返却する
                //            self.annivs.sort(by: {($0["remainingDays"] as! Int) < ($1["remainingDays"] as! Int)})
                
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
        
        let defaultActionSet = ["redisplay".localized: redisplayThisAnniv]
        let destructiveActionSet = ["delete".localized: deleteThisAnniv]
        // 選択されたセルの行番号
        selectedRow = indexPath.row
        // ActionSheetを表示
        DialogBox.showActionSheet(rootVC: self, title: nil, message: nil,
                                  defaultActionSet: defaultActionSet,
                                  destructiveActionSet: destructiveActionSet)
    }
    
    /// 選択したセルの記念日を削除する
    func deleteThisAnniv() {
        let documentPath = annivs?[selectedRow]["id"] as! String
        AnnivDAO.delete(with: documentPath)
    }
    /// 選択したセルの記念日を再表示する
    func redisplayThisAnniv() {
        let documentPath = annivs?[selectedRow]["id"] as! String
        AnnivDAO.update(with: documentPath, field: "isHidden", content: false)
    }

    
    // MARK: - Table view data source

    /// セクション数
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    /// 行数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return annivs?.count ?? 0
    }

    /// セルの内容
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hiddenAnniversaryCell", for: indexPath)

        let iconImageView = cell.viewWithTag(1) as! UIImageView
        let titleLabel = cell.viewWithTag(2) as! UILabel

        guard let anniversary = annivs?[indexPath.row],
            let category = anniversary["category"] as? String else { return cell }
        
        let type = AnnivType(category: category)
        
        switch type {
        case .anniv:
            titleLabel.text = anniversary["title"] as? String

        case .birthday:
            titleLabel.text = String(format: "whoseBirthday".localized,
                                     arguments: [anniversary["familyName"] as! String, anniversary["givenName"] as! String])
        }

        if let iconImage = anniversary["iconImage"] as? Data {
            iconImageView.image = UIImage(data: iconImage)
            
        } else {
            // デフォルトアイコン
            iconImageView.image = type == .birthday
                ? #imageLiteral(resourceName: "Ribbon") // 誕生日
                : #imageLiteral(resourceName: "giftBox") // それ以外
        }

        return cell
    }
    
    /// セクションごとのヘッダータイトル
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "titleForHeaderInSection".localized

        default:
            return nil
        }
    }
}
