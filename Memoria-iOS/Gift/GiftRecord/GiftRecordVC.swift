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

    // MARK: - Property
    
    @IBOutlet weak var recordButton: UIBarButtonItem!
    @IBOutlet weak var gotOrReceived: InspectableSegmentedControl!
    @IBOutlet weak var memoView: InspectableTextView!
    /// コンテナビューのテーブルVC
    var tableVC: GiftRecordTableVC!
    // プレゼント更新ならギフト情報を受け取る
    var selectedGiftId: String?
    

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectedGiftId == nil ? "recordGift".localized : "updateGift".localized
        // ContainerViewを特定
        for child in children {
            if let child = child as? GiftRecordTableVC {
                tableVC = child
                // GiftRecordTableVCのデリゲートをこのクラスに移譲する
                tableVC.giftRecordTableVCDelegate = self
                break
            }
        }
        // 新規登録ではなく、ギフト更新なら登録済みデータを反映する
        setGiftData()
    }
    
    
    // MARK: - IBAction
    /// キャンセルボタンを押した時
    @IBAction func didTapCancelButton(_ sender: UIBarButtonItem) {
        DialogBox.showDestructiveAlert(on: self, message: "realy".localized, destructiveTitle: "discard".localized) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    /// 登録ボタンを押した時
    @IBAction func didTapRecordButton(_ sender: UIBarButtonItem) {
        // プレゼント新規登録なら新しくIDを生成
        let uuid = selectedGiftId ?? UUID().uuidString
        // もらったものかあげたものか
        let isReceived = gotOrReceived.selectedSegmentIndex == 0
        // プレゼントデータをセット
        let gift = GiftDataModel(id: uuid,
                                 isReceived: isReceived,
                                 personName: tableVC.personNameField.text!,
                                 anniversaryName: tableVC.anniversaryNameField.text!,
                                 date: tableVC.timeStamp ?? Timestamp(),
                                 goods: tableVC.goodsField.text!,
                                 memo: memoView.text)
        // DBに書き込んで画面を閉じる
        GiftDAO.set(documentPath: uuid, data: gift)
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Misc method
    /// プレゼントの編集なら、元のデータを反映させる
    private func setGiftData() {
        guard let selectedGiftId = selectedGiftId else { return }
        GiftDAO.get(by: selectedGiftId) { (gift) in
            self.gotOrReceived.selectedSegmentIndex = (gift["isReceived"] as! Bool) ? 0 : 1
            self.tableVC.personNameField.text = gift["personName"] as? String
            self.tableVC.anniversaryNameField.text = gift["anniversaryName"] as? String
            self.tableVC.goodsField.text = gift["goods"] as? String
            if let memo = gift["memo"] as? String {
                self.memoView.text = memo
                self.memoView.togglePlaceholder()
            }
        }
    }
}

// MARK: - GiftRecordTableVC Delegate
// 登録ボタンの有効・無効を切り替えるデリゲート
extension GiftRecordVC: GiftRecordTableVCDelegate {
    func recordingStandby(_ enabled: Bool) {
        recordButton.isEnabled = enabled
    }
}
