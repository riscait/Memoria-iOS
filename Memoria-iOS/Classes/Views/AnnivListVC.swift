//
//  AnnivListVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/10/27.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

protocol AnnivListView: AnyObject {
    func reloadData()
}
/// 記念日一覧を表示するメイン画面のクラス
final class AnnivListVC: UIViewController {
    // MARK: - Enum
    // CollectionViewのセクション
    enum CollectionSection: Int {
        case notFinishedAnniv
        case finishedAnniv
    }
    
    // MARK: - Presenter
    private var presenter: AnnivListPresenterInput!
    
    // MARK: - IBOutlet properties
    @IBOutlet weak var emptySetView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    // 引っ張って更新用のRefreshControl
    private lazy var refresher: UIRefreshControl = {
        let refresher = UIRefreshControl()
        // リフレッシュ実行時に呼び出すメソッドを指定
        refresher.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        return refresher
    }()
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // プレゼンターをインスタンス化
        // TabBarControllerから表示されるので自ら注入する？
        presenter = AnnivListPresenter(view: self, model: AnnivListModel())
        
        // コレクションビューにRefreshControlを設定
        collectionView.refreshControl = refresher
        // CollectionViewのレイアウト設定
        setup(withMargin: 6.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // FIXME: これ不要？
        if ((Auth.auth().currentUser?.uid) == nil) { return }
        presenter.addListenerAndUpdateAnniv()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.removeAnnivListener()
    }
    
    // MARK: - Navigation methods
    /// セグエで他の画面へ遷移するときに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        
        if id == "toDetailSegue" {
            let nextVC = segue.destination as! AnnivDetailVC
            guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return }
            // TODO: AnnivDetailVCのMVP化で消す
            nextVC.anniv = presenter.anniv(forSection: indexPath.section, forRow: indexPath.row)!.toDictionary
        }
    }
    
    // MARK: - IBAction methods
    /// 他の画面からこの画面へ戻ってくるのに使う
    @IBAction func returnToAnnivVC(segue: UIStoryboardSegue) {}
    
    // MARK: - Misc methods
    
    /// コレクションビューのレイアウト設定
    private func setup(withMargin margin: CGFloat) {
        let margin2x = margin * 2
        title = "anniversary".localized
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: view.frame.width / 2 - margin * 3, height: 90.0)
        // 列間の余白
        flowLayout.minimumInteritemSpacing = margin2x
        // 行間の余白
        flowLayout.minimumLineSpacing = margin2x
        // セクションの外側の余白
        flowLayout.sectionInset = UIEdgeInsets(top: margin2x, left: margin2x, bottom: margin2x, right: margin2x)
        collectionView.collectionViewLayout = flowLayout
    }
}

// MARK: - AnnivListView Delegate
extension AnnivListVC: AnnivListView {
    // CollectionViewを更新する
    @objc func reloadData() {
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
            self.collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionView DataSource
extension AnnivListVC: UICollectionViewDataSource {
/// CollectionViewのセクション数
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return presenter.numberOfSections
    }
    
    /// CollectionViewのアイテム数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfAnnivs(forSection: section)
    }
    
    /// CollectionViewCellの作成
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "anniversaryCell", for: indexPath) as! AnnivCell
        if let anniv = presenter.anniv(forSection: indexPath.section, forRow: indexPath.row) {
            cell.configure(anniv: anniv)
        }
        return cell
    }
}

// MARK: - AnnivListPresenterOutput
extension AnnivListVC: AnnivListPresenterOutput {
    /// 記念日リストを更新する
    func updateAnnivs(forNotFinished notFinishedAnnivs: [Anniv], forFinished finishedAnnivs: [Anniv]) {
        collectionView.reloadData()
    }
    
    /// 詳細画面へ遷移する
    func transitionToAnnivDetail(userName: String) {
        let annivDetailVC = UIStoryboard(name: "AnnivDetail", bundle: nil).instantiateInitialViewController() as! AnnivDetailVC
        // FIXME: M & P
        // let model = AnnivDetailModel()
        // let presenter = AnnivDetailPresenter()
        // annivDetailVC.inject(presenter: presenter)
        navigationController?.pushViewController(annivDetailVC, animated: true)
    }
}
