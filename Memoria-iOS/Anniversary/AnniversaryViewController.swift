//
//  AnniversaryViewController.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/10/27.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

class AnniversaryViewController: UICollectionViewController {
    
    // MARK: Property
    var anniversaryData: [[String: Any]]?
    
    // 引っ張って更新用
    var refresher: UIRefreshControl!
    
    
    // MARK: Life-cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // 引っ張って更新用
        refresher = UIRefreshControl()
        collectionView.refreshControl = refresher
        refresher.addTarget(self, action: #selector(refreshCollectionView), for: .valueChanged)
        
        // 記念日データ取得
        readContactData()
        
        // CollectionViewのレイアウト設定
        setLayout(margin: 6.0)
    }
    
    // MARK: IBAction
    /// 記念日追加ボタン(+)を押した時の動作
    ///
    /// - Parameter sender: UIBarButtonItem（NavigationBarの右上に配置）
    @IBAction func tapAddBtn(_ sender: UIBarButtonItem) {
        // 連絡先アクセス用のクラスをインスタンス化
        let contactAccess = ContactAccess()
        
        // 連絡先情報の使用が許可されているか調べる
        guard contactAccess.checkStatus() else {
            print("連絡先情報が使えないので何もできない")
            return
        }
        
        // ダイアログボックスをポップアップ
        AlertController.showActionSheet(rootVC: self, title: "タイトルが入ります", message: "メッセージが入ります", defaultAction: contactAccess.saveContactInfo)
        
        print("CollectionViewをリロードする")
        self.collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    /// CollectionViewのセクション数を返す
    ///
    /// - Parameter collectionView: AnniversaryViewController
    /// - Returns: セクションの数
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // TODO: セクションの数を設定する
        return 1
    }
    
    /// CollectionViewのアイテム数を返す
    ///
    /// - Parameters:
    ///   - collectionView: AnniversaryViewController
    ///   - section: セクション番号
    /// - Returns: アイテム数
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // 記念日データの存在チェック
        guard let anniversaryCount = anniversaryData?.count else {
            print("記念日データがまだありません。アイテム数を1にします")
            return 1
        }
        print("記念日データ: \(anniversaryCount)件")
        return anniversaryCount
    }
    
    /// CollectionViewCellを設定する
    ///
    /// - Parameters:
    ///   - collectionView: AnniversaryViewController
    ///   - indexPath: セルNo
    /// - Returns: CollectionViewCell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Storyboardで設定したカスタムセルを指定
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "anniversaryCell", for: indexPath)
        
        // Storyboardで配置したパーツ
        let anniversaryNameLabel = cell.viewWithTag(1) as! UILabel
        let anniversaryDateLabel = cell.viewWithTag(2) as! UILabel
        let remainingDaysLabel = cell.viewWithTag(3) as! UILabel
        
        // 日時フォーマットクラス
        let dtf = DateTimeFormat()
        
        // 記念日データの存在チェック
        guard let anniversaryData = anniversaryData?[indexPath.row] else {
            print("記念日データがnilだった")
            return cell
        }
        
        // 記念日の名称
        // もし誕生日だったら苗字と名前を繋げる
        anniversaryNameLabel.text = (anniversaryData["familyName"] as! String) + (anniversaryData["givenName"] as! String)

        // 記念日の日程
        anniversaryDateLabel.text = dtf.getMonthAndDay(date: anniversaryData["birthday"] as! Date)
        
        // 記念日までの残り日数
        let remainingDays = anniversaryData["remainingDays"] as! Int
        
        remainingDaysLabel.text = "あと\(remainingDays)日"
        
        // 残り日数によってセルの見た目を変化させる
        switch remainingDays {
        case 0...100:
            // 背景色
            let startColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1).cgColor
            let endColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).cgColor
            let layer = CAGradientLayer()
            layer.colors = [startColor, endColor]
            layer.frame = view.bounds
            layer.startPoint = CGPoint(x: 1, y: 0)
            layer.endPoint = CGPoint(x: 0, y: 1)
            
            cell.layer.insertSublayer(layer, at: 0)
            
        default :
            cell.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        }
        
        print("セル情報を返す: \(indexPath.row)セル目")
        return cell
    }
    
    /// データベースに登録済みの連絡先データを読み込む
    ///
    /// - Returns: 連絡先の辞書データが詰まった配列
    func readContactData() {
        
        let db = Firestore.firestore()
        
        // DBからユーザー情報を取得するためにUUIDを取り出しておく
        let userDefaults = UserDefaults.standard
        guard let uuid = userDefaults.string(forKey: "uuid") else {
            print("UUIDがありません")
            return
        }
        
        // DBの連絡先誕生日データを検索して取得する
        let contactBirthdayRef = db.collection("users").document(uuid).collection("contactBirthday")
        
        contactBirthdayRef.getDocuments() { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            // エラーチェック
            if let error = error {
                print("ドキュメントの検索に失敗しました: \(error)")
            } else {
                print("ドキュメントの検索が成功しました: \(querySnapshot.count)件：\(querySnapshot)")
                if querySnapshot.count == 0 { return }
                // value:連絡先データ　だけを取り出して配列にする
                var contactDataArray: [[String: Any]] = []
                for document in querySnapshot.documents {
                    // key:連絡先ID, value:連絡先データ辞書　として取り出す
                    contactDataArray.append(document.data())
                }
                // 残日数を計算し、追加する
                for (i, contactDictionary) in contactDataArray.enumerated() {
                    let dtf = DateTimeFormat()
                    let remainingDays = dtf.getRemainingDays(date: contactDictionary["birthday"] as! Date)
                    // 当人のデータに残日数を追加する
                    contactDataArray[i]["remainingDays"] = remainingDays
                }
                print("並び替え前: \(contactDataArray)")
                // 記念日までの残日数順で並び替えて返却する
                self.anniversaryData = contactDataArray.sorted(by: {($0["remainingDays"] as! Int) < ($1["remainingDays"] as! Int)})
                print("並び替え後: \(self.anniversaryData!)")
            }
        }
    }
    
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
        readContactData()
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        self.refresher.endRefreshing()
    }
}
