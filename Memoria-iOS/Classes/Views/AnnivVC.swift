//
//  AnnivVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/10/27.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

/// 記念日一覧を表示するメイン画面のクラス
final class AnnivVC: UICollectionViewController {
    
    // MARK: - IBOutlet property

    @IBOutlet private weak var emptySetView: UIView!

    
    // MARK: - Properties
    
    /// リスナー登録
    var listenerRegistration: ListenerRegistration?
    /// 未来の日付、または繰り返す記念日
    var notFinishedAnnivs = [[String: Any]]()
    /// 繰り返さない記念日かつ、もう過ぎた記念日の数
    var finishedAnnivs = [[String: Any]]()
    
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
        if ((Auth.auth().currentUser?.uid) == nil) {
            return
        }
        registerListener()
    }
    
    /// Viewが非表示になる直前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // リスナー登録を破棄する
        if let listenerRegistration = listenerRegistration {
            listenerRegistration.remove()
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
            let nextVC = segue.destination as! AnnivDetailVC
            guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return }
            switch indexPath.section {
            case 0:
                nextVC.anniv = notFinishedAnnivs[indexPath.row]
            case 1:
                nextVC.anniv = finishedAnnivs[indexPath.row]
            default : fatalError()
            }
        }
    }
    
    
    // MARK: - IBAction（InterfaceBuiderとつないだActionメソッド）
    
    /// 他の画面からこの画面へ戻ってくる
    ///
    /// - Parameter segue: Segue
    @IBAction func returnToAnnivVC(segue: UIStoryboardSegue) {}
    
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
        let filteredCollection = AnnivDAO.getQuery(whereField: "isHidden", equalTo: false)
        // anniversaryコレクションの変更を監視するリスナー登録
        listenerRegistration = filteredCollection?.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                print("ドキュメント取得エラー: \(error!)")
                return
            }
            print("anniversaryコレクション変更リスナー登録！")
            self.notFinishedAnnivs.removeAll()
            self.finishedAnnivs.removeAll()
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
                if remainingDays < 0, !isAnnualy {
                    self.finishedAnnivs.append(data)
                } else {
                    self.notFinishedAnnivs.append(data)
                }
            }
            // 記念日までの残日数順で並び替える
            self.notFinishedAnnivs.sort(by: {($0["remainingDays"] as! Int) < ($1["remainingDays"] as! Int)})
            self.finishedAnnivs.sort(by: {($0["remainingDays"] as! Int) < ($1["remainingDays"] as! Int)})

            let yesterdays = self.notFinishedAnnivs.filter { $0["remainingDays"] as! Int == -1}
            let otherDays = self.notFinishedAnnivs.filter { $0["remainingDays"] as! Int != -1}
            self.notFinishedAnnivs = otherDays + yesterdays
            self.collectionView.reloadData()
        }
    }
    
    /// 引っ張って更新用アクション
    @objc func refreshCollectionView() {
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
        let sectionNum = finishedAnnivs.isEmpty ? 1 : 2
        return sectionNum
    }
    
    /// CollectionViewのアイテム数
    ///
    /// - Parameters:
    ///   - collectionView: AnniversaryVC
    ///   - section: セクション番号
    /// - Returns: アイテム数
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 記念日が一つもないときはガイド用Viewを表示
        emptySetView.isHidden = notFinishedAnnivs.count != 0

        switch section {
        case 0: return notFinishedAnnivs.count
        case 1: return finishedAnnivs.count
            
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "anniversaryCell", for: indexPath) as! AnnivCell
        // 記念日データを順に取り出す
        let anniversary: [String : Any]
        switch indexPath.section {
        case 0: anniversary = self.notFinishedAnnivs[indexPath.row]
        case 1: anniversary = self.finishedAnnivs[indexPath.row]
        default: fatalError()
        }
        // 記念日の名前
        cell.annivNameLabel.text = AnnivUtil.getName(from: anniversary)
        // 記念日の日程
        guard let anniversaryDate = (anniversary["date"] as? Timestamp)?.dateValue() else { return cell }
        cell.annivDateLabel.text = DateTimeFormat.getMonthDayString(date: anniversaryDate)
        // 繰り返す記念日か否か
        let isAnnualy = anniversary["isAnnualy"] as! Bool
        // 記念日のアイコン
        cell.annivIconImage.image = AnnivUtil.getIconImage(from: anniversary)
        // 記念日までの残り日数
        let remainingDays = anniversary["remainingDays"] as! Int
        // 過去の記念日かどうか
        let isPastAnniversary = remainingDays < 0 && !isAnnualy
        // 過去の記念日は薄くする
        cell.contentView.alpha = isPastAnniversary ? 0.5 : 1.0

        // グラデーションのためのレイヤー
        var layer: CAGradientLayer?
        // 近日中の記念日設定
        if 0...30 ~= remainingDays {
            // 文字
            cell.annivNameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.annivDateLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.remainingDaysLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            layer = CAGradientLayer()
            layer?.frame = view.bounds
            layer?.startPoint = CGPoint(x: 0, y: 0.5)
            layer?.endPoint = CGPoint(x: 0.5, y: 0)
            layer?.name = "grade"
        }
        // 特別な残日数の設定
        switch remainingDays {
        case -1:  // 昨日
            cell.remainingDaysLabel.text = "remainingDaysYesterday".localized
            
        case 0:  // 当日
            if let layer = layer {
                // 背景
                let startColor = #colorLiteral(red: 0.8235294118, green: 0.0862745098, blue: 0.3921568627, alpha: 1).cgColor
                let endColor = #colorLiteral(red: 0.5529411765, green: 0.2235294118, blue: 1, alpha: 1).cgColor
                layer.colors = [startColor, endColor]
                cell.layer.insertSublayer(layer, at: 0)
            }
            cell.remainingDaysLabel.text = "remainingDaysToday".localized

        case 1:  // 明日
            cell.remainingDaysLabel.text = "remainingDaysTomorrow".localized
            fallthrough
            
        case 2...30:  // 30日以内
            if let layer = layer {
            // 背景
                cell.remainingDaysLabel.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                let startColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1).cgColor
                let endColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1).cgColor
                layer.colors = [startColor, endColor]
                cell.layer.insertSublayer(layer, at: 0)
            }
            fallthrough // 残日数文字列をセットするためにdefaultへ
        default: // 2日以前、31日以降の記念日すべて
            // 記念日までの残り日数文字列
            cell.remainingDaysLabel.text = AnnivUtil.getRemainingDaysString(from: remainingDays)
        }
        return cell
    }
}
