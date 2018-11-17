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
final class AnniversaryViewController: UICollectionViewController {
    
    // MARK: - IBOutletプロパティ

    @IBOutlet private weak var emptySetView: UIView!

    // MARK: - プロパティ
    
    /// データ永続化（端末保存）のためのUserDefaults
    let userDefaults = UserDefaults.standard
    /// 日付フォーマットクラス
    let dtf = DateTimeFormat()
    /// 正直まだよく理解していないリスナー登録？
    var listenerRegistration: ListenerRegistration?
    /// ユーザー一意のID
    var uuid: String?
    /// データ配列
    var anniversarys: [[String: Any]] = []
    
    // 引っ張って更新用のRefreshControl
    var refresher = UIRefreshControl()
    
    
    // MARK: - ライフサイクル
    
    /// Viewの読込完了後に一度だけ呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 検索バーを追加
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        // 検索バーを常に表示する場合は記述。消すと引っ張って出現してスクロールで隠れるようになる
        navigationItem.hidesSearchBarWhenScrolling = false
        
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
        
        guard let uuid = uuid else { return }
        let usersCollection = Firestore.firestore().collection("users")
        let anniversaryCollection = usersCollection.document(uuid).collection("anniversary")
        // anniversaryコレクションの変更を監視する
        listenerRegistration = anniversaryCollection.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                print("ドキュメント取得エラー: \(error!)")
                return
            }
            self.anniversarys = []
            // 記念日データが入ったドキュメントの数だけ繰り返す
            for doc in snapshot.documents {
                // ドキュメントから記念日データを取り出す
                var data = doc.data()
                // 記念日データから日付を取り出す
                let anniversaryDate = data["date"] as! Date
                // 日付から次の記念日までの残日数を計算
                let remainingDays = self.dtf.getRemainingDays(date: anniversaryDate)
                // 記念日データに残日数を追加
                data["remainingDays"] = remainingDays
                // 残日数も含めた記念日データをローカル配列に記憶
                self.anniversarys.append(data)
                print("ローカルに追加したdata: \(data["familyName"] ?? "") \(data["givenName"] ?? "")")
            }
            // 記念日までの残日数順で並び替えて返却する
            self.anniversarys.sort(by: {($0["remainingDays"] as! Int) < ($1["remainingDays"] as! Int)})
            
            self.collectionView.reloadData()
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
    
    /// セグエで他の画面へ遷移するときに呼ばれる
    ///
    /// - Parameters:
    ///   - segue: <#segue description#>
    ///   - sender: <#sender description#>
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        
        if id == "toDetailSegue" {
            let nextVc = segue.destination as! AnniversaryDetailVC
            let indexPath = collectionView.indexPathsForSelectedItems?.first
            let cell = collectionView.cellForItem(at: indexPath!) as! AnniversaryCell
            nextVc.anniversaryId = cell.anniversaryId.text
            nextVc.anniversaryName = cell.anniversaryNameLabel.text
            nextVc.anniversaryDate = cell.anniversaryDateLabel.text
            nextVc.remainingDays = cell.remainingDaysLabel.text
            nextVc.iconImage = cell.anniversaryIconImage.image
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
        DialogBox.showActionSheet(rootVC: self,
                                  title: "タイトルが入ります",
                                  message: "メッセージが入ります",
                                  defaultActionSet: ["連絡先を読み込む": contactAccess.saveContactInfo,
                                                     "記念日を登録する": contactAccess.saveContactInfo]) // FIXME: ダミーvalue
    }
    
    
    // MARK: - 汎用メソッド
    
    /// コレクションビューのレイアウト設定
    ///
    /// - Parameter margin: レイアウトの余白数値
    func setLayout(margin: CGFloat) {
        
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.itemSize = CGSize(width: view.frame.width / 2 - margin * 3, height: 90.0)
        // 列間の余白
        flowLayout.minimumInteritemSpacing = margin * 2
        // 行間の余白
        flowLayout.minimumLineSpacing = margin * 2
        // セクションの外側の余白
        flowLayout.sectionInset = UIEdgeInsets(top: margin * 2, left: margin * 2, bottom: margin * 2, right: margin * 2)
        self.collectionView.collectionViewLayout = flowLayout
    }
    
    /// 引っ張って更新用アクション
    @objc func refreshCollectionView() {
        print("引っ張って更新が始まります！")
        
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
        print("記念日データ件数: \(anniversarys.count)件")
        // 記念日が一つもないときはガイド用Viewを表示
        emptySetView.isHidden = anniversarys.count == 0
            ? false : true

        return anniversarys.count
    }
    
    /// CollectionViewCellの表示設定
    ///
    /// - Parameters:
    ///   - collectionView: AnniversaryViewController
    ///   - indexPath: セル番号
    /// - Returns: CollectionViewCell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Storyboardで設定したカスタムセルIDを指定
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "anniversaryCell", for: indexPath) as! AnniversaryCell

        // 日時フォーマットクラス
        let dtf = DateTimeFormat()

        // 記念日データを順に取り出す
        let anniversary = self.anniversarys[indexPath.row]
        // 記念日の分類
        let type = anniversary["type"] as! String
        // 記念日のID（隠し項目）
        cell.anniversaryId.text = anniversary["id"] as? String
        // 記念日の名称。もし誕生日だったら苗字と名前を繋げて表示
        if type == "contactBirthday" {
            cell.anniversaryNameLabel.text = "\(anniversary["familyName"] as! String) \(anniversary["givenName"] as! String)さん\n誕生日"
        }
        // 記念日の日程
        cell.anniversaryDateLabel.text = dtf.getMonthDayString(date: anniversary["date"] as! Date)
        // 記念日までの残り日数
        let remainingDays = anniversary["remainingDays"] as! Int
        cell.remainingDaysLabel.text = String(format: NSLocalizedString("remainingDays", comment: ""), remainingDays.description)
        // 記念日のアイコン
        if let iconImage = anniversary["iconImage"] as? Data {
            cell.anniversaryIconImage.image = UIImage(data: iconImage)
            
        } else {
            // デフォルトアイコン
            cell.anniversaryIconImage.image = type == "contactBirthday"
                ? #imageLiteral(resourceName: "Ribbon") // 誕生日
                : #imageLiteral(resourceName: "PresentBox") // それ以外
        }
        
        // 残り日数によってセルの見た目を変化させる
        if remainingDays <= 30 { // 記念日がもうすぐ！な場合
            // 文字
            cell.anniversaryNameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.anniversaryDateLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.remainingDaysLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            // 背景
            let startColor = #colorLiteral(red: 0.8235294118, green: 0.0862745098, blue: 0.3921568627, alpha: 1).cgColor
            let endColor = #colorLiteral(red: 0.5529411765, green: 0.2235294118, blue: 1, alpha: 1).cgColor
            let layer = CAGradientLayer()
            layer.colors = [startColor, endColor]
            layer.frame = view.bounds
            layer.startPoint = CGPoint(x: 1, y: 0)
            layer.endPoint = CGPoint(x: 0, y: 1)
            layer.name = "grade"
            cell.layer.insertSublayer(layer, at: 0)

        }
        // 残り日数によって分岐
        switch remainingDays {
        case 0: // 当日のとき
            cell.remainingDaysLabel.text = NSLocalizedString("remainingDaysToday", comment: "")
            
        case 1: // 明日のとき
            cell.remainingDaysLabel.text = NSLocalizedString("remainingDaysTomorrow", comment: "")
            
        default: break
        }
        return cell
    }
    
}
