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
    @IBOutlet weak var changeButton: UIButton!
    
    var activeTextField: UITextField?
    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("updateEmail", comment: "")
        currentEmail.text = Auth.auth().currentUser?.email
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureObserver()
    }
    
    
    // MARK: - タッチアクション
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)  // キーボードを下げる
    }
    
    @IBAction func didTapChangeButton(_ sender: UIButton) {
        // 2度押し防止のため、まずボタンを無効にする
        changeButton.isEnabled = false
        
        guard let newEmail = newEmailField.text,
            let user = Auth.auth().currentUser,
            let email = user.email else { return }
        // メールアドレス変更を試みる
        DialogBox.showAlertWithIndicator(on: self, message: NSLocalizedString("updateEmailInProgress", comment: ""), completion: nil)
        user.updateEmail(to: newEmail) { error in
            DialogBox.dismissAlertWithIndicator(on: self, completion: nil)
            guard let error = error else {
                // メールアドレス変更に成功、処理終了
                print("メールアドレスの変更に成功")
                DialogBox.showAlert(on: self,
                                    title: NSLocalizedString("successfullyChangedEmailTitle", comment: ""),
                                    message: NSLocalizedString("successfullyChangedEmailMessage", comment: "")) {
                                        self.dismiss(animated: true, completion: nil)
                }
                return
            }
            print("エラー: \(error)")
            // エラー原因が「再ログインが必要」以外の場合
            if error.localizedDescription != "This operation is sensitive and requires recent authentication. Log in again before retrying this request." {
                // エラーダイアログ表示して処理終了
                DialogBox.showAlert(on: self, message: NSLocalizedString(error.localizedDescription, comment: ""))
                return
            }
            // 再ログインが必要だった場合、パスワードの入力を求める
            DialogBox.showPasswordInputAlert(on: self,
                                             title: NSLocalizedString("reAuthRequired", comment: ""),
                                             message: NSLocalizedString("pleaseEnterPassword", comment: ""),
                                             placeholder: NSLocalizedString("placeholderPassword", comment: "")) { password in
                                                print("入力されたパスワード:\(password)")
                                                // 再認証に使うため、Email&パスワードログインの認証情報を取得
                                                let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                                                // 取得した認証情報で再認証
                                                DialogBox.showAlertWithIndicator(on: self, message: NSLocalizedString("reauthInProgress", comment: ""), completion: nil)
                                                user.reauthenticateAndRetrieveData(with: credential) { (authResult, error) in
                                                    DialogBox.dismissAlertWithIndicator(on: self, completion: nil)
                                                    if let error = error {
                                                        print("エラー: \(error)")
                                                        // 失敗した場合はエラーダイアログを表示して処理終了
                                                        DialogBox.showAlert(on: self,
                                                                            message: NSLocalizedString(error.localizedDescription, comment: ""))
                                                        return
                                                    }
                                                    print("再認証成功, 再度メールアドレス変更を試みる")
                                                    // もう一度メールアドレス変更を試みる
                                                    DialogBox.showAlertWithIndicator(on: self, message: NSLocalizedString("updateEmailInProgress", comment: ""), completion: nil)
                                                    user.updateEmail(to: newEmail) { (error) in
                                                        // エラー発生したらダイアログ表示して処理終了
                                                        DialogBox.dismissAlertWithIndicator(on: self, completion: nil)
                                                        if let error = error {
                                                            print("2度目でエラー: \(error)")
                                                            DialogBox.showAlert(on: self, message: NSLocalizedString(error.localizedDescription, comment: ""))
                                                            return
                                                        }
                                                        // メールアドレス変更に成功、処理終了
                                                        print("メールアドレスの変更に成功")
                                                        DialogBox.showAlert(on: self,
                                                                            title: NSLocalizedString("successfullyChangedEmailTitle", comment: ""),
                                                                            message: NSLocalizedString("successfullyChangedEmailMessage", comment: "")) {
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
        changeButton.isEnabled = activeTextField?.text?.count ?? 0 > 7
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
