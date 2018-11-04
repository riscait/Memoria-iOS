//
//  AnniversaryViewController.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/10/27.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

/// 記念日一覧を表示するメイン画面のクラス
class AnniversaryViewController: UICollectionViewController {
    
    // MARK: - プロパティ
    
    /// データ永続化（端末保存）のためのUserDefaults
    let userDefaults = UserDefaults.standard
    /// Firestoreのドキュメントスナップショット
    var documentSnapshot = Array<DocumentSnapshot>()
    /// 正直まだよく理解していないリスナー登録？
    var listenerRegistration: ListenerRegistration?
    /// ユーザー一意のID
    var uuid: String?
    /// データ配列
    var anniversaryData: [[String: Any]]?
    
    // 引っ張って更新用のRefreshControl
    var refresher = UIRefreshControl()
    
    
    // MARK: - ライフサイクルメソッド
    
    /// Viewの読込完了後に一度だけ呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        // コレクションビューにRefreshControlを設定
        collectionView.refreshControl = refresher
        // リフレッシュ実行時に呼び出すメソッドを指定
        refresher.addTarget(self, action: #selector(refreshCollectionView), for: .valueChanged)
        
        // CollectionViewのレイアウト設定
        setLayout(margin: 6.0)
        // ユーザーデフォルトからUUIDを読み込む
        uuid = userDefaults.string(forKey: "uuid")
    }
    
    /// Viewが表示される直前に呼ばれる（タブ切り替え等も含む）
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let uuid = uuid else { return }
        let usersCollection = Firestore.firestore().collection("users")
        let anniversaryCollection = usersCollection.document(uuid).collection("contactBirthday")
        // コレクションにリスナーを登録してDBの変化を取得する
        listenerRegistration = anniversaryCollection.addSnapshotListener { snapshot, error in
            if let snapshot = snapshot {
                self.documentSnapshot = snapshot.documents
                self.collectionView.reloadData()
            }
        }
    }
    
    /// Viewが非表示になる直前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // リスナー登録を破棄する
        if let listenerRegistration = listenerRegistration {
            listenerRegistration.remove()
        }
    }
    
    
    // MARK: - IBAction（InterfaceBuiderとつないだActionメソッド）
    
    /// 記念日追加ボタン(+)を押した時の振る舞い
    ///
    /// - Parameter sender: UIBarButtonItem（NavigationBarの右上に配置）
    @IBAction func tapAddBtn(_ sender: UIBarButtonItem) {
        // 連絡先アクセス用のクラスをインスタンス化
        let contactAccess = ContactAccess()
        // 連絡先情報の使用が許可されているか調べる
        guard contactAccess.checkStatus() else {
            print("連絡先情報が使えません")
            return
        }
        // アクションシートをポップアップ（デフォルトアクション選択時の動作を引数で渡している）
        AlertController.showActionSheet(rootVC: self, title: "タイトルが入ります", message: "メッセージが入ります", defaultAction: contactAccess.saveContactInfo)
    }
    
    // MARK: - 汎用メソッド
    
    /// コレクションビューのレイアウト設定
    ///
    /// - Parameter margin: レイアウトの余白数値
    func setLayout(margin: CGFloat) {
        
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.itemSize = CGSize(width: view.frame.width / 2 - margin * 3, height: 100.0)
        // 列間の余白
        flowLayout.minimumInteritemSpacing = margin
        // 行間の余白
        flowLayout.minimumLineSpacing = margin
        // セクションの外側の余白
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin * 2, bottom: margin, right: margin * 2)
        self.collectionView.collectionViewLayout = flowLayout
    }
    
    /// 引っ張って更新用アクション
    @objc func refreshCollectionView() {
        print("引っ張って更新が始まります！")
        
        // 記念日データを再取得する
        //        readContactData()
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        self.refresher.endRefreshing()
    }

    
    // MARK: - UICollectionViewDataSource
    
    /// CollectionViewのセクション数
    ///
    /// - Parameter collectionView: AnniversaryViewController
    /// - Returns: セクションの数
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // セクションの数を必要であれば設定する。現段階では1つで十分
        return 1
    }
    
    /// CollectionViewのアイテム数
    ///
    /// - Parameters:
    ///   - collectionView: AnniversaryViewController
    ///   - section: セクション番号
    /// - Returns: アイテム数
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("\(documentSnapshot.count)件の記念日データがあります")
        return documentSnapshot.count
    }
    
    /// CollectionViewCellの表示設定
    ///
    /// - Parameters:
    ///   - collectionView: AnniversaryViewController
    ///   - indexPath: セル番号
    /// - Returns: CollectionViewCell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Storyboardで設定したカスタムセルIDを指定
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "anniversaryCell", for: indexPath)
        
        // Storyboardで配置したパーツ
        let anniversaryNameLabel = cell.viewWithTag(1) as! UILabel
        let anniversaryDateLabel = cell.viewWithTag(2) as! UILabel
        let remainingDaysLabel = cell.viewWithTag(3) as! UILabel
        
        // 日時フォーマットクラス
        let dtf = DateTimeFormat()
        
        guard let anniversaryData = documentSnapshot[indexPath.row].data() else {
            print("記念日データがnilです")
            return cell
        }
        // 記念日の名称。もし誕生日だったら苗字と名前を繋げて表示
        // TODO: 誕生日かそれ以外かの分岐が必要
        anniversaryNameLabel.text = (anniversaryData["familyName"] as! String) + (anniversaryData["givenName"] as! String)
        // 記念日の日程
        anniversaryDateLabel.text = dtf.getMonthAndDay(date: anniversaryData["birthday"] as! Date)
        // 記念日までの残り日数を計算し、追加する
        let remainingDays = dtf.getRemainingDays(date: anniversaryData["birthday"] as! Date)
        remainingDaysLabel.text = "あと\(remainingDays)日"
        // 当人のデータに残日数を追加する
//        contactDataArray[i]["remainingDays"] = remainingDays
        
        // 残り日数によってセルの見た目を変化させる
        switch remainingDays {
        case 0...100:
            // 文字色
            anniversaryNameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            anniversaryDateLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            remainingDaysLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            // 背景色
            let startColor = #colorLiteral(red: 0.8235294118, green: 0.0862745098, blue: 0.3921568627, alpha: 1).cgColor
            let endColor = #colorLiteral(red: 0.5529411765, green: 0.2235294118, blue: 1, alpha: 1).cgColor
            let layer = CAGradientLayer()
            layer.colors = [startColor, endColor]
            layer.frame = view.bounds
            layer.startPoint = CGPoint(x: 1, y: 0)
            layer.endPoint = CGPoint(x: 0, y: 1)
            cell.layer.insertSublayer(layer, at: 0)

        default :
            cell.backgroundColor = #colorLiteral(red: 0.8249073625, green: 0.8200044036, blue: 0.8286765814, alpha: 1)
        }
        
        print("セル情報を返す: \(indexPath.row)セル目")
        return cell
    }
    
    /// データベースに登録済みの連絡先データを読み込む
    ///
    /// - Returns: 連絡先の辞書データが詰まった配列
//    func readContactData() {
//
//        let db = Firestore.firestore()
//
//        // DBからユーザー情報を取得するためにUUIDを取り出しておく
//        let userDefaults = UserDefaults.standard
//        guard let uuid = userDefaults.string(forKey: "uuid") else {
//            print("UUIDがありません")
//            return
//        }
//
//        // DBの連絡先誕生日データを検索して取得する
//        let contactBirthdayRef = db.collection("users").document(uuid).collection("contactBirthday")
//
//        contactBirthdayRef.getDocuments() { querySnapshot, error in
//            guard let querySnapshot = querySnapshot else { return }
//            // エラーチェック
//            if let error = error {
//                print("ドキュメントの検索に失敗しました: \(error)")
//            } else {
//                print("ドキュメントの検索が成功しました: \(querySnapshot.count)件：\(querySnapshot)")
//                if querySnapshot.count == 0 { return }
//                // value:連絡先データ　だけを取り出して配列にする
//                var contactDataArray: [[String: Any]] = []
//                for document in querySnapshot.documents {
//                    // key:連絡先ID, value:連絡先データ辞書　として取り出す
//                    contactDataArray.append(document.data())
//                }
//                // 残日数を計算し、追加する
//                for (i, contactDictionary) in contactDataArray.enumerated() {
//                    let dtf = DateTimeFormat()
//                    let remainingDays = dtf.getRemainingDays(date: contactDictionary["birthday"] as! Date)
//                    // 当人のデータに残日数を追加する
//                    contactDataArray[i]["remainingDays"] = remainingDays
//                }
//                print("並び替え前: \(contactDataArray)")
//                // 記念日までの残日数順で並び替えて返却する
//                self.anniversaryData = contactDataArray.sorted(by: {($0["remainingDays"] as! Int) < ($1["remainingDays"] as! Int)})
//                print("並び替え後: \(self.anniversaryData!)")
//            }
//        }
//    }
}
