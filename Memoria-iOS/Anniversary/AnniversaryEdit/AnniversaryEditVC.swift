//
//  AnniversaryEditVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/01/06.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit
import Firebase

class AnniversaryEditVC: UIViewController {

    // MARK: - Property
    
    @IBOutlet weak var anniversaryTypeChoice: InspectableSegmentedControl!
    @IBOutlet weak var anniversaryTypeLabel: UILabel!
    @IBOutlet weak var anniversaryTitleField: InspectableTextField!
    @IBOutlet weak var leftNameField: InspectableTextField!
    @IBOutlet weak var rightNameField: InspectableTextField!
    @IBOutlet weak var hideAnniversaryButton: UIButton!
    
    var anniversaryType: AnniversaryType?
    
    /// コンテナビューのテーブルVC
    var tableVC: AnniversaryEditTableVC!

    // 編集の場合は記念日情報を前の画面から受け取る
    var anniversaryData: AnniversaryDataModel?
    
    
    // MARK: - IBAction method
    
    /// 閉じるボタンが押された時
    @IBAction func didTapDismissButton(_ sender: UIBarButtonItem) {
        let message = anniversaryData == nil ? "discardMessageForRecord".localized : "discardMessageForEdit".localized
        
        DialogBox.showDestructiveAlert(on: self, message: message, destructiveTitle: "close".localized) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    /// 記念日登録ボタンが押された時
    @IBAction func didTapApprovalButton(_ sender: UIBarButtonItem) {
        // 新規登録なら新しくIDを生成
        let uuid = anniversaryData?.id ?? UUID().uuidString
        // Birthday or Anniversary?
        anniversaryType = AnniversaryType(rawValue: anniversaryTypeChoice.selectedSegmentIndex)
        // Annualy anniversary?
        let isAnnualy = tableVC.annualySwitch.isOn
        
        // データをセット
        let anniversary = AnniversaryDataModel(id: uuid,
                                               category: anniversaryType!,
                                               title: anniversaryTitleField.text,
                                               familyName: leftNameField.text,
                                               givenName: rightNameField.text,
                                               date: tableVC.timestamp ?? Timestamp(),
                                               iconImage: nil,
                                               isHidden: false,
                                               isAnnualy: isAnnualy,
                                               isFromContact: false)
        print(anniversary)
        // DBに書き込んで画面を閉じる
        AnniversaryDAO.set(documentPath: uuid, data: anniversary)
        dismiss(animated: true, completion: nil)
    }
    /// 記念日の種類を切り替えるボタンが押された時
    @IBAction func toggleAnniversaryType(_ sender: InspectableSegmentedControl) {
        anniversaryType = AnniversaryType(rawValue: sender.selectedSegmentIndex)
        configureUI(with: anniversaryType!)
    }
    /// 非表示にするボタンを押された時
    @IBAction func didTapHideButton(_ sender: UIButton) {
        print("非表示にします")
        DialogBox.showAlert(on: self,
                            hasCancel: true,
                            title: "hideThisAnniversaryTitle".localized,
                            message: "hideThisAnniversaryMessage".localized,
                            defaultAction: {
                                guard let anniversaryData = self.anniversaryData else { return }
                                AnniversaryDAO.update(anniversaryId: anniversaryData.id, field: "isHidden", content: true)
                                // 画面を閉じる
                                self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Title of this screen
        title = "anniversaryRecord".localized
        
        configureUI(with: anniversaryType ?? .anniversary)
        configureField(with: anniversaryData)
        // 新規登録時は非表示ボタンを表示しない
        hideAnniversaryButton.isHidden = anniversaryData == nil
    }
    
    
    // MARK: - Private method
    
    /// 記念日の種類をもとに画面を構成する
    ///
    /// - Parameter anniversaryType: 記念日の種類の列挙型
    private func configureUI(with anniversaryType: AnniversaryType) {
        switch anniversaryType {
        case .anniversary:
            anniversaryTypeLabel.text = "anniversaryTitleLabel".localized
            anniversaryTitleField.isHidden = false
            leftNameField.isHidden = true
            rightNameField.isHidden = true
            
        case .birthday:
            anniversaryTypeLabel.text = "birthdayNameLabel".localized
            anniversaryTitleField.isHidden = true
            leftNameField.isHidden = false
            rightNameField.isHidden = false
        }
    }
    
    /// 編集なら、前の画面から受け取った記念日を反映する
    func configureField(with anniversary: AnniversaryDataModel?) {
        guard let anniversary = anniversary else { return }
        
        switch anniversary.category {
        case .anniversary:
            anniversaryTitleField.text = anniversary.title
            
        case .birthday:
            leftNameField.text = anniversary.familyName
            rightNameField.text = anniversary.givenName
        }
        
        
    }
    /// 非表示にするボタンを承諾した時の処理
//    private func hideThisAnniversary() {
//        guard let anniversaryId = anniversaryId else { return }
//        AnniversaryDAO.set(documentPath: anniversaryId, data: ["isHidden": true])
//        // 画面を閉じる
//        dismiss(animated: true, completion: nil)
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
