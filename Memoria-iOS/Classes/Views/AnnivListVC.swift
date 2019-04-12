//
//  AnnivListVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/10/27.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

/// 記念日一覧を表示するメイン画面のクラス
final class AnnivListVC: UIViewController, EventTrackable {
    // MARK: - Enum
    // CollectionViewのセクション
    enum CollectionSection: Int {
        case notFinishedAnniv
        case finishedAnniv
    }
    
    // MARK: - Presenter
    private var presenter: AnnivListPresenterInput!
    
    // MARK: - IBOutlet properties
    @IBOutlet private weak var emptySetView: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // プレゼンターをインスタンス化
        // TabBarControllerから表示されるので自ら注入する？
        presenter = AnnivListPresenter(view: self, model: AnnivListModel())
        // CollectionViewのレイアウト設定
        setup(withMargin: 6.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreen()
        // FIXME: これ不要？
        if ((Auth.auth().currentUser?.uid) == nil) { return }
        presenter.addListenerAndUpdateAnniv()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.removeAnnivListener()
    }
    
    // MARK: - IBAction methods
    /// FIXME: 他の画面からこの画面へ戻ってくるのに使っている？
    @IBAction func returnToAnnivVC(segue: UIStoryboardSegue) {}
    
    // MARK: - Private methods
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

// MARK: - UICollectionView Dalegate
extension AnnivListVC: UICollectionViewDelegate {
    /// CollectionViewのセルを選択した時
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectItem(at: indexPath)
    }
}

// MARK: - AnnivListPresenterOutput
extension AnnivListVC: AnnivListPresenterOutput {
    /// 記念日が一つもない場合は、記念日の追加を促すViewを表示する
    func toggleEmptySetView(hasAnniv: Bool) {
        emptySetView.isHidden = hasAnniv
    }
    
    /// 記念日リストを更新する
    func updateAnnivs(forNotFinished notFinishedAnnivs: [Anniv], forFinished finishedAnnivs: [Anniv]) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    /// 詳細画面へ遷移する
    func transitionToAnnivDetail(anniv: Anniv) {
        let annivDetailVC = UIStoryboard(name: "AnnivDetail", bundle: nil).instantiateInitialViewController() as! AnnivDetailVC
        // ModelとPresenterをインスタンス化
        let model = AnnivDetailModel()
        // PresenterはViewとModelの参照を持っている
        let presenter = AnnivDetailPresenter(anniv: anniv, view: annivDetailVC, model: model)
        print("Debug log:", "presenter", "->", presenter)
        // ViewにPresenterを注入
        annivDetailVC.inject(presenter: presenter)
        // 詳細画面へPushで遷移
        navigationController?.pushViewController(annivDetailVC, animated: true)
    }
}
