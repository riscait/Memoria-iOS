//
//  GiftRecordVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/16.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

/// Giftを登録・編集する画面
final class GiftRecordVC: UIViewController, EventTrackable {
    // MARK: - Presenter
    private var presenter: GiftRecordPresenterInput!
    func inject(presenter: GiftRecordPresenter) {
        self.presenter = presenter
    }

    // MARK: - IBOutlet Properties
    @IBOutlet weak var recordButton: UIBarButtonItem!
    @IBOutlet weak var gotOrReceived: InspectableSegmentedControl!
    @IBOutlet weak var memoView: InspectableTextView!
    
    // MARK: - Properties
    /// コンテナビューのテーブルVC
    var tableVC: GiftRecordTableVC!
    // アクティブなテキストフィールド
    private var activeTextField: UITextView?

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // InspectableTextViewのデリゲートを上書きするために必要
        memoView.delegate = self
        // 子ビューを特定する
        discoverChildVC()
        presenter.setExistGift()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreen()
    }
    
    // MARK: - IBAction methods
    /// キャンセルボタンを押した時
    @IBAction func didTapCancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    /// 登録ボタンを押した時
    @IBAction func didTapRecordButton(_ sender: UIBarButtonItem) {
        presenter.didTapRecordButton(isReceived: gotOrReceived.selectedSegmentIndex == 0,
                                     isDateTBD: tableVC.dateTBDSwitch.isOn,
                                     personName: tableVC.personNameField.text!,
                                     annivName: tableVC.annivNameField.text!,
                                     timestamp: tableVC.timestamp,
                                     goods: tableVC.goodsField.text!,
                                     mwmo: memoView.text)
    }
    
    
    // MARK: - Misc methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 画面タッチでキーボードを下げる
        view.endEditing(true)
    }
}

// MARK: - Private methods
private extension GiftRecordVC {
    /// 子VCを特定する
    private func discoverChildVC() {
        // ContainerViewを特定
        for child in children {
            if let child = child as? GiftRecordTableVC {
                tableVC = child
                // GiftRecordTableVCのデリゲートをこのクラスに移譲する
                tableVC.giftRecordTableVCDelegate = self
                break
            }
        }
    }
}

// MARK: - UITextView Delegate
extension GiftRecordVC: UITextViewDelegate{
    /// メモを書き始めるときにキーボードと重ならないように画面を上げる
    /// TODO: ソフトウェアキーボードを使わない入力の場合は画面だけ不自然にずれてしまう？
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -200)
        }
        return true
    }
    /// 上げていた画面を元に戻す
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform.identity
        }
        return true
    }
    /// に書き換えられるたびにプレースホルダーの表示切替を判断する
    func textViewDidChange(_ textView: UITextView) {
        memoView.togglePlaceholder()
    }
}


// MARK: - GiftRecordTableVC Delegate
// 登録ボタンの有効・無効を切り替えるデリゲート
extension GiftRecordVC: GiftRecordTableVCDelegate {
    /// 通知を受けて完了ボタンの有効非有効を切り替える
    func recordingStandby(_ enabled: Bool) {
        recordButton.isEnabled = enabled
    }
}

extension GiftRecordVC: GiftRecordPresenterOutput {
    /// 自らのModal画面を閉じる
    func dismiss(animated: Bool) {
        dismiss(animated: animated, completion: nil)
    }
    /// 既存ギフトの編集なら既存のデータを画面へ反映する
    func setupLayout(gift: Gift?) {
        guard let gift = gift else {
            title = "recordGift".localized
            return
        }
        gotOrReceived.selectedSegmentIndex = gift.isReceived ? 0 : 1
        tableVC.personNameField.text = gift.personName
        tableVC.annivNameField.text = gift.annivName
        
        if let timestamp = gift.date {
            tableVC.timestamp = timestamp
            tableVC.dateField.text = DateTimeFormat.getYMDString(date: timestamp.dateValue())
        } else {
            tableVC.dateTBDSwitch.isOn = true
            tableVC.doDateTBD(isTBD: true)
        }
        
        tableVC.goodsField.text = gift.goods
        if !gift.memo.isEmpty {
            memoView.text = gift.memo
            memoView.togglePlaceholder()
        }
        title = "updateGift".localized
    }
}
