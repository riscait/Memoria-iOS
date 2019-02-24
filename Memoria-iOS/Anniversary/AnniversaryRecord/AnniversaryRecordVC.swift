//
//  AnniversaryRecordVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/19.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

class AnniversaryRecordVC: UIViewController {

    @IBOutlet weak var familyName: UITextField!
    @IBOutlet weak var givenName: UITextField!
    @IBOutlet weak var anniversaryTitle: UITextField!
    @IBOutlet weak var recordBirthdayButton: PositiveButton!
    @IBOutlet weak var recordAnniversaryButton: PositiveButton!
    
    var activeTextField: UITextField?
    
    enum SegueId {
        case birthday
        case anniversary
    }
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Title of this screen
        title = "anniversaryRecord".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureObserver()  //Notification発行
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBeganが呼ばれた1")
        view.endEditing(true)
    }

    // MARK: - Navigation

    /// 画面遷移直前に呼ばれる
    ///
    /// - Parameters:
    ///   - segue: Segue
    ///   - sender: sender
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let id = segue.identifier else { return }
        
        let segueId = id == "toRecordBirthday" ? SegueId.birthday : SegueId.anniversary
        /// 登録用Anniversaryモデル
        let anniversary: AnniversaryRecordModel
        
        switch segueId {
        case .birthday:
            anniversary = AnniversaryRecordModel(givenName: givenName.text, familyName: familyName.text)

        case .anniversary:
            anniversary = AnniversaryRecordModel(title: anniversaryTitle.text!)
        }
        // 次のVCに記念日情報を渡す
        let nextVC = segue.destination as! AnniversaryDateRecordVC
        nextVC.anniversary = anniversary
    }
    
    
    // MARK: - Notification
    
    /// Notification発行
    func configureObserver() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                 name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                 name: UIResponder.keyboardWillHideNotification, object: nil)
        notification.addObserver(self, selector: #selector(textFieldEditingChanged(_:)), name: UITextField.textDidChangeNotification, object: nil)
        print("Notificationを発行")
    }
    
    /// キーボードが表示時に画面をずらす。
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
        print("""
            スクリーンの高さ: \(screenHeight) --- キーボードの高さ: \(keyboardHeight)
            TextFieldの上辺位置: \(textFieldOrignY) --- TextFieldの高さ: \(textFieldHeight)
            TextFieldの下辺位置: \(textFieldBottom) --- キーボードの上辺位置: \(keyboardY)
            TextFieldとキーボードの距離: \(distance)
            """)
    }

    /// キーボードが降りたら画面を戻す
    @objc func keyboardWillHide(_ notification: Notification?) {
        guard let duration = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration) {
            self.view.transform = CGAffineTransform.identity
        }
    }
    
    /// TextFieldが編集された時に呼び出される
    @objc func textFieldEditingChanged(_ sender: Notification) {
        // 誕生日の名前が入力されているか
        if familyName.text?.count ?? 0 > 0 ||
            givenName.text?.count ?? 0 > 0 {
            recordBirthdayButton.isEnabled = true
        } else {
            recordBirthdayButton.isEnabled = false
        }
        // 記念日の名前が入力されているか
        if anniversaryTitle.text?.count ?? 0 > 0 {
            recordAnniversaryButton.isEnabled = true
        } else {
            recordAnniversaryButton.isEnabled = false
        }
        print("textFieldEditingChangedを実行")
    }
}


// MARK: - UITextFieldDelegate

extension AnniversaryRecordVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension UIScrollView {
    // これがないとスクロールビューがタッチを検出しないため記述
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesBegan(touches, with: event)
    }
}
