//
//  AnnivDetailVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/09.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

/// 選択された記念日の詳細情報を表示する画面のクラス
final class AnnivDetailVC: UIViewController {
    // MARK: - Enum
    // CollectionViewのセクション
    enum TableSection: Int {
        case annivInfo
        case giftInfo
    }
    // MARK: - Presenter
    private var presenter: AnnivDetailPresenterInput!
    func inject(presenter: AnnivDetailPresenterInput) {
        self.presenter = presenter
    }

    // MARK: - IBOutlet properties
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = AnnivUtil.getRemainingDaysString(from: presenter.anniv.remainingDays!)
        presenter.addObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.addListenerAndUpdateGift()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.removeGiftListener()
    }
    
    // MARK: - Navigation methods
    /// セグエで他の画面へ遷移するときに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        
        if id == "editAnniversarySegue" {
            let navC = segue.destination as! UINavigationController
            let nextVC = navC.topViewController as! AnnivEditVC
            nextVC.annivModel = presenter.anniv
        }
        
        if id == "editGiftSegue" {
            let navC = segue.destination as! UINavigationController
            let nextVC = navC.topViewController as! GiftRecordVC
            let indexPath = tableView.indexPathForSelectedRow
            nextVC.selectedGiftId = presenter.gifts?[indexPath!.row]["id"] as? String
            print(nextVC.selectedGiftId ?? "selectedGiftId = nil")
        }
    }
}

// MARK: - UITableView DataSource
extension AnnivDetailVC: UITableViewDataSource {
    /// TableViewのセクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSections
    }
    
    /// TableViewのセルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows(for: section)
    }
    
    /// TableViewのセルの中身
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = TableSection(rawValue: indexPath.section) else { fatalError() }
        
        switch (section, indexPath.row) {
        case (.annivInfo, 0):  // 記念日情報メインセル
            let cell = tableView.dequeueReusableCell(withIdentifier: "annivDetailTopCell", for: indexPath) as! AnnivDetailTopCell
            cell.configure(anniv: presenter.anniv)
            return cell
            
        case (.annivInfo, let row):  // 記念日付加情報
            let cell = tableView.dequeueReusableCell(withIdentifier: "annivDetailInfoCell", for: indexPath) as! AnnivDetailInfoCell
            var content: AnnivDetailInfoCell.contentType
            switch row {
            case 1: content = AnnivDetailInfoCell.contentType.zodiacStarSign
            case 2: content = AnnivDetailInfoCell.contentType.chineseZodiacSign
            default: fatalError()  // セルの数を増やした時、設定忘れを防ぐため fatalError() とする
            }
            cell.configure(anniv: presenter.anniv, contentType: content)
            return cell
            
        case (.giftInfo, let row):  // 関連ギフト一覧
            let cell = tableView.dequeueReusableCell(withIdentifier: "annivDetailGiftCell", for: indexPath) as! AnnivDetailGiftCell
            cell.configure(annivCategory: presenter.anniv.category, gifts: presenter.gifts!, row: row)
            return cell
        }
    }
    
    /// ヘッダー
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.titleForHeader(in: section)
    }
    
    /// フッター
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return presenter.titleForFooter(in: section)
    }
}

// MARK: - UITableView Delegate
extension AnnivDetailVC: UITableViewDelegate {
    /// セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(presenter.heightForRow(at: indexPath))
    }
    /// ヘッダーの高さ
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // 高さを0にするには CGFloat.leastNormalMagnitude を返す必要がある
        if let height = presenter.heightForHeader(in: section) {
            return CGFloat(height)
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }
    /// セルを選択した時の挙動
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - AnnivDetailPresenterOutput
extension AnnivDetailVC: AnnivDetailPresenterOutput {
    // 参考にしたリポジトリではこのように引数で情報を渡しつつも、それは使っていなかったので、
    // とりあえずそれにならって引数でgiftsを渡しつつもここでは使用していない
    func update(for gifts: [[String : Any]]?) {
        navigationItem.title = AnnivUtil.getRemainingDaysString(from: presenter.anniv.remainingDays!)
        tableView.reloadData()
    }
    // 一つ前の画面へ戻る
    @objc func popVC() {
        navigationController?.popViewController(animated: true)
    }
    func transitionToAnnivEdit(anniv: Anniv) {
        // TODO: 他Issueにて,Segueから移行する
    }
    func transitionToGiftEdit(anniv: Anniv) {
        // TODO: 他Issueにて,Segueから移行する
    }
}
