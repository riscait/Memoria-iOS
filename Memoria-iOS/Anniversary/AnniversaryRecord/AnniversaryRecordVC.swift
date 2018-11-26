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
    
    var activeTextField: UITextField?
    
    enum SegueId {
        case birthday
        case anniversary
    }
    
    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("anniversaryRecord", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureObserver()  //Notification発行
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObserver()  //Notification破棄
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
        print("Notificationを発行")
    }
    
    /// Notification破棄
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
        print("Notificationを破棄")
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
}

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
