//
//  AnnivPresenter.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/03/10.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import Foundation
import Firebase
/// Viewから指示を受けるためのデリゲート
protocol AnnivListPresenterInput: AnyObject {
    var numberOfSections: Int { get }
    func addListenerAndUpdateAnniv()
    func removeAnnivListener()
    func numberOfAnnivs(forSection section: Int) -> Int
    func anniv(forSection section: Int, forRow row: Int) -> Anniv?
    func didSelectItem(at indexPath: IndexPath)
}
/// Viewに指示を出すためのデリゲート
protocol AnnivListPresenterOutput: AnyObject {
    func updateAnnivs(forNotFinished notFinishedAnnivs: [Anniv], forFinished finishedAnnivs: [Anniv])
    func transitionToAnnivDetail(anniv: Anniv)
}

/// 記念日リスト画面とモデルの仲介役
final class AnnivListPresenter: AnnivListPresenterInput {
    // Presenter & Model
    private weak var view: AnnivListPresenterOutput!
    private var model: AnnivListModelInput
    /// これからの記念日
    private(set) var notFinishedAnnivs = [Anniv]()
    /// 終了済みの記念日
    private(set) var finishedAnnivs = [Anniv]()
    /// 終了済み記念日があれば、セクションが2つ必要
    var numberOfSections: Int {
        return finishedAnnivs.isEmpty ? 1 : 2
    }
    // PresenterはViewとModelの参照を持つ
    required init(view: AnnivListPresenterOutput, model: AnnivListModelInput) {
        self.view = view
        self.model = model
    }
    
    /// Firestoreのanniversaryコレクションにリスナーを登録し、変更あればUI更新を命令する
    func addListenerAndUpdateAnniv() {
        model.startFetchAnnivs { [weak self] (notFinishedAnnivs, finishedAnnivs) in
            guard let self = self else { return }
            self.notFinishedAnnivs = notFinishedAnnivs
            self.finishedAnnivs = finishedAnnivs
            DispatchQueue.main.async {
                self.view.updateAnnivs(forNotFinished: notFinishedAnnivs, forFinished: finishedAnnivs)
            }
        }
    }

    /// リスナー登録を破棄する
    func removeAnnivListener() {
        model.stopFetchAnnivs()
    }
    /// 記念日の数を返す
    func numberOfAnnivs(forSection section: Int) -> Int {
        switch section {
        case AnnivListSection.notFinishedAnniv.rawValue:
            return notFinishedAnnivs.count
        case AnnivListSection.finishedAnniv.rawValue:
            return finishedAnnivs.count
        default:
            return 0
        }
    }
    /// セクションと行を用いて、一つの記念日を返す
    func anniv(forSection section: Int, forRow row: Int) -> Anniv? {
        switch section {
        case AnnivListSection.notFinishedAnniv.rawValue:
            guard row < notFinishedAnnivs.count else { return nil }
            return notFinishedAnnivs[row]
        case AnnivListSection.finishedAnniv.rawValue:
            guard row < finishedAnnivs.count else { return nil }
            return finishedAnnivs[row]
        default:
            fatalError()
        }
    }
    /// 記念日が選択されたら記念日データを取得して、Viewに詳細画面への遷移指示を出す
    func didSelectItem(at indexPath: IndexPath) {
        guard let anniv = anniv(forSection: indexPath.section, forRow: indexPath.row) else { return }
        view.transitionToAnnivDetail(anniv: anniv)
    }
}
