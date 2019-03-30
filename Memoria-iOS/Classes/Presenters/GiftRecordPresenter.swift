//
//  GiftRecordPresenter.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/03/26.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import Foundation
import Firebase
/// Viewから指示を受けるためのデリゲート
protocol GiftRecordPresenterInput: AnyObject {
    /// 既存のギフト情報を画面に反映させる
    func setExistGift()
    /// キャンセルボタンを押した時はダイアログを表示させる
    /// 新規登録か編集かで文言が変わる
    func didTapCancelButton(gift: Gift?)
    /// 画面上で入力された情報を取得し、ギフトを新規登録または編集して画面を閉じる
    func didTapRecordButton(isReceived: Bool,
                            isDateTBD: Bool,
                            personName: String,
                            annivName: String,
                            timestamp: Timestamp?,
                            goods: String,
                            mwmo: String)
}
/// Viewに指示を出すためのデリゲート
protocol GiftRecordPresenterOutput: AnyObject {
    /// 使命を終えた自らを閉じる
    func dismiss(animated: Bool)
    /// 新規登録か編集かをギフトの有無で判断し、画面レイアウトの設定を行う。
    func setupLayout(gift: Gift?)
}
/// ギフトリスト画面とモデルの仲介役
final class GiftRecordPresenter: GiftRecordPresenterInput {
    // View & Model
    private weak var view: GiftRecordPresenterOutput!
    /// ギフト（編集の場合は、選択したギフト情報が入る）
    private(set) var gift: Gift?
    // PresenterはViewとModelの参照を持つ
    init(gift: Gift?, view: GiftRecordPresenterOutput) {
        self.gift = gift
        self.view = view
    }
    
    func setExistGift() {
        view.setupLayout(gift: gift)
    }
    
    func didTapCancelButton(gift: Gift?) {
        let message = gift == nil
            ? "discardMessageForRecord".localized
            : "discardMessageForEdit".localized
        DialogBox.showDestructiveAlert(on: view as! UIViewController, message: message, destructiveTitle: "close".localized) {
            self.view.dismiss(animated: true)
        }
    }
    func didTapRecordButton(isReceived: Bool, isDateTBD: Bool, personName: String, annivName: String, timestamp: Timestamp?, goods: String, mwmo: String) {
        let id = gift?.id ?? UUID().uuidString
        let newGift = Gift(id: id,
                        isReceived: isReceived,
                        personName: personName,
                        annivName: annivName,
                        date: isDateTBD ? nil : timestamp ?? Timestamp(),
                        goods: goods,
                        memo: mwmo,
                        isHidden: false,
                        iconImage: nil)
        // DBに書き込んで画面を閉じる
        GiftDAO.set(documentPath: id, data: newGift)
        view.dismiss(animated: true)
    }
}
