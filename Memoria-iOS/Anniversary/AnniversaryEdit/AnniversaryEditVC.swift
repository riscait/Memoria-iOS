//
//  AnniversaryEditVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/01/06.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit
import Firebase

class AnniversaryEditVC: UIViewController {

    // MARK: - Property
    
    @IBOutlet weak var recordButton: UIBarButtonItem!
    @IBOutlet weak var anniversaryTypeChoice: InspectableSegmentedControl!
    @IBOutlet weak var anniversaryTypeLabel: UILabel!
    @IBOutlet weak var anniversaryTitleField: InspectableTextField!
    @IBOutlet weak var leftNameField: InspectableTextField!
    @IBOutlet weak var rightNameField: InspectableTextField!
    @IBOutlet weak var memoView: InspectableTextView!
    @IBOutlet weak var hideAnniversaryButton: UIButton!
    
    var anniversaryType: AnniversaryType?
    
    /// コンテナビューのテーブルVC
    var tableVC: AnniversaryEditTableVC!

    // 編集の場合は記念日情報を前の画面から受け取る
    var anniversaryData: AnniversaryDataModel?
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Title of this screen
        title = "anniversaryRecord".localized
        // InspectableTextViewのデリゲートを上書きするために必要
        memoView.delegate = self
        
        discoverChildVC()
        configureUI(with: anniversaryData?.category ?? .anniversary)
        // 新規登録ではなく、編集なら登録済みデータを反映する
        configureField(with: anniversaryData)
    }
    
    
    // MARK: - IBAction methods
    
    /// 閉じるボタンが押された時
    @IBAction func didTapDismissButton(_ sender: UIBarButtonItem) {
        let message = anniversaryData == nil ? "discardMessageForRecord".localized : "discardMessageForEdit".localized
        
        DialogBox.showDestructiveAlert(on: self, message: message, destructiveTitle: "close".localized) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    /// 記念日登録ボタンが押された時
    @IBAction func didTapRecordlButton(_ sender: UIBarButtonItem) {
        // 新規登録なら新しくIDを生成
        let uuid = anniversaryData?.id ?? UUID().uuidString
        // 記念日のタイプはセグメントコントロールの選択から判断
        anniversaryType = AnniversaryType(rawValue: anniversaryTypeChoice.selectedSegmentIndex)
        // 毎年繰り返す記念日か否かはスイッチで
        let isAnnualy = tableVC.annualySwitch.isOn
        // 連絡先からインポートしたデータであるか否か。新規登録ならfalse
        let isFromContact = anniversaryData?.isFromContact ?? false
        
        // 記念日データをセット
        let anniversary = AnniversaryDataModel(id: uuid,
                                               category: anniversaryType!,
                                               title: anniversaryTitleField.text,
                                               familyName: leftNameField.text,
                                               givenName: rightNameField.text,
                                               date: tableVC.timestamp ?? Timestamp(),
                                               iconImage: nil,
                                               isHidden: false,
                                               isAnnualy: isAnnualy,
                                               isFromContact: isFromContact,
                                               memo: memoView.text.trimmingCharacters(in: .whitespacesAndNewlines))
        print(anniversary)
        // DBに書き込んで画面を閉じる
        AnniversaryDAO.set(documentPath: uuid, data: anniversary)
        dismiss(animated: true, completion: nil)
    }
    
    /// 記念日の種類を切り替えるボタンが押された時
    @IBAction func toggleAnniversaryType(_ sender: InspectableSegmentedControl) {
        anniversaryType = AnniversaryType(rawValue: sender.selectedSegmentIndex)
        configureUI(with: anniversaryType!)
        
        // 名称入力欄をリセットする
        anniversaryTitleField.text = nil
        leftNameField.text = nil
        rightNameField.text = nil
        // 登録ボタンを無効化する
        recordButton.isEnabled = false
    }
    
    /// 非表示にするボタンを押された時
    @IBAction func didTapHideButton(_ sender: UIButton) {
        print("非表示にします")
        DialogBox.showAlert(on: self,
                            hasCancel: true,
                            title: "hideThisAnniversaryTitle".localized,
                            message: "hideThisAnniversaryMessage".localized,
                            defaultAction: {
                                guard let anniversaryData = self.anniversaryData else { return }
                                AnniversaryDAO.update(anniversaryId: anniversaryData.id, field: "isHidden", content: true)
                                // 画面を閉じる
                                self.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func textFieldEditingChanged(_ sender: InspectableTextField) {
        switch AnniversaryType(rawValue: anniversaryTypeChoice.selectedSegmentIndex)! {
        case .anniversary:
            if !(anniversaryTitleField.text?.isEmpty ?? true) {
                recordButton.isEnabled = true
            } else {
                recordButton.isEnabled = false
            }
            
        case .birthday:
            if !(leftNameField.text?.isEmpty ?? true),
                !(rightNameField.text?.isEmpty ?? true) {
                recordButton.isEnabled = true
                print("enabled")
            } else {
                recordButton.isEnabled = false
                print("desabled")
            }
        }
    }
    
    
    // MARK: - Misc methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 画面タッチでキーボードを下げる
        view.endEditing(true)
    }

    
    // MARK: - Private methods
    
    /// 子VCを特定する
    private func discoverChildVC() {
        // ContainerViewを特定
        for child in children {
            if let child = child as? AnniversaryEditTableVC {
                tableVC = child
                // GiftRecordTableVCのデリゲートをこのクラスに移譲する
                tableVC.anniversaryEditTableVCDelegate = self
                if let date = anniversaryData?.date.dateValue() {
                    tableVC.datePicker.setDate(date, animated: true)
                }
                break
            }
        }
    }

    /// 記念日の種類をもとに画面を構成する
    ///
    /// - Parameter anniversaryType: 記念日の種類の列挙型
    private func configureUI(with anniversaryType: AnniversaryType) {
        switch anniversaryType {
        case .anniversary:
            anniversaryTypeChoice.selectedSegmentIndex = 0
            anniversaryTypeLabel.text = "anniversaryTitleLabel".localized
            anniversaryTitleField.isHidden = false
            leftNameField.isHidden = true
            rightNameField.isHidden = true
            
        case .birthday:
            anniversaryTypeChoice.selectedSegmentIndex = 1
            anniversaryTypeLabel.text = "birthdayNameLabel".localized
            anniversaryTitleField.isHidden = true
            leftNameField.isHidden = false
            rightNameField.isHidden = false
        }
    }
    
    /// 編集なら、前の画面から受け取った記念日を反映する
    private func configureField(with anniversary: AnniversaryDataModel?) {
        
        if let anniversary = anniversary {
            // 編集時の処理
            // 記念日タイプを選択不可にする
            anniversaryTypeChoice.isEnabled = false
            // フィールドに値を表示する
            switch anniversary.category {
            case .anniversary:
                anniversaryTitleField.text = anniversary.title
                
            case .birthday:
                leftNameField.text = anniversary.familyName
                rightNameField.text = anniversary.givenName
            }
            tableVC.timestamp = anniversary.date
            tableVC.dateField.text = DateTimeFormat.getYMDString(date: anniversary.date.dateValue())
            tableVC.annualySwitch.isOn = anniversary.isAnnualy
            memoView.text = anniversary.memo
            if !anniversary.memo.isEmpty {
                memoView.togglePlaceholder()
            }
        } else {
            // 新規登録時の処理
            // 非表示ボタンを表示しない
            hideAnniversaryButton.isHidden = true
        }
    }
}


// MARK: - Text field delegate
extension AnniversaryEditVC: UITextFieldDelegate {
    
    /// Did tap CLEAR button
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        recordButton.isEnabled = false
        return true
    }
    
    /// Did tap Return key
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == leftNameField {
            // 現在のtextFieldからフォーカスを外し、次のFieldへフォーカスを移す
            textField.resignFirstResponder()
            rightNameField.becomeFirstResponder()
        } else {
            // キーボードを下げる
            view.endEditing(true)
        }
        return true
    }
}


// MARK: - Text view delegate
extension AnniversaryEditVC: UITextViewDelegate{
    
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
        
        // TODO: 重複内容だから共通化するAnniversaryType生成するのは一回のみにする
        switch AnniversaryType(rawValue: anniversaryTypeChoice.selectedSegmentIndex)! {
        case .anniversary:
            if !(anniversaryTitleField.text?.isEmpty ?? true) {
                recordButton.isEnabled = true
            } else {
                recordButton.isEnabled = false
            }
            
        case .birthday:
            if !(leftNameField.text?.isEmpty ?? true),
                !(rightNameField.text?.isEmpty ?? true) {
                recordButton.isEnabled = true
                print("enabled")
            } else {
                recordButton.isEnabled = false
                print("desabled")
            }
        }
    }
}


// MARK: - AnniversaryEditTableVC Delegate
// 登録ボタンの有効・無効を切り替えるデリゲート
extension AnniversaryEditVC: AnniversaryEditTableVCDelegate {
    func recordingStandby(_ enabled: Bool) {
        recordButton.isEnabled = enabled
    }
}
