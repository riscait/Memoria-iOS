//
//  GiftRecordVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/16.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

class GiftRecordVC: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var recordButton: UIBarButtonItem!
    @IBOutlet weak var gotOrReceived: InspectableSegmentedControl!
    @IBOutlet weak var memoView: InspectableTextView!
    /// コンテナビューのテーブルVC
    var tableVC: GiftRecordTableVC!
    // 編集の場合はギフト情報を受け取る
    var selectedGiftId: String?
    
    private var activeTextField: UITextView?
    

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectedGiftId == nil ? "recordGift".localized : "updateGift".localized
        // InspectableTextViewのデリゲートを上書きするために必要
        memoView.delegate = self
        
        discoverChildVC()
        // 新規登録ではなく、ギフト更新なら登録済みデータを反映する
        setGiftData()
    }
    

    // MARK: - IBAction methods
    /// キャンセルボタンを押した時
    @IBAction func didTapCancelButton(_ sender: UIBarButtonItem) {
        let message = selectedGiftId == nil ? "discardMessageForRecord".localized : "discardMessageForEdit".localized
        
        DialogBox.showDestructiveAlert(on: self, message: message, destructiveTitle: "close".localized) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    /// 登録ボタンを押した時
    @IBAction func didTapRecordButton(_ sender: UIBarButtonItem) {
        // ギフト新規登録なら新しくIDを生成
        let uuid = selectedGiftId ?? UUID().uuidString
        // もらいもの？あげたもの？
        let isReceived = gotOrReceived.selectedSegmentIndex == 0
        // 日付未定の記念日か否か
        let isDateTBD = tableVC.dateTBDSwitch.isOn
        
        // ギフトデータをセット
        let gift = Gift(id: uuid,
                                 isReceived: isReceived,
                                 personName: tableVC.personNameField.text!,
                                 annivName: tableVC.annivNameField.text!,
                                 date: isDateTBD ? nil : tableVC.timestamp ?? Timestamp(),
                                 goods: tableVC.goodsField.text!,
                                 memo: memoView.text,
                                 isHidden: false,
                                 iconImage: nil)
        print(gift)
        // DBに書き込んで画面を閉じる
        GiftDAO.set(documentPath: uuid, data: gift)
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Misc methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 画面タッチでキーボードを下げる
        view.endEditing(true)
    }
    
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

    /// ギフトの編集なら、元のデータを反映させる
    private func setGiftData() {
        guard let selectedGiftId = selectedGiftId else { return }

        GiftDAO.get(by: selectedGiftId) { (gift) in

            self.gotOrReceived.selectedSegmentIndex = (gift["isReceived"] as! Bool) ? 0 : 1
            self.tableVC.personNameField.text = gift["personName"] as? String
            self.tableVC.annivNameField.text = gift["anniversaryName"] as? String
            if let timestamp = (gift["date"] as? Timestamp) {
                self.tableVC.timestamp = timestamp
                self.tableVC.dateField.text = DateTimeFormat.getYMDString(date: timestamp.dateValue())
            } else {
                self.tableVC.dateTBDSwitch.isOn = true
                self.tableVC.doDateTBD(isTBD: true)
            }
            self.tableVC.goodsField.text = gift["goods"] as? String
            if let memo = gift["memo"] as? String {
                self.memoView.text = memo
                self.memoView.togglePlaceholder()
            }
        }
    }
}

extension GiftRecordVC: UITextViewDelegate{
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print(#function, textView)
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -200)
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        print(#function, textView)
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform.identity
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        memoView.togglePlaceholder()
    }
}


// MARK: - GiftRecordTableVC Delegate
// 登録ボタンの有効・無効を切り替えるデリゲート
extension GiftRecordVC: GiftRecordTableVCDelegate {
    func recordingStandby(_ enabled: Bool) {
        recordButton.isEnabled = enabled
    }
}
