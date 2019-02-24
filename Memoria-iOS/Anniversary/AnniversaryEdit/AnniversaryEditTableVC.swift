//
//  AnniversaryEditTableVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/01/07.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit
import Firebase

/// すべてのフィールドにテキストが入力されて登録ボタンを押せることを知らせる
protocol AnniversaryEditTableVCDelegate: AnyObject {
    func recordingStandby(_ enabled: Bool)
}

/// Anniversaryの情報を入力するためのテーブルVC
class AnniversaryEditTableVC: UITableViewController {

    // MARK: - Properties

    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var annualySwitch: UISwitch!
    
    var datePicker: UIDatePicker!

    var timestamp: Timestamp?
    
    // 登録ボタンを押せることを知らせるプロトコルのデリゲートを宣言
    weak var anniversaryEditTableVCDelegate: AnniversaryEditTableVCDelegate?
    
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDatePicker()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureObserver()
    }

    
    // MARK: - IBAction method

    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        print(#function)
        checkReadyForRecording()
        
        if sender == dateField {
            dateField.text = DateTimeFormat.getYMDString(date: datePicker.date)
            timestamp = Timestamp(date: datePicker.date)
        }
    }

    @IBAction private func toggleAnnualy(_ sender: UISwitch) {
        print(#function)
        checkReadyForRecording()
    }
    
    // MARK: - Private Method
    
    @objc private func checkReadyForRecording() {
        if !(dateField.text?.isEmpty ?? true) {
            print("ready!")
            // デリゲートメソッドを実行する
            anniversaryEditTableVCDelegate?.recordingStandby(true)
        } else {
            print("not ready!")
            // デリゲートメソッドを実行する
            anniversaryEditTableVCDelegate?.recordingStandby(false)
        }
    }

    private func setupDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(checkReadyForRecording), for: .valueChanged)
        // placeholder is today
        dateField.placeholder = DateTimeFormat.getYMDString()
        dateField.inputView = datePicker
    }


    // MARK: - Notification
    
    /// Notification発行
    func configureObserver() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                 name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                 name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// キーボード表示時に、TextFieldとキーボードが重なるのであれば画面をずらす。
    @objc func keyboardWillShow(_ notification: Notification?) {
        guard let keyboardHeight = (notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height,
            let duration = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        // 親Viewからの相対位位置ではなく、最上階層のviewからの位置を求めるためにはコンバートが必要
        let convertedFrame = dateField.convert(dateField.bounds, to: self.view)
        let textFieldOrignY = convertedFrame.minY
        let textFieldHeight = convertedFrame.height
        
        let screenHeight = UIScreen.main.bounds.size.height
        let keyboardY = screenHeight - keyboardHeight
        let textFieldBottom = textFieldOrignY + textFieldHeight
        let distance = keyboardY - textFieldBottom
        // TextFieldとキーボードの距離が0未満なら（重なっていたら）画面をずらす
        if distance < 0 {
            UIView.animate(withDuration: duration) {
                let transform = CGAffineTransform(translationX: 0, y: distance)
                self.view.transform = transform
            }
        }
    }
    
    /// キーボードが降りたら画面を戻す
    @objc func keyboardWillHide(_ notification: Notification?) {
        guard let duration = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration) {
            self.view.transform = CGAffineTransform.identity
        }
    }
}