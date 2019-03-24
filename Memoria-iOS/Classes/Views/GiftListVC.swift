//
//  GiftListVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/11.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

/// Gift一覧を表示するメイン画面のクラス
final class GiftListVC: UIViewController {

    // MARK: - Presenter
    private var presenter: GiftListPresenterInput!
    
    // MARK: - IBOutlet properties
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var guidanceView: UIView!
    
    // MARK: - Properties
    // TODO: 不要かも？
    var authStateListenerHandler: AuthStateDidChangeListenerHandle?

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "gift".localized
        // プレゼンターをインスタンス化
        // TabBarControllerから表示されるので自ら注入する？
        presenter = GiftListPresenter(view: self, model: GiftListModel())
        // Xibファイルを登録する
        tableView.register(UINib(nibName: "GiftListCell", bundle: nil), forCellReuseIdentifier: "giftListCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.addListenerAndUpdateGift()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.removeListener()
    }
}

// MARK: - Table view data source
extension GiftListVC: UITableViewDataSource {
    // セクション数
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSections
    }

    // セクションごとの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfGifts(forSection: section)
    }

    // Cellの作成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // カスタムセルを指定
        let cell = tableView.dequeueReusableCell(withIdentifier: "giftListCell", for: indexPath) as! GiftListCell
        // ギフト情報を取得してセルに設定
        if let gift = presenter.gift(at: indexPath) {
            cell.configure(gift: gift)
        }
        return cell
    }
    
    /// スワイプで削除可能になる
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // ローカル・DBのデータおよびテーブルビューの行を削除する
        presenter.deleteRow(at: indexPath)
    }
}

// MARK: - TableViewDelegate
extension GiftListVC: UITableViewDelegate {
    // セルを選択した時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectItem(at: indexPath)
    }
}

// MARK: - GiftListPresenterOutput
extension GiftListVC: GiftListPresenterOutput {
    func update(gifts: [Gift]) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    // ギフトが削除された時にTableView上のぎ該当行を削除する
    func delete(at indexPath: IndexPath) {
        // Table view cellを削除
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    /// ギフトがない時はガイド用のViewを表示するためのり切り替えメソッド
    func toggleGuidanceView(hasGift: Bool) {
        guidanceView.isHidden = hasGift
    }
    /// ギフトが選択された時に、ギフト編集画面へ遷移する
    func transitionToGiftRecord(gift: Gift) {
        let nextVC = UIStoryboard(name: "GiftRecord", bundle: nil)
            .instantiateInitialViewController()!
        // TODO: GiftRecordクラスのMVP化の際に有効化する
        // ModelとPresenterをインスタンス化
//        let giftRecordModel = GiftRecordModel()
        // PresenterはViewとModelの参照を持っている
//        let presenter = GiftRecordPresenter(gift: gift, view: giftRecordVC, model: giftRecordModel)
        // ViewにPresenterを注入
//        giftRecordVC.inject(presenter: presenter)
        // 編集画面へ遷移
        navigationController?.present(nextVC, animated: true, completion: nil)
    }
}
