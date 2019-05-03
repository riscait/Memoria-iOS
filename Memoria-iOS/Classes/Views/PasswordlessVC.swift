//
//  PasswordlessVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/02.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

import Firebase

class PasswordlessVC: UIViewController, EventTrackable {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var sendSignInLinkButton: UIButton!
    
    private var activeTextField: UITextField?

    
    // MARK: - ライフサイクル

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("passwordless", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreen()
        
        configureObserver()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    // MARK: - IBAction

    func setPlaceholder(localizedStringKey: String, color: UIColor) -> NSAttributedString {
        return NSAttributedString(string: NSLocalizedString(localizedStringKey, comment: ""),
                                  attributes: [NSAttributedString.Key.foregroundColor: color])
    }

    
    @IBAction func didTapSendLogInLink(_ sender: UIButton) {
        
        guard let email = emailField.text else { return }
        
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "")
        // ログイン操作は常にアプリで完了している必要があります
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        
        Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { (error) in
            DialogBox.dismissAlertWithIndicator(on: self, completion: {
                if let error = error {
                    Log.warn(error.localizedDescription)
                    DialogBox.showAlert(on: self, message: NSLocalizedString(error.localizedDescription, comment: ""))
                    return
                }
                // リンクは正常に送信されました。ユーザーに通知します
                // 電子メールをローカルに保存して、ユーザに再度質問する必要はありません
                // それらが同じデバイス上のリンクを開く場合。
            DialogBox.showAlert(on: self, message: NSLocalizedString("Check your email for link", comment: ""))
            })
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
        // メールアドレスとパスワードが8文字以上入力されているか
        if emailField.text?.count ?? 0 > 7 {
            sendSignInLinkButton.isEnabled = true
        } else {
            sendSignInLinkButton.isEnabled = false
        }
    }
}

// MARK: - UITextFieldDelegate

extension PasswordlessVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
