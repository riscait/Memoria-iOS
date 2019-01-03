//
//  GiftRecordTableVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/16.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

/// すべてのフィールドにテキストが入力されて登録ボタンを押せることを知らせる
protocol GiftRecordTableVCDelegate: AnyObject {
    func recordingStandby(_ enabled: Bool)
}

/// 進行方向を定める列挙体
enum Direction {
    case previous
    case next
}

/// プレゼントや渡す相手などの情報を入力するためのテーブルVC
class GiftRecordTableVC: UITableViewController {
    
    enum SegueVC: String {
        case selectPersonVC = "GiftRecordSelectPersonVC"
        case selectAnniversaryVC = "GiftRecordSelectAnniversaryVC"
    }
    
    @IBOutlet weak var personNameField: UITextField!
    @IBOutlet weak var personSelectIcon: UIImageView!
    @IBOutlet weak var anniversarySelectIcon: UIImageView!
    @IBOutlet weak var anniversaryNameField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var goodsField: UITextField!
    
    private var datePicker: UIDatePicker!
    var timeStamp: Timestamp?
    
    
    // 登録ボタンを押せることを知らせるプロトコルのデリゲートを宣言
    weak var giftRecordTableVCDelegate: GiftRecordTableVCDelegate?
    
    
    // MARK: - IBAction
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        print(#function)
        checkReadyForRecording()
        
        if sender == dateField {
            dateField.text = DateTimeFormat.getYMDString(date: datePicker.date)
            timeStamp = Timestamp(date: datePicker.date)
        }
    }
    
    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // placeholder is today
        dateField.placeholder = DateTimeFormat.getYMDString()
        setupDesign()
        setupDatePicker()
    }
    
    // セグエでの遷移前の準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 遷移元のVCを特定して列挙型に当てはめる
        guard let segueVC = SegueVC(rawValue: String(describing: type(of: segue.destination))) else { return }
        // 遷移前の画面を判別
        switch segueVC {
        case .selectPersonVC:
            (segue.destination as! GiftRecordSelectPersonVC).delegate = self
        case .selectAnniversaryVC:
            (segue.destination as! GiftRecordSelectAnniversaryVC).delegate = self
        }
    }
    
    
    // MARK: - Private Method
    private func checkReadyForRecording() {
        if !(personNameField.text?.isEmpty ?? true),
            !(anniversaryNameField.text?.isEmpty ?? true),
            !(goodsField.text?.isEmpty ?? true) {
            print("ready!")
            // デリゲートメソッドを実行する
            giftRecordTableVCDelegate?.recordingStandby(true)
        } else {
            print("not ready!")
            // デリゲートメソッドを実行する
            giftRecordTableVCDelegate?.recordingStandby(false)
        }
    }
    
    private func setupDesign() {
        personSelectIcon.tintColor = UIColor.init(named: "mainColor")
        anniversarySelectIcon.tintColor = UIColor.init(named: "mainColor")
    }
    
    private func setupDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        dateField.inputAccessoryView = setupToolbar()
        dateField.inputView = datePicker
    }
    private func setupToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let next = UIBarButtonItem(title: "next".localized, style: .done, target: self, action: #selector(moveToDateFieldEdit))
        next.tintColor = UIColor.init(named: "mainColor")
        let previous = UIBarButtonItem(title: "previous".localized, style: .plain, target: self, action: #selector(moveToAnniversaryFieldEdit))
        previous.tintColor = UIColor.init(named: "mainColor")
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([previous, space, next], animated: true)

        return toolbar
    }
    
    @objc private func moveToDateFieldEdit() {
        editingField(dateField, moveToFieldWith: .next)
    }
    @objc private func moveToAnniversaryFieldEdit() {
        editingField(dateField, moveToFieldWith: .previous)
    }

    private func editingField(_ textField: UITextField, moveToFieldWith direction: Direction) {
        // 現在のtextFieldからフォーカスを外す
        textField.resignFirstResponder()
        
        let nextTag: Int
        switch direction {
        case .previous:
            nextTag = textField.tag - 1
        case .next:
            nextTag = textField.tag + 1
        }
        // 次のTag番号を持っているtextFieldがあれば、フォーカスする
        if let nextField = view.viewWithTag(nextTag) as? UITextField {
            nextField.becomeFirstResponder()
        }
    }
}

// MARK: - Text field delegate
extension GiftRecordTableVC: UITextFieldDelegate {
    
    /// Did tap CLEAR button
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        giftRecordTableVCDelegate?.recordingStandby(false)
        return true
    }
    
    /// Did tap Return key
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        editingField(textField, moveToFieldWith: .next)
        return true
    }
}

// MARK: - GiftRecordSelectPersonVC Delegate
extension GiftRecordTableVC: GiftRecordSelectPersonVCDelegate {
    
    /// Update Person name
    func updatePersonName(with text: String?) {
        print(#function, text ?? "nil")
        personNameField.text = text
    }
}

// MARK: - GiftRecordSelectAnniversaryVC Delegate
extension GiftRecordTableVC: GiftRecordSelectAnniversaryVCDelegate {
    
    /// Update Anniversary name
    func updateAnniversaryName(with text: String?) {
        print(#function, text ?? "nil")
        anniversaryNameField.text = text
    }
}
