//
//  GiftVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/11.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

/// Gift一覧を表示するメイン画面のクラス
class GiftVC: UITableViewController {

    // MARK: - Property

    /// 正直まだよく理解していないリスナー登録？
    var listenerRegistration: ListenerRegistration?
    var authStateListenerHandler: AuthStateDidChangeListenerHandle?

    /// Firebase Auth - User ID
    var uid: String?
    /// 表示用ギフトデータ
    var gifts: [[String: Any]] = []

    // 引っ張って更新用のRefreshControl
    var refresher = UIRefreshControl()
    
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "gift".localized
        
        /* ---------- 検索バーは未実装 ----------
         let searchController = UISearchController(searchResultsController: nil)
         navigationItem.searchController = searchController
         // 検索バーを常に表示する場合はfalse。消すと引っ張って出現してスクロールで隠れるようになる
         navigationItem.hidesSearchBarWhenScrolling = false
         */
        
        // RefreshControlを設定
        tableView.refreshControl = refresher
        // リフレッシュ実行時に呼び出すメソッドを指定
        refresher.addTarget(self, action: #selector(refreshCollectionView), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("GiftVCの\(#function)")
        // User ID
        uid = Auth.auth().currentUser?.uid
//        guard let uid = uid else { return }
        
        // giftコレクションの変更を監視するリスナー登録
        let query = GiftDAO.getQuery(whereField: "isHidden", equalTo: false)
        listenerRegistration = query?.addSnapshotListener { (querySnapShot, error) in
            guard let querySnapShot = querySnapShot else {
                print("ドキュメント取得エラー: \(error!)")
                return
            }
            print("giftCollectionリスナー登録")
            self.gifts.removeAll()
            
            //Gigtデータが入ったドキュメントの数だけ繰り返す
            for doc in querySnapShot.documents {
                // ドキュメントからデータを取り出す
                let data = doc.data()
                // 残日数も含めた記念日データをローカル配列に記憶
                self.gifts.append(data)
            }
            // 日付順に並び替えて返却する
            // 日付未定のものは100年ごとして比較する
            let future = Calendar.current.date(byAdding: .year, value: 100, to: Date())!
            self.gifts.sort(by: {(($0["date"] as? Timestamp)?.dateValue() ?? future) > (($1["date"] as? Timestamp)?.dateValue() ?? future)})
            
            self.tableView.reloadData()
        }
    }
    
    /// Viewが非表示になる直前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("GiftVCの\(#function)")
        // リスナー登録を破棄する
        if let listenerRegistration = listenerRegistration {
            listenerRegistration.remove()
            print("Giftコレクション変更リスナー破棄！")
        }
    }
    
    
    // MARK: - Navigation
    
    /// セグエで他の画面へ遷移するときに呼ばれる
    ///
    /// - Parameters:
    ///   - segue: Segue
    ///   - sender: Any?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        
        if id == "updateCellSegue" {
            let navC = segue.destination as! UINavigationController
            let nextVC = navC.topViewController as! GiftRecordVC
            let indexPath = tableView.indexPathForSelectedRow
            nextVC.selectedGiftId = gifts[indexPath!.row]["id"] as? String
            print(nextVC.selectedGiftId ?? "selectedGiftId = nil")
        }
    }

    
    // MARK: - Misc method

    /// 引っ張って更新用アクション
    @objc func refreshCollectionView() {
        print("引っ張って更新が始まります！")
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        refresher.endRefreshing()
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // セクションの数を必要であれば設定する。現段階では1つで十分
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("データ件数: \(gifts.count)件")
        // 一つもないときはガイド用Viewを表示
//        emptySetView.isHidden = annivs.count == 0
//            ? false : true
        
        return gifts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Storyboardで設定した Prototype Cell IDを指定
        let cell = tableView.dequeueReusableCell(withIdentifier: "giftCell", for: indexPath)

        let gift = gifts[indexPath.row]
        
        let personNameLabel = cell.viewWithTag(1) as! UILabel
        personNameLabel.text = gift["personName"] as? String
        
        let anniversaryNameLabel = cell.viewWithTag(6) as! UILabel
        anniversaryNameLabel.text = gift["anniversaryName"] as? String
        
        let goodsLabel = cell.viewWithTag(2) as! UILabel
        goodsLabel.text = gift["goods"] as? String
        
        let dateLabel = cell.viewWithTag(3) as! UILabel
        if let date = (gift["date"] as? Timestamp)?.dateValue() {
            dateLabel.text = DateTimeFormat.getYMDString(date: date)
        } else {
            dateLabel.text = "dateTBD".localized
        }
        
        let gotOrReceivedLabel = cell.viewWithTag(4) as! UILabel
        let isReceived = gift["isReceived"] as! Bool
        
        gotOrReceivedLabel.text = isReceived ? "gotGift".localized : "gaveGift".localized
        DispatchQueue.main.async {
            gotOrReceivedLabel.backgroundColor = isReceived ? #colorLiteral(red: 1, green: 0.6629999876, blue: 0.07800000161, alpha: 1) : #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        }
        
        let icon = cell.viewWithTag(5) as! UIImageView
        icon.image = #imageLiteral(resourceName: "giftBox")

        return cell
    }
    
    /// スワイプで削除可能になる
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // ローカル・DBのデータおよびテーブルビューの行を削除する
        // 対象のGift IDを特定する
        let giftId = gifts[indexPath.row]["id"] as! String
        // ローカルのデータ配列、DBのデータ、画面上のセル、の3つを削除
        gifts.remove(at: indexPath.row)  // Local data Array
        GiftDAO.delete(documentPath: giftId)  // DB data
        tableView.deleteRows(at: [indexPath], with: .automatic)  // Table view cell
    }
}
