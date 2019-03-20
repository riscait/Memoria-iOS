//
//  AnnivDetailPresenter.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/03/16.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import Foundation

protocol AnnivDetailPresenterInput: AnyObject {
    var anniv: Anniv! { get }
    var gifts: [[String: Any]]? { get }
    var numberOfSections: Int { get }
    func addListenerAndUpdateGift()
    func removeGiftListener()
    func numberOfRows(for section: Int) -> Int
    func titleForHeader(in section: Int) -> String?
    func titleForFooter(in section: Int) -> String?
    func heightForRow(at indexPath: IndexPath) -> Float
    func heightForHeader(in section: Int) -> Float?
}

protocol AnnivDetailPresenterOutput: AnyObject {
    func update(for gifts: [[String: Any]]?)
}

/// 記念日詳細画面とモデルの仲介役
final class AnnivDetailPresenter: AnnivDetailPresenterInput {
    // MARK: - Enum
    // TableViewのセクション
    enum Section: Int {
        case topSection
        case giftSection
    }

    // Presenter & Model
    private weak var view: AnnivDetailPresenterOutput!
    private var model: AnnivDetailModelInput
    
    /// AnnivListVCから遷移してくる際に受け取る、特定の記念日データ
    private(set) var anniv: Anniv!
    /// 記念日に紐付くギフト
    private(set) var gifts: [[String: Any]]?
    /// 記念日に紐付くギフトがあればセクションが2つ必要
    var numberOfSections: Int {
        return gifts == nil ? 1 : 2
    }
    // PresenterはViewとModelの参照を持つ
    init(anniv: Anniv, view: AnnivDetailPresenterOutput, model: AnnivDetailModelInput) {
        // 記念日リスト画面から記念日情報を引き継ぐ
        self.anniv = anniv
        self.view = view
        self.model = model
    }
    
    /// Firestoreのgiftコレクションにリスナーを登録し、変更あればUI更新を命令する
    func addListenerAndUpdateGift() {
        model.startFetchAnnivAndGifts(anniv: self.anniv) { [weak self] anniv, gifts  in
            guard let self = self else { return }
            self.anniv = anniv
            self.gifts = gifts
            self.view.update(for: gifts)
        }
    }
    /// リスナー登録を破棄する
    func removeGiftListener() {
        model.stopFetchAnnivAndGifts()
    }
    /// セクションごとの行数を返す
    func numberOfRows(for section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .topSection:
            // 誕生日にはプラスでセルが必要（干支・星座）
            return anniv.category == .anniv ? 1 : 3
        case .giftSection:
            return gifts?.count ?? 0
        }
    }
    
    /// 各セクションのヘッダータイトル文字列
    func titleForHeader(in section: Int) -> String? {
        let section = Section(rawValue: section)!
        switch section {
        case .topSection: return nil
        case .giftSection: return "giftHistory".localized
        }
    }
    /// 各セクションのフッタータイトル文字列
    func titleForFooter(in section: Int) -> String? {
        let section = Section(rawValue: section)!
        switch (section, anniv.category) {
        case (.topSection, _): return anniv.memo.isEmpty ? nil : "memo:".localized + anniv.memo
        case (.giftSection, .anniv): return "giftSectionFooterForAnniversary".localized
        case (.giftSection, .birthday): return "giftSectionFooterForBirthday".localized
        }
    }
    /// 各行の高さ
    func heightForRow(at indexPath: IndexPath) -> Float {
        let section = Section(rawValue: indexPath.section)!
        switch (section, indexPath.row) {
        case (.topSection, 0): return 116
        case (.topSection, _),
             (.giftSection, _): return 44
        }
    }
    /// 各セクションのヘッダーの高さ
    func heightForHeader(in section: Int) -> Float? {
        let section = Section(rawValue: section)!
        switch section {
        case .topSection: return nil
        case .giftSection: return 40
        }
    }
}
