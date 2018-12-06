//
//  UpdateEmailVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/06.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

import Firebase

class UpdateEmailVC: UIViewController {

    @IBOutlet weak var currentEmail: UILabel!
    @IBOutlet weak var newEmailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var changeButton: UIButton!
    
    var activeTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        currentEmail.text = Auth.auth().currentUser?.email
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureObserver()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)  // キーボードを下げる
    }
    
    @IBAction func didTapChangeButton(_ sender: UIButton) {
        let message = NSLocalizedString("updatedEmailMessage", comment: "")
        
        Auth.auth().currentUser?.updateEmail(to: newEmailField.text!) { (error) in
            if let error = error {
                DialogBox.showAlert(on: self, message: NSLocalizedString(error.localizedDescription, comment: ""))
                print("エラー: \(error)")
                return
            }
            DialogBox.showAlertWithIndicator(on: self, message: message) {
                self.dismiss(animated: true, completion: nil)
            }
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
        notification.addObserver(self, selector: #selector(textFieldEditingChanged(_:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    /// キーボード表示時に画面をずらす。
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
            スクリーンの高さ: \(screenHeight) --- キーボードの高さ: \(keyboardHeight)\n
            TextFieldの上辺位置: \(textFieldOrignY) --- TextFieldの高さ: \(textFieldHeight)\n
            TextFieldの下辺位置: \(textFieldBottom) --- キーボードの上辺位置: \(keyboardY)\n
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
        // メールアドレスが8文字以上入力されているか
        changeButton.isEnabled = newEmailField.text?.count ?? 0 > 7 && activeTextField?.text?.count ?? 0 > 7
            ? true : false
        print(#function)
    }
}

// MARK: - UITextFieldDelegate

extension UpdateEmailVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードのReturnボタンタップでキーボードを閉じる
        view.endEditing(true)
        return true
    }
}
