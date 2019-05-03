//
//  AnnivEditVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/01/06.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit
import Firebase

class AnnivEditVC: UIViewController, StoreReviewRequestable, EventTrackable {

    // MARK: - Property
    
    @IBOutlet weak var recordButton: UIBarButtonItem!
    @IBOutlet weak var annivTypeSegment: InspectableSegmentedControl!
    @IBOutlet weak var annivTypeLabel: UILabel!
    @IBOutlet weak var annivTitleField: InspectableTextField!
    @IBOutlet weak var leftNameField: InspectableTextField!
    @IBOutlet weak var rightNameField: InspectableTextField!
    @IBOutlet weak var memoView: InspectableTextView!
    @IBOutlet weak var annivHideButton: UIButton!
    
    var annivType: AnnivType?
    
    /// コンテナビューのテーブルVC
    var tableVC: AnnivEditTableVC!

    // 編集の場合は記念日情報を前の画面から受け取る
    var annivModel: Anniv?
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Title of this screen
        title = "anniversaryRecord".localized
        // InspectableTextViewのデリゲートを上書きするために必要
        memoView.delegate = self
        
        discoverChildVC()
        configureUI(with: annivModel?.category ?? .anniv)
        // 新規登録ではなく、編集なら登録済みデータを反映する
        configureField(with: annivModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreen()
    }
    
    // MARK: - IBAction methods
    
    /// 閉じるボタンが押された時
    @IBAction func didTapDismissButton(_ sender: UIBarButtonItem) {
        let message = annivModel == nil ? "discardMessageForRecord".localized : "discardMessageForEdit".localized
        
        DialogBox.showDestructiveAlert(on: self, message: message, destructiveTitle: "close".localized) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    /// 記念日登録ボタンが押された時
    @IBAction func didTapRecordlButton(_ sender: UIBarButtonItem) {
        // 新規登録なら新しくIDを生成
        let uuid = annivModel?.id ?? UUID().uuidString
        // 記念日のタイプはセグメントコントロールの選択から判断
        guard let annivType = AnnivType(rawValue: annivTypeSegment.selectedSegmentIndex) else { return }
        // 毎年繰り返す記念日か否かはスイッチで
        let isAnnualy = tableVC.annualySwitch.isOn
        // 連絡先からインポートしたデータであるか否か。新規登録ならfalse
        let isFromContact = annivModel?.isFromContact ?? false
        
        let date = tableVC.timestamp ?? Timestamp()
        
        // 記念日データをセット
        let anniversary = Anniv(id: uuid,
                                category: annivType,
                                title: annivTitleField.text,
                                familyName: leftNameField.text,
                                givenName: rightNameField.text,
                                date: date,
                                iconImage: nil,
                                isHidden: false,
                                isAnnualy: isAnnualy,
                                isFromContact: isFromContact,
                                memo: memoView.text.trimmingCharacters(in: .whitespacesAndNewlines),
                                remainingDays: nil)
        
        AnnivDAO.set(documentPath: uuid, data: anniversary)
        
        let userDefaults = UserDefaults.standard
        
        let numberOfAddedAnnivKey = "numberOfAddedAnniv"
        
        let newNumberOfAddedAnniv = userDefaults.integer(forKey: numberOfAddedAnnivKey).incremented
        userDefaults.set(newNumberOfAddedAnniv, forKey: numberOfAddedAnnivKey)
        
        trackAddAnniversary(eventName: AnnivUtil.getName(from: anniversary),
                            annivDate: date.dateValue(),
                            annivCategory: annivType,
                            numberOfAddedAnniv: newNumberOfAddedAnniv)
        
        dismiss(animated: true) { [weak self] in
            self?.requestStoreReviewWhenAddedAnniv()
        }
    }
    
    /// 記念日の種類を切り替えるボタンが押された時
    @IBAction func toggleAnnivTypeTapped(_ sender: InspectableSegmentedControl) {
        annivType = AnnivType(rawValue: sender.selectedSegmentIndex)
        configureUI(with: annivType!)
        
        // 名称入力欄をリセットする
        annivTitleField.text = nil
        leftNameField.text = nil
        rightNameField.text = nil
        // 登録ボタンを無効化する
        recordButton.isEnabled = false
    }
    
    /// 非表示にするボタンを押された時
    @IBAction func didTapHideButton(_ sender: UIButton) {
        DialogBox.showAlert(on: self,
                            hasCancel: true,
                            title: "hideThisAnniversaryTitle".localized,
                            message: "hideThisAnniversaryMessage".localized,
                            defaultAction: {
                                guard let anniversaryData = self.annivModel else { return }
                                AnnivDAO.update(with: anniversaryData.id, field: "isHidden", content: true)
                                // 画面を閉じる
                                self.dismiss(animated: true) {
                                    // この画面を閉じた後、すぐに詳細画面一覧画面まで一気に戻る
                                    NotificationCenter.default.post(name: .popToAnnivListVC, object: nil)
                                }
        })
    }
    
    @IBAction func textFieldEditingChanged(_ sender: InspectableTextField) {
        validate()
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
            if let child = child as? AnnivEditTableVC {
                tableVC = child
                // GiftRecordTableVCのデリゲートをこのクラスに移譲する
                tableVC.annivEditTableVCDelegate = self
                if let date = annivModel?.date.dateValue() {
                    tableVC.datePicker.setDate(date, animated: true)
                }
                break
            }
        }
    }

    /// 記念日の種類をもとに画面を構成する
    ///
    /// - Parameter annivType: 記念日の種類の列挙型
    private func configureUI(with annivType: AnnivType) {
        switch annivType {
        case .anniv:
            annivTypeSegment.selectedSegmentIndex = 0
            annivTypeLabel.text = "anniversaryTitleLabel".localized
            annivTitleField.isHidden = false
            leftNameField.isHidden = true
            rightNameField.isHidden = true
            
        case .birthday:
            annivTypeSegment.selectedSegmentIndex = 1
            annivTypeLabel.text = "birthdayNameLabel".localized
            annivTitleField.isHidden = true
            leftNameField.isHidden = false
            rightNameField.isHidden = false
        }
    }
    
    /// 編集なら、前の画面から受け取った記念日を反映する
    private func configureField(with annivModel: Anniv?) {
        
        if let anniversary = annivModel {
            // 編集時の処理
            // 記念日タイプを選択不可にする
            annivTypeSegment.isEnabled = false
            // フィールドに値を表示する
            switch anniversary.category {
            case .anniv:
                annivTitleField.text = anniversary.title
                
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
            annivHideButton.isHidden = true
        }
    }
    
    private func validate() {
        switch AnnivType(rawValue: annivTypeSegment.selectedSegmentIndex)! {
        case .anniv: // 記念日名が入力されていればOK
            recordButton.isEnabled = !(annivTitleField.text?.isEmpty ?? true)
            
        case .birthday: // 姓名が入力されていればOK
            recordButton.isEnabled = !(leftNameField.text?.isEmpty ?? true)
                && !(rightNameField.text?.isEmpty ?? true)
        }
    }
}


// MARK: - Text field delegate
extension AnnivEditVC: UITextFieldDelegate {
    
    /// Did tap CLEAR button
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // 記念日の名前か姓名TextFieldのクリアボタンが押されたら登録ボタンを無効化する（ここには日付含まず）
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
extension AnnivEditVC: UITextViewDelegate{
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -200)
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform.identity
        }
        return true
    }
    /// メモが書き換えられたら
    func textViewDidChange(_ textView: UITextView) {
        memoView.togglePlaceholder()
        validate()
    }
}


// MARK: - AnniversaryEditTableVC Delegate
// TableVCから通知を受けて、登録ボタンの有効・非有効化を検証するメソッドを呼ぶ
extension AnnivEditVC: AnnivEditTableVCDelegate {
    func needValidation(with enabled: Bool) {
        // v2.0.1現在、必ずtrueで呼ばれる
        if enabled { validate() }
    }
}
