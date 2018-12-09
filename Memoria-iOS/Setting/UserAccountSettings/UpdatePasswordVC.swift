//
//  UpdatePasswordVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/08.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

import Firebase

class UpdatePasswordVC: UIViewController {

    @IBOutlet weak var currentPasswordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var newPasswordConfirmationField: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    
    var activeTextField: UITextField?

    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("updatePassword", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureObserver()
    }


    // MARK: - タッチアクション

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)  // キーボードを下げる
    }

    @IBAction func didTapUpdateButton(_ sender: UIButton) {
        // 2度押し防止のため、まずボタンを無効にする
        updateButton.isEnabled = false

        guard let user = Auth.auth().currentUser,
            let email = user.email,
            let currentPassword = currentPasswordField.text,
            let newPassword = newPasswordField.text,
            let newPasswordConfirmation = newPasswordConfirmationField.text else { return }
        
        print("""
            currentPassword: \(currentPassword)
            newPassword: \(newPassword)
            newPasswordConfirmation: \(newPasswordConfirmation)
            """)
        
        guard currentPassword != newPassword else {
            // 現在のパスワードと新しいパスワードが一緒なら失敗
            print("現在のパスワードと新しいパスワードが一緒")
            DialogBox.showAlert(on: self, message: NSLocalizedString("currentAndNewPasswordAreSame", comment: ""))
            newPasswordField.text = nil
            newPasswordConfirmationField.text = nil
            return
        }
        guard newPassword == newPasswordConfirmation else {
            // 新しいパスワードと確認用パスワードが違ったら失敗
            print("確認パスワードが一致しません")
            DialogBox.showAlert(on: self, message: NSLocalizedString("mismatchPasswordConfirmation", comment: ""))
            newPasswordConfirmationField.text = nil
            return
        }
        // 再認証に使うため、Email&パスワードログインの認証情報を取得
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        // 取得した認証情報で再認証
        DialogBox.showAlertWithIndicator(on: self, message: NSLocalizedString("reauthInProgress", comment: "")) {
            user.reauthenticateAndRetrieveData(with: credential) { (authResult, error) in
                if let error = error {
                    print("エラー: \(error)")
                    // 失敗した場合はエラーダイアログを表示して処理終了
                    DialogBox.showAlert(on: self,
                                        message: NSLocalizedString(error.localizedDescription, comment: ""))
                    self.currentPasswordField.text = nil
                    DialogBox.dismissAlertWithIndicator(on: self, completion: nil)
                    return
                }
                print("再認証成功")
                // パスワード変更処理
                DialogBox.updateAlert(with: NSLocalizedString("updatePasswordInProgress", comment: ""), on: self)
                user.updatePassword(to: newPassword) { error in
                    DialogBox.dismissAlertWithIndicator(on: self) {
                        
                        if let error = error {
                            print("エラー: \(error)")
                            // エラーダイアログ表示して処理終了
                            DialogBox.showAlert(on: self, message: NSLocalizedString(error.localizedDescription, comment: ""))
                            return
                        }
                        print("パスワードの変更に成功")
                        DialogBox.showAlert(on: self, message: NSLocalizedString("successfullyUpdatePassword", comment: "")) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
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
        // メールアドレスが8文字以上入力されているか
        updateButton.isEnabled = currentPasswordField.text?.count ?? 0 > 7
            && newPasswordField.text?.count ?? 0 > 7
            && newPasswordConfirmationField.text?.count ?? 0 > 7
            ? true : false
        print(#function)
    }
}


// MARK: - UITextFieldDelegate

extension UpdatePasswordVC: UITextFieldDelegate {
    
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
