//
//  SignUpVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/01.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

import Firebase

class SignUpVC: UIViewController {

    @IBOutlet weak var emailField: InspectableTextField!
    @IBOutlet weak var passwordField: InspectableTextField!
    @IBOutlet weak var passwordConfirmationField: InspectableTextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    private var activeTextField: UITextField?
    private let warningColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)

    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureObserver()
    }
    
    @IBAction func didTapCloseButton(_ sender: UIButton) { dismiss(animated: true, completion: nil) }
    
    @IBAction func didTapSignUpButton(_ sender: PositiveButton) {
        // 各Fieldがきちんと入力されているかチェック
        guard let email = emailField.text,
            !email.isEmpty,
            let password = passwordField.text,
            !password.isEmpty,
            let passwordConfirmation = passwordConfirmationField.text,
            !passwordConfirmation.isEmpty else {
                
                // 入力がないFieldに警告する
                if emailField.text?.isEmpty ?? false {
                    print("emailが空です")
                    emailField.attributedPlaceholder = setPlaceholder(localizedStringKey: "pleaseEnterEmail", color: warningColor)
                }
                if passwordField.text?.isEmpty ?? false {
                    print("passwordFieldが空です")
                    passwordField.attributedPlaceholder = setPlaceholder(localizedStringKey: "pleaseEnterPassword", color: warningColor)
                }
                if passwordConfirmationField.text?.isEmpty ?? false {
                    print("passwordConfirmationFieldが空です")
                    passwordConfirmationField.attributedPlaceholder = setPlaceholder(localizedStringKey: "pleaseEnterPasswordConfirmation", color: warningColor)
                }
                return
        }
        // パスワードの入力が確認入力と同一ではない
        if password != passwordConfirmation {
            print("パスワードが確認と不一致")
            passwordField.text = nil
            passwordField.attributedPlaceholder = setPlaceholder(localizedStringKey: "mismatchPasswordConfirmation", color: warningColor)
            signUpButton.isEnabled = false
            return
        }
        DialogBox.showAlertWithIndicator(on: self, message: "登録中です") {
            // アカウント登録スタート
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                DialogBox.dismissAlertWithIndicator(on: self) {
                    // 除外条件の検証
                    if let error = error {
                        print(error)
                        DialogBox.showAlert(on: self, message: NSLocalizedString(error.localizedDescription, comment: ""))
                        return
                    }
                    print("Sign up成功: \(authResult?.user.email ?? "nil")")
                    // SignUp, SignInの2つの画面を一気に消す
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                } // END: 除外条件の検証
            } // END: アカウント登録
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 画面タッチでキーボードを下げる
        view.endEditing(true)
    }
    
    func setPlaceholder(localizedStringKey: String, color: UIColor) -> NSAttributedString {
        return NSAttributedString(string: NSLocalizedString(localizedStringKey, comment: ""),
                                  attributes: [NSAttributedString.Key.foregroundColor: color])
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
    @objc func keyboardWillShow(_ notification: Notification?) {
        guard let rect = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let textFieldOrignY = activeTextField?.frame.origin.y,
            let textFieldHeight = activeTextField?.frame.height else { return }
        
        let boundSize = UIScreen.main.bounds.size
        let keyboardTop = boundSize.height - rect.size.height
        let textFieldBottom = textFieldOrignY + textFieldHeight + 8
        
        if textFieldBottom >= keyboardTop {
            UIView.animate(withDuration: duration) {
                let transform = CGAffineTransform(translationX: 0, y: -(rect.size.height))
                self.view.transform = transform
            }
        }
        print("keyboardWillShowを実行")
    }
    
    /// キーボードが降りたら画面を戻す
    @objc func keyboardWillHide(_ notification: Notification?) {
        guard let duration = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration) {
            self.view.transform = CGAffineTransform.identity
        }
        print("keyboardWillHideを実行")
    }
    
    /// TextFieldが編集された時に呼び出される
    @objc func textFieldEditingChanged(_ sender: Notification) {
        // 各種フィールドが8文字以上入力されているか
        if emailField.text?.count ?? 0 > 7,
            passwordField.text?.count ?? 0 > 7,
            passwordConfirmationField.text?.count ?? 0 > 7 {
            signUpButton.isEnabled = true
        } else {
            signUpButton.isEnabled = false
        }
        print("textFieldEditingChangedを実行")
    }
}

// MARK: - UITextFieldDelegate

extension SignUpVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
