//
//  GiftListPresenter.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/03/21.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import Foundation
import Firebase
/// Viewから指示を受けるためのデリゲート
protocol GiftListPresenterInput: AnyObject {
    var numberOfSections: Int { get }
    func addListenerAndUpdateGift()
    func removeListener()
    func numberOfGifts(forSection section: Int) -> Int
    func gift(at indexPath: IndexPath) -> Gift?
    func didSelectItem(at indexPath: IndexPath)
    func deleteRow(at indexPath: IndexPath)
}
/// Viewに指示を出すためのデリゲート
protocol GiftListPresenterOutput: AnyObject {
    func update(gifts: [Gift])
    func delete(at: IndexPath)
    func toggleGuidanceView(hasGift: Bool)
    func transitionToGiftRecord(gift: Gift)
}
/// ギフトリスト画面とモデルの仲介役
final class GiftListPresenter: GiftListPresenterInput {
    // View & Model
    private weak var view: GiftListPresenterOutput!
    private var model: GiftListModelInput
    // ギフト
    private(set) var gifts = [Gift]()
    
    // 現状は一つのセクションしか使う予定なし
    var numberOfSections: Int = 1
    
    // PresenterはViewとModelの参照を持つ
    required init(view: GiftListPresenterOutput, model: GiftListModelInput) {
        self.view = view
        self.model = model
    }

    /// Firestoreのgiftコレクションにリスナーを登録し、変更あればUI更新を命令する
    func addListenerAndUpdateGift() {
        model.startFetch { [weak self] gifts in
            guard let self = self else { return }
            self.gifts = gifts
            self.view.update(gifts: gifts)
        }
    }
    // リスナーを破棄
    func removeListener() {
        model.stopFetch()
    }
    // ギフトの数を返す
    func numberOfGifts(forSection section: Int) -> Int {
        // ギフトが一つもないときはガイド用Viewを表示
        let hasGift = !gifts.isEmpty
        view.toggleGuidanceView(hasGift: hasGift)
        // 現在は一つのセクションしかない
        return gifts.count
    }
    // TODO: Optionalの必要があるかどうか
    func gift(at indexPath: IndexPath) -> Gift? {
        return gifts[indexPath.row]
    }
    /// ギフトが選択されたらギフトデータを取得して、Viewに詳細画面への遷移指示を出す
    func didSelectItem(at indexPath: IndexPath) {
        guard let gift = gift(at: indexPath) else { return }
        view.transitionToGiftRecord(gift: gift)
    }
    // ギフトを削除する
    func deleteRow(at indexPath: IndexPath) {
        // DBのデータを削除
        GiftDAO.delete(documentPath: gifts[indexPath.row].id)
        // ローカルのデータ配列を削除
        gifts.remove(at: indexPath.row)
        // 画面上のセルを削除
        view.delete(at: indexPath)
    }
}
