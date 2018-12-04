//
//  SignInVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/01.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

import Firebase

class SignInVC: UIViewController {
    
    @IBOutlet weak var emailField: InspectableTextField!
    @IBOutlet weak var passwordField: InspectableTextField!
    @IBOutlet weak var signInButton: UIButton!
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func setPlaceholder(localizedStringKey: String, color: UIColor) -> NSAttributedString {
        return NSAttributedString(string: NSLocalizedString(localizedStringKey, comment: ""),
                                  attributes: [NSAttributedString.Key.foregroundColor: color])
    }
    
    
    // MARK: - IBAction
    
    @IBAction func didTapSignIn(_ sender: UIButton) {
        guard let email = emailField.text else {
            emailField.attributedPlaceholder = setPlaceholder(localizedStringKey: "pleaseEnterEmail", color: warningColor)
            return
        }
        guard let password = passwordField.text else {
            passwordField.attributedPlaceholder = setPlaceholder(localizedStringKey: "pleaseEnterPassword", color: warningColor)
            return
        }
        DialogBox.showAlertWithIndicator(on: self, message: NSLocalizedString("underSignIn", comment: "")) {
            // START: メールアドレスログイン処理
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                DialogBox.dismissAlertWithIndicator(on: self) {
                    print("ログイン結果: \(String(describing: authResult))")
                    if let error = error {
                        print(error)
                        DialogBox.showAlert(on: self, message: NSLocalizedString(error.localizedDescription, comment: ""))
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func didTapForgotPasswordButton(_ sender: UIButton) {
        guard let email = emailField.text else { return }
        if email.isEmpty {
            DialogBox.showAlert(on: self, message: NSLocalizedString("pleaseEnterEmail", comment: ""))
            return
        }
        DialogBox.showAlertWithIndicator(on: self, message: NSLocalizedString("underSendEmail", comment: "")) {
            
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                DialogBox.dismissAlertWithIndicator(on: self) {
                    if let error = error {
                        print(error)
                        DialogBox.showAlert(on: self, message: NSLocalizedString(error.localizedDescription, comment: ""))
                        return
                    }
                    DialogBox.showAlert(on: self, title: NSLocalizedString("passwordResetMailSentTitle", comment: ""),
                                        message: NSLocalizedString("passwordResetMailSentMessage", comment: ""))
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
        // メールアドレスとパスワードが8文字以上入力されているか
        if emailField.text?.count ?? 0 > 7,
            passwordField.text?.count ?? 0 > 7 {
            signInButton.isEnabled = true
        } else {
            signInButton.isEnabled = false
        }
        print("textFieldEditingChangedを実行")
    }
}

// MARK: - UITextFieldDelegate

extension SignInVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
