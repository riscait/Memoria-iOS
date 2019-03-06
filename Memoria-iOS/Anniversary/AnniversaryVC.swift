//
//  AnniversaryVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/10/27.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

/// 記念日一覧を表示するメイン画面のクラス
final class AnniversaryVC: UICollectionViewController {
    
    // MARK: - IBOutlet property

    @IBOutlet private weak var emptySetView: UIView!

    
    // MARK: - Property
    
    /// 正直まだよく理解していないリスナー登録？
    var listenerRegistration: ListenerRegistration?
    
    /// 記念日データ配列
    var anniversarys = [[String: Any]]()
    /// 繰り返さない記念日かつ、もう過ぎた記念日の数
    var alreadyFinishedAnniversary = [[String: Any]]()
    
    // 引っ張って更新用のRefreshControl
    var refresher = UIRefreshControl()
    
    
    // MARK: - Life cycle
    
    /// Viewの読込完了後に一度だけ呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "anniversary".localized

        /* ---------- 検索バーは未実装 ----------
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        // 検索バーを常に表示する場合はfalse。消すと引っ張って出現してスクロールで隠れるようになる
        navigationItem.hidesSearchBarWhenScrolling = false
         */
        
        // コレクションビューにRefreshControlを設定
        collectionView.refreshControl = refresher
        // リフレッシュ実行時に呼び出すメソッドを指定
        refresher.addTarget(self, action: #selector(refreshCollectionView), for: .valueChanged)
        // CollectionViewのレイアウト設定
        setLayout(margin: 6.0)
    }
    
    /// Viewが表示される直前に呼ばれる（タブ切り替え等も含む）
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("AnniversaryVCの\(#function)")
        if ((Auth.auth().currentUser?.uid) == nil) {
            return
        }
        registerListener()
    }
    
    /// Viewが非表示になる直前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("AnniversaryVCの\(#function)")
        // リスナー登録を破棄する
        if let listenerRegistration = listenerRegistration {
            listenerRegistration.remove()
            print("anniversaryコレクション変更リスナー破棄！")
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
        
        if id == "toDetailSegue" {
            let nextVC = segue.destination as! AnniversaryDetailVC
            guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return }
            switch indexPath.section {
            case 0:
                nextVC.anniversary = anniversarys[indexPath.row]
            case 1:
                nextVC.anniversary = alreadyFinishedAnniversary[indexPath.row]
            default : fatalError()
            }
        }
    }
    
    
    // MARK: - IBAction（InterfaceBuiderとつないだActionメソッド）
    
    /// 他の画面からこの画面へ戻ってくる
    ///
    /// - Parameter segue: Segue
    @IBAction func returnToAnniversaryVC(segue: UIStoryboardSegue) {}
    
    // MARK: - Misc method
    
    /// コレクションビューのレイアウト設定
    ///
    /// - Parameter margin: レイアウトの余白数値
    private func setLayout(margin: CGFloat) {
        
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
    
    /// 記念日データ変更監視用リスナー登録
    private func registerListener() {
        let filteredCollection = AnniversaryDAO.getQuery(whereField: "isHidden", equalTo: false)
        // anniversaryコレクションの変更を監視するリスナー登録
        listenerRegistration = filteredCollection?.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                print("ドキュメント取得エラー: \(error!)")
                return
            }
            print("anniversaryコレクション変更リスナー登録！")
            self.anniversarys.removeAll()
            self.alreadyFinishedAnniversary.removeAll()
            // 記念日データが入ったドキュメントの数だけ繰り返す
            for doc in snapshot.documents {
                // ドキュメントから記念日データを取り出す
                var data = doc.data()
                // 記念日データから日付を取り出す
                guard let anniversaryDate = (data["date"] as? Timestamp)?.dateValue() else { return }
                let isAnnualy = data["isAnnualy"] as? Bool ?? true
                // 日付から次の記念日までの残日数を計算
                let remainingDays = DateDifferenceCalculator.getDifference(from: anniversaryDate, isAnnualy: isAnnualy)
                // 記念日データに残日数を追加
                data["remainingDays"] = remainingDays
                // 残日数も含めた記念日データをローカル配列に記憶
                if remainingDays < 0 {
                    self.alreadyFinishedAnniversary.append(data)
                } else {
                    self.anniversarys.append(data)
                }
            }
            // 記念日までの残日数順で並び替える
            self.anniversarys.sort(by: {($0["remainingDays"] as! Int) < ($1["remainingDays"] as! Int)})
            self.alreadyFinishedAnniversary.sort(by: {($0["remainingDays"] as! Int) < ($1["remainingDays"] as! Int)})

            self.collectionView.reloadData()
        }
    }
    
    /// 引っ張って更新用アクション
    @objc func refreshCollectionView() {
        print("引っ張って更新が始まります！")
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        refresher.endRefreshing()
    }

    
    // MARK: - UICollectionViewDataSource
    
    /// CollectionViewのセクション数
    ///
    /// - Parameter collectionView: AnniversaryVC
    /// - Returns: セクションの数
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // 終了済み記念日があればセクション数を2に増やす
        let sectionNum = alreadyFinishedAnniversary.isEmpty ? 1 : 2
        print("sectionNum:", sectionNum)
        return sectionNum
    }
    
    /// CollectionViewのアイテム数
    ///
    /// - Parameters:
    ///   - collectionView: AnniversaryVC
    ///   - section: セクション番号
    /// - Returns: アイテム数
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("記念日データ件数: \(anniversarys.count)件")
        print("終了済み件数: \(alreadyFinishedAnniversary.count)件")
        // 記念日が一つもないときはガイド用Viewを表示
        emptySetView.isHidden = anniversarys.count != 0

        switch section {
        case 0: return anniversarys.count
        case 1: return alreadyFinishedAnniversary.count
            
        default: return 0
        }
    }
    
    /// CollectionViewCellの表示設定
    ///
    /// - Parameters:
    ///   - collectionView: AnniversaryVC
    ///   - indexPath: セル番号
    /// - Returns: CollectionViewCell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Storyboardで設定したカスタムセルIDを指定
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "anniversaryCell", for: indexPath) as! AnniversaryCell
        // 記念日データを順に取り出す
        let anniversary: [String : Any]
        switch indexPath.section {
        case 0: anniversary = self.anniversarys[indexPath.row]
        case 1: anniversary = self.alreadyFinishedAnniversary[indexPath.row]
        default: fatalError()
        }
        // 記念日の名前
        cell.anniversaryNameLabel.text = AnniversaryUtil.getName(from: anniversary)
        // 記念日の日程
        guard let anniversaryDate = (anniversary["date"] as? Timestamp)?.dateValue() else { return cell }
        cell.anniversaryDateLabel.text = DateTimeFormat.getMonthDayString(date: anniversaryDate)
        // 記念日のアイコン
        cell.anniversaryIconImage.image = AnniversaryUtil.getIconImage(from: anniversary)
        // 記念日までの残り日数
        let remainingDays = anniversary["remainingDays"] as! Int
        cell.remainingDaysLabel.text = AnniversaryUtil.getRemainingDaysString(from: remainingDays)
        
        // 残り日数によってセルの見た目を変化させる
        var layer: CAGradientLayer?
        if 0 < remainingDays, remainingDays <= 30 {
            // 文字
            cell.anniversaryNameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.anniversaryDateLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.remainingDaysLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            layer = CAGradientLayer()
            layer?.frame = view.bounds
            layer?.startPoint = CGPoint(x: 0, y: 0.5)
            layer?.endPoint = CGPoint(x: 0.5, y: 0)
            layer?.name = "grade"
        }
        switch remainingDays {
        case -1:
            cell.remainingDaysLabel.text = "remainingDaysYesterday".localized
            fallthrough
        case ...0:
            cell.alpha = 0.7
            
        case 0:
            // 背景
            let startColor = #colorLiteral(red: 0.8235294118, green: 0.0862745098, blue: 0.3921568627, alpha: 1).cgColor
            let endColor = #colorLiteral(red: 0.5529411765, green: 0.2235294118, blue: 1, alpha: 1).cgColor
            layer?.colors = [startColor, endColor]
            cell.layer.insertSublayer(layer!, at: 0)
            // 「当日」と表示する
            cell.remainingDaysLabel.text = "remainingDaysToday".localized

        case 1:
            // 「明日」と表示する
            cell.remainingDaysLabel.text = "remainingDaysTomorrow".localized
            fallthrough
        case ...30:
            // 背景
            cell.remainingDaysLabel.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            let startColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1).cgColor
            let endColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1).cgColor
            layer?.colors = [startColor, endColor]
            cell.layer.insertSublayer(layer!, at: 0)
            
        default: break
        }
        return cell
    }
}
