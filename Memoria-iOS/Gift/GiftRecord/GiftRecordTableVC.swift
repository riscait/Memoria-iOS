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

/// 進行方向を定める列挙型
enum Direction {
    case previous
    case next
}

/// プレゼントや渡す相手などの情報を入力するためのテーブルVC
class GiftRecordTableVC: UITableViewController {
    
    // MARK: - Enum
    
    enum SegueVC: String {
        case selectPersonVC = "GiftRecordSelectPersonVC"
        case selectAnniversaryVC = "GiftRecordSelectAnniversaryVC"
    }
    
    
    // MARK: - Properties
    
    @IBOutlet weak var personNameField: UITextField!
    @IBOutlet weak var personSelectIcon: UIImageView!
    @IBOutlet weak var anniversarySelectIcon: UIImageView!
    @IBOutlet weak var anniversaryNameField: UITextField!
    @IBOutlet weak var dateCell: UITableViewCell!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var goodsField: UITextField!
    @IBOutlet weak var dateTBDSwitch: UISwitch!
    
    private var datePicker: UIDatePicker!
    
    var timestamp: Timestamp?
    var dateCellHeight: CGFloat = 44
    
    private var activeTextField: UITextField?

    // 登録ボタンを押せることを知らせるプロトコルのデリゲートを宣言
    weak var giftRecordTableVCDelegate: GiftRecordTableVCDelegate?
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // placeholder is today
        dateField.placeholder = DateTimeFormat.getYMDString()
        setupDesign()
        setupDatePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureObserver()
    }
    
    
    // MARK: - Navigation
    
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
    
    
    // MARK: - IBAction method
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        validate()
    }
    
    @IBAction private func toggleDateTBD(_ sender: UISwitch) {
        print(#function)
        doDateTBD(isTBD: sender.isOn)
        validate()
    }
    
    func doDateTBD(isTBD: Bool) {
        dateField.text = isTBD ? "recordDateIsTBD".localized : nil
        dateField.textColor = isTBD ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        (dateCell.viewWithTag(1) as! UILabel).textColor = isTBD ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        dateCell.backgroundColor = isTBD ? #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1) : UIColor.clear
        dateField.isEnabled = !isTBD
        dateField.clearButtonMode = isTBD ? .never : .unlessEditing
        timestamp = nil
    }
    
    
    // MARK: - Private Method
    
    private func validate() {
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
        datePicker.addTarget(self, action: #selector(didChangedDatePickerDate), for: .valueChanged)
        // placeholder is today
        dateField.placeholder = DateTimeFormat.getYMDString()
        dateField.inputAccessoryView = setupKeyboardToolbar()
        dateField.inputView = datePicker
    }
    
    @objc private func didChangedDatePickerDate() {
        // 日付ラベルにピッカーの日付を反映する
        dateField.text = DateTimeFormat.getYMDString(date: datePicker.date)
        // 登録時の日付参照用変数に日付情報を代入
        timestamp = Timestamp(date: datePicker.date)
        validate()
    }

    private func setupKeyboardToolbar() -> UIToolbar {
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
            let duration = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let activeField = activeTextField else { return }
        // 親Viewからの相対位位置ではなく、最上階層のviewからの位置を求めるためにはコンバートが必要
        let convertedFrame = activeField.convert(activeField.bounds, to: self.view)
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

// MARK: - Text field delegate
extension GiftRecordTableVC: UITextFieldDelegate {
    
    /// クリアボタンを押した時
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == dateField {
            let today = Date()
            datePicker.date = today
            timestamp = Timestamp(date: today)
        }
        validate()
        return true
    }
    
    /// Did tap Return key
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        editingField(textField, moveToFieldWith: .next)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }
}

// MARK: - GiftRecordSelectPersonVC Delegate
extension GiftRecordTableVC: GiftRecordSelectPersonVCDelegate {
    /// 選択用画面経由で人名を更新した時
    func updatePersonName(with text: String?) {
        personNameField.text = text
        validate()
    }
}

// MARK: - GiftRecordSelectAnniversaryVC Delegate
extension GiftRecordTableVC: GiftRecordSelectAnniversaryVCDelegate {
    /// 選択用画面経由で記念日名を更新した時
    func updateAnniversaryName(with text: String?) {
        anniversaryNameField.text = text
        validate()
    }
}
