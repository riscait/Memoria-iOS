//
//  SignUpVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/01.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

import Firebase

class SignUpVC: UIViewController, EventTrackable {

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
        trackScreen()
        
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
        DialogBox.showAlertWithIndicator(on: self, message: NSLocalizedString("underSignUp", comment: "")) {
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
